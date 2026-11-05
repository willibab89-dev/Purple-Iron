#!/usr/bin/env python3
"""Exercise critical-hit calculation and stacking paths in both ROMs (PyBoy)."""
from collections import Counter

from pyboy import PyBoy
from test_unique_species import ROOT, symbols


def validate(version):
    rom = (ROOT / (version + ".gbc")).read_bytes()
    syms = symbols(ROOT / (version + ".sym"))
    game = PyBoy(str(ROOT / (version + ".gbc")), window="null", sound_emulated=False)
    game.set_emulation_speed(0)
    game.tick(90, False)
    patches = {}
    visits = Counter()

    def addr(name):
        return syms[name][1]

    def put(name, value):
        game.memory[addr(name)] = value

    def get(name):
        return game.memory[addr(name)]

    def patch(name, code):
        bank, address = syms[name]
        patches.setdefault(name, list(game.memory[bank, address:address + len(code)]))
        game.memory[bank, address:address + len(code)] = code

    def restore(name):
        bank, address = syms[name]
        original = patches.pop(name)
        game.memory[bank, address:address + len(original)] = original

    def call(name, **regs):
        bank, target = syms[name]
        game.memory[0x2000] = bank or 1
        game.memory[0xffb8] = bank or 1
        game.memory[0, 0x100:0x108] = [0xf3, 0xcd, target & 255, target >> 8, 0xc3, 4, 1, 0]
        game.memory[0xffff] = 0
        game.memory[0xff0f] = 0
        game.register_file.SP = 0xdffe
        game.register_file.PC = 0x100
        for key, value in regs.items():
            setattr(game.register_file, key, value)
        for _ in range(120):
            game.tick(1, False)
            if game.register_file.PC in (0x104, 0x105, 0x106):
                return
        raise AssertionError((version, name, hex(game.register_file.PC)))

    def stub(name):
        patch(name, [0xc9])
        bank, address = syms[name]
        game.hook_register(bank, address, lambda key: visits.update([key]), name)

    try:
        # UI/audio exits are stubbed; actual move/item/AI logic and far calls run.
        for name in ("PlayCurrentMoveAnimation", "PrintText", "DelayFrames",
                     "PrintButItFailedText_", "PrintItemUseTextAndRemoveItem",
                     "ItemUseNoEffect", "ItemUseNotTime", "AIPlayRestoringSFX",
                     "AIPrintItemUse", "PlayBattleMusic"):
            stub(name)
        for side in ("Player", "Enemy"):
            status2, status3 = f"w{side}BattleStatus2", f"w{side}BattleStatus3"
            put(status2, 0xfb)  # every other flag set, pumped flag clear
            put(status3, 0xcf)  # all non-counter bits set
            pointer = addr(status2)
            for use in range(1, 6):
                call("RaiseFocusEnergyBoost", D=pointer >> 8, E=pointer & 255)
                assert bool(game.register_file.F & 0x10) == (use <= 3)
                assert get(status3) == 0xcf | (min(use, 3) << 4)
                assert get(status2) == 0xff
            # Haze clears the counter and pumped flag but keeps Transform,
            # Substitute, Rage and unrelated reserved high bits intact.
            call("CureVolatileStatuses", HL=addr(f"w{side}BattleStatus1"))
            assert get(status3) == 0xc8
            assert get(status2) == 0x78

        # Mix Focus Energy and Dire Hit on each side: x2 -> x3 -> x4 -> capped.
        for side, turn, item in (("Player", 0, "ItemUseDireHit"), ("Enemy", 1, "AIUseDireHit")):
            put(f"w{side}BattleStatus2", 0)
            put(f"w{side}BattleStatus3", 0)
            game.memory[0xfff3] = turn
            put("wIsInBattle", 2)
            call("FocusEnergyEffect_")
            assert get(f"w{side}BattleStatus3") & 0x30 == 0x10
            call(item)
            assert get(f"w{side}BattleStatus3") & 0x30 == 0x20
            call("FocusEnergyEffect_")
            assert get(f"w{side}BattleStatus3") & 0x30 == 0x30
            item_uses = visits["PrintItemUseTextAndRemoveItem"] + visits["AIPrintItemUse"]
            call(item)
            assert visits["PrintItemUseTextAndRemoveItem"] + visits["AIPrintItemUse"] == item_uses
            failures = visits["PrintButItFailedText_"]
            call("FocusEnergyEffect_")
            assert visits["PrintButItFailedText_"] == failures + 1
            assert get(f"w{side}BattleStatus3") & 0x30 == 0x30
        put("wIsInBattle", 0)
        call("ItemUseDireHit")
        assert visits["ItemUseNotTime"] == 1

        # Actual initialization must clear both counters.
        put("wCurMap", 0)
        call("InitBattleVariables")
        for side in ("Player", "Enemy"):
            assert get(f"w{side}BattleStatus2") == 0
            assert get(f"w{side}BattleStatus3") == 0

        # Execute the actual five status-reset writes at each send-out site.
        # Temporarily return immediately after them to avoid send-out UI.
        for side, minimum_sites in (("Player", 1), ("Enemy", 2)):
            start = addr(f"w{side}StatsToDouble")
            pattern = bytes([0x21, start & 255, start >> 8, 0x22, 0x22, 0x22, 0x22, 0x77])
            found = 0
            position = 0
            while (position := rom.find(pattern, position)) != -1:
                bank = position // 0x4000
                address = position if not bank else 0x4000 + position % 0x4000
                key = f"test-reset-{side}-{found}"
                syms[key] = (bank, address)
                end = address + len(pattern)
                original_end = game.memory[bank, end]
                game.memory[bank, end] = 0xc9
                put(f"w{side}BattleStatus2", 255)
                put(f"w{side}BattleStatus3", 255)
                call(key, A=0)
                assert get(f"w{side}BattleStatus2") == get(f"w{side}BattleStatus3") == 0
                game.memory[bank, end] = original_end
                found += 1
                position += len(pattern)
            assert found >= minimum_sites, (side, found)

        # Test arithmetic independently of header lookup, which the species
        # suite tests against all 172 actual headers. No on-disk ROM is edited.
        patch("GetMonHeader", [0xc9])
        patch("BattleRandom", [0x3e, 0, 0xc9])
        moves = ((33, False), (2, True), (75, True), (152, True), (163, True))
        cases = 0
        for side, turn in (("Player", 0), ("Enemy", 1)):
            game.memory[0xfff3] = turn
            for stage in range(4):
                patch("BattleRandom", [0x3e, 0, 0xc9])
                put(f"w{side}BattleStatus2", 4 if stage else 0)
                put(f"w{side}BattleStatus3", stage << 4)
                put(f"w{side}MoveEffect", 0)
                put(f"w{side}MovePower", 50)
                for move, high in moves:
                    put(f"w{side}MoveNum", move)
                    for speed in range(256):
                        put("wMonHBaseSpeed", speed)
                        call("CriticalHitTest")
                        expected = min(255, (speed // 2) * (stage + 1) * (2 if high else 1))
                        assert game.register_file.B == expected, (side, stage, move, speed, game.register_file.B, expected)
                        assert get("wCriticalHitOrOHKO") == int(expected > 0)
                        cases += 1
                # Exhaust the whole RNG range for a normal and a high-crit move.
                for move, high in (moves[0], moves[-1]):
                    put(f"w{side}MoveNum", move)
                    put("wMonHBaseSpeed", 100)
                    count = 0
                    for rng in range(256):
                        patch("BattleRandom", [0x3e, rng, 0xc9])
                        call("CriticalHitTest")
                        count += get("wCriticalHitOrOHKO")
                    assert count == min(255, 50 * (stage + 1) * (2 if high else 1))
                # Status and fixed-damage moves still cannot critically hit.
                patch("BattleRandom", [0x3e, 0, 0xc9])
                put(f"w{side}MovePower", 0)
                call("CriticalHitTest")
                assert get("wCriticalHitOrOHKO") == 0
                put(f"w{side}MovePower", 50)
                put(f"w{side}MoveEffect", 0x29)
                call("CriticalHitTest")
                assert get("wCriticalHitOrOHKO") == 0
        restore("GetMonHeader")
        restore("BattleRandom")
    finally:
        game.stop(save=False)
    print(f"{version}: {cases} crit thresholds, exhaustive RNG counts, mixed Focus/Dire Hit stacking and cap, both sides, Haze and send-out/init resets passed")


if __name__ == "__main__":
    for version in ("pokered", "pokeblue"):
        validate(version)
