#!/usr/bin/env python3
"""Test exact thaw probability, status handling, roster sync and move selection."""
from collections import Counter

from pyboy import PyBoy
from test_unique_species import ROOT, symbols


def validate(version):
    syms = symbols(ROOT / (version + ".sym"))
    game = PyBoy(str(ROOT / (version + ".gbc")), window="null", sound_emulated=False)
    game.set_emulation_speed(0)
    game.tick(90, False)
    originals = {}
    visits = Counter()

    def addr(name):
        return syms[name][1]

    def put(name, value):
        game.memory[addr(name)] = value

    def get(name):
        return game.memory[addr(name)]

    def patch(name, code):
        bank, address = syms[name]
        originals.setdefault(name, list(game.memory[bank, address:address + len(code)]))
        game.memory[bank, address:address + len(code)] = code

    def restore(name):
        bank, address = syms[name]
        code = originals.pop(name)
        game.memory[bank, address:address + len(code)] = code

    def call(name, **regs):
        bank, target = syms[name]
        game.memory[0x2000] = bank or 1
        game.memory[0xffb8] = bank or 1
        game.memory[0, 0x100:0x108] = [0xf3, 0xcd, target & 255, target >> 8, 0xc3, 4, 1, 0]
        game.memory[0xffff] = game.memory[0xff0f] = 0
        game.register_file.SP = 0xdffe
        game.register_file.PC = 0x100
        for key, value in regs.items():
            setattr(game.register_file, key, value)
        for _ in range(120):
            game.tick(1, False)
            if game.register_file.PC in (0x104, 0x105, 0x106):
                return
        raise AssertionError((version, name, hex(game.register_file.PC)))

    def clean():
        for side in ("Player", "Enemy"):
            for number in (1, 2, 3):
                put(f"w{side}BattleStatus{number}", 0)
            put(f"w{side}DisabledMove", 0)
            put(f"w{side}DisabledMoveNumber", 0)
            put(f"w{side}SelectedMove", 33)
            put(f"w{side}UsedMove", 33)
        put("wBattleMonStatus", 0)
        put("wEnemyMonStatus", 0)
        put("wIsInBattle", 2)
        put("wPlayerMonNumber", 2)
        put("wEnemyMonPartyPos", 3)
        put("wActionResultOrTookBattleTurn", 0)

    def roster(side):
        first = "wPartyMon1Status" if side == "Player" else "wEnemyMon1Status"
        stride = addr("wPartyMon2") - addr("wPartyMon1") if side == "Player" else addr("wEnemyMon2") - addr("wEnemyMon1")
        return [addr(first) + i * stride for i in range(6)]

    def print_hook(_):
        visits[game.register_file.HL] += 1

    try:
        patch("PrintText", [0xc9])
        bank, location = syms["PrintText"]
        game.hook_register(bank, location, print_hook, None)
        # Every accepted RNG byte is checked: 50 of 250 outcomes thaw exactly.
        clean()
        for side, turn, status_name, party_index, checker in (
            ("Player", 0, "wBattleMonStatus", 2, "CheckPlayerStatusConditions"),
            ("Enemy", 1, "wEnemyMonStatus", 3, "CheckEnemyStatusConditions"),
        ):
            game.memory[0xfff3] = turn
            thawed = 0
            for byte in range(250):
                clean()
                game.memory[0xfff3] = turn
                put(status_name, 0x20)
                party = roster(side)
                for pointer in party:
                    game.memory[pointer] = 0x20
                patch("BattleRandom", [0x3e, byte, 0xc9])
                call(checker)
                expected = byte < 50
                assert get(status_name) == (0 if expected else 0x20)
                assert bool(game.register_file.F & 0x80) == (not expected), "thawed mon must be allowed to act immediately"
                assert [game.memory[p] for p in party] == [0 if expected and i == party_index else 0x20 for i in range(6)]
                assert get(f"w{side}SelectedMove") == 33
                assert get(f"w{side}UsedMove") == (33 if expected else 0)
                thawed += expected
            assert thawed == 50
            # A thaw does not bypass other reasons that prevent moving.
            for blocker in ("flinch", "recharge", "trapped"):
                clean()
                game.memory[0xfff3] = turn
                put(status_name, 0x20)
                patch("BattleRandom", [0x3e, 0, 0xc9])
                if blocker == "flinch":
                    put(f"w{side}BattleStatus1", 1 << 3)
                elif blocker == "recharge":
                    put(f"w{side}BattleStatus2", 1 << 5)
                else:
                    other = "Enemy" if side == "Player" else "Player"
                    put(f"w{other}BattleStatus1", 1 << 5)
                call(checker)
                assert get(status_name) == 0
                assert game.register_file.F & 0x80, blocker
            # Failed thaw attempts preserve forced-move state and PP.
            clean()
            game.memory[0xfff3] = turn
            put(status_name, 0x20)
            put(f"w{side}BattleStatus1", (1 << 4) | (1 << 6))
            pp = "wBattleMonPP" if side == "Player" else "wEnemyMonPP"
            put(pp, 10)
            patch("BattleRandom", [0x3e, 50, 0xc9])
            call(checker)
            assert get(f"w{side}BattleStatus1") == (1 << 4) | (1 << 6)
            assert get(pp) == 10

        # Reject the six high bytes before making the exact 20% decision.
        saved_scratch = game.memory[0xff80]
        game.memory[0xff80] = 249
        # Incrementing RNG returns 250..255, then 0, which must thaw.
        restore("BattleRandom")
        patch("BattleRandom", [0xf0, 0x80, 0x3c, 0xe0, 0x80, 0xc9])
        call("NaturalThawRoll")
        assert game.memory[0xff80] == 0 and game.register_file.F & 0x10
        game.memory[0xff80] = saved_scratch
        restore("BattleRandom")

        # Wild thawing must not touch the trainer's party storage.
        clean()
        game.memory[0xfff3] = 1
        put("wIsInBattle", 1)
        put("wEnemyMonStatus", 0x20)
        for pointer in roster("Enemy"):
            game.memory[pointer] = 0x20
        patch("BattleRandom", [0x3e, 0, 0xc9])
        call("CheckEnemyStatusConditions")
        assert get("wEnemyMonStatus") == 0
        assert all(game.memory[p] == 0x20 for p in roster("Enemy"))

        # Enemy selection must choose a fresh legal move while still frozen.
        clean()
        put("wIsInBattle", 1)
        put("wLinkState", 0)
        put("wEnemyMonStatus", 0x20)
        put("wEnemySelectedMove", 10)
        start = addr("wEnemyMonMoves")
        game.memory[start:start + 4] = [33, 45, 0, 0]
        call("SelectEnemyMove")
        assert get("wEnemySelectedMove") == 33
        assert get("wEnemyMonStatus") == 0x20, "selection must not roll for thaw"

        # Walk the actual player loop to move selection; stop before the
        # enemy's selection so this test doesn't execute a whole UI battle.
        for name in ("ReadPlayerMonCurHPAndStatus", "SaveScreenTilesToBuffer1", "LoadScreenTilesFromBuffer1", "DrawHUDsAndHPBars"):
            patch(name, [0xc9])
        patch("DisplayBattleMenu", [0xaf, 0xc9])  # Fight, no turn used
        selected = addr("wPlayerSelectedMove")
        patch("MoveSelectionMenu", [0x3e, 33, 0xea, selected & 255, selected >> 8, 0xaf, 0xc9])
        patch("SelectEnemyMove", [0xc9])
        bank, location = syms["SelectEnemyMove"]

        def stop_before_enemy(_):
            game.register_file.PC = 0x104
            game.register_file.SP = 0xdffe

        game.hook_register(bank, location, stop_before_enemy, None)
        clean()
        put("wBattleMonStatus", 0x20)
        put("wPlayerSelectedMove", 10)
        put("wEscapedFromBattle", 0)
        put("wBattleMonHP", 1)
        put("wEnemyMonHP", 1)
        call("MainInBattleLoop")
        assert get("wPlayerSelectedMove") == 33, "frozen player skipped fresh move selection"
        assert get("wBattleMonStatus") == 0x20
        assert visits[addr("NaturallyThawedText")] >= 100
    finally:
        game.stop(save=False)
    print(f"{version}: exact 20% thaw, same-turn action, party sync, rejection, frozen-state/PP preservation and fresh player/enemy move selection passed")


if __name__ == "__main__":
    for version in ("pokered", "pokeblue"):
        validate(version)
