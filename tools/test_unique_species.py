#!/usr/bin/env python3
"""Validate species tables and execute their engine routines in headless PyBoy.

Run after make red blue. Requires pyboy==2.9.0.
The routine harness overrides only in-memory ROM entry bytes; files are unchanged.
"""
import json
from pathlib import Path
import re

from pyboy import PyBoy

ROOT = Path(__file__).resolve().parents[1]
SPECIES = json.loads((ROOT / "data/unique_species.json").read_text())


def symbols(path):
    result = {}
    for line in path.read_text().splitlines():
        match = re.match(r"([\da-fA-F]+):([\da-fA-F]+) (\S+)", line)
        if match:
            result[match[3]] = (int(match[1], 16), int(match[2], 16))
    return result


def validate(version):
    rom_path = ROOT / (version + ".gbc")
    rom = rom_path.read_bytes()
    syms = symbols(ROOT / (version + ".sym"))

    def data(label, size, offset=0):
        bank, address = syms[label]
        start = (bank * 0x4000 + address - 0x4000 if bank else address) + offset
        return rom[start:start + size]

    dex_order = data("PokedexOrder", 190)
    assert sorted(n for n in dex_order if n) == list(range(1, 173))
    assert len(rom) == 1024 * 1024
    assert (sum(rom) - rom[0x14e] - rom[0x14f]) & 65535 == int.from_bytes(rom[0x14e:0x150], "big")
    header_sum = 0
    for value in rom[0x134:0x14d]:
        header_sum = (header_sum - value - 1) & 255
    assert header_sum == rom[0x14d]
    for entry in SPECIES:
        clone = data("BaseStats", 28, (entry["dex"] - 1) * 28)
        source = data("BaseStats", 28, (entry["base_dex"] - 1) * 28)
        assert clone[0] == entry["dex"]
        assert clone[1:6] == source[1:6], entry["symbol"]
        assert clone[8:10] == source[8:10]
        assert clone[15:] == source[15:]
        types = {"FIGHTING": 1, "POISON": 3, "ROCK": 5}
        expected_types = bytes([types[entry["type_override"]]] * 2) if entry["type_override"] else source[6:8]
        assert clone[6:8] == expected_types
        for table, width in (("EvosMovesPointerTable", 2), ("PokedexEntryPointers", 2), ("CryData", 3)):
            assert data(table, width, (entry["index"] - 1) * width) == data(table, width, (entry["base_index"] - 1) * width)
        assert data("MonsterPalettes", 1, entry["dex"]) == data("MonsterPalettes", 1, entry["base_dex"])
        def icon(dex):
            packed = data("MonPartyData", 1, (dex - 1) // 2)[0]
            return packed >> 4 if dex & 1 else packed & 15
        assert icon(entry["dex"]) == icon(entry["base_dex"])

    game = PyBoy(str(rom_path), window="null", sound_emulated=False)
    game.set_emulation_speed(0)
    game.tick(90, False)

    def address(label):
        return syms[label][1]

    def put(label, value):
        game.memory[address(label)] = value

    def get(label, count=1):
        start = address(label)
        return bytes(game.memory[start:start + count])

    def call(label, **registers):
        bank, target = syms[label]
        game.memory[0x2000] = bank or 1
        game.memory[0xffb8] = bank or 1  # H_LOADEDROMBANK
        # DI; CALL routine; JP return-loop. No real ROM bytes are changed.
        game.memory[0, 0x100:0x108] = [0xf3, 0xcd, target & 255, target >> 8, 0xc3, 0x04, 0x01, 0]
        game.memory[0xffff] = 0
        game.memory[0xff0f] = 0
        game.register_file.SP = 0xdffe
        game.register_file.PC = 0x100
        for name, value in registers.items():
            setattr(game.register_file, name, value)
        for _ in range(120):
            game.tick(1, False)
            if game.register_file.PC in (0x104, 0x105, 0x106):
                return
        raise AssertionError(f"{version}: {label} failed to return; PC={game.register_file.PC:04x}")

    try:
        # Verify every original and new species' index/dex round-trip.
        for index, dex in enumerate(dex_order, 1):
            if not dex:
                continue
            put("wd11e", index)
            call("IndexToPokedex")
            assert get("wd11e")[0] == dex
            call("PokedexToIndex")
            assert get("wd11e")[0] == index
            put("wd0b5", index)
            call("GetMonHeader")
            expected = data("BaseStats", 28, (dex - 1) * 28)
            assert get("wMonHeader", 28) == bytes([index]) + expected[1:]
        for entry in SPECIES:
            index = entry["index"]
            put("wd0b5", index)
            call("GetMonHeader")
            put("wd11e", index)
            call("GetMonName")
            assert get("wcd6d", 10) == data("MonsterNames", 10, (index - 1) * 10)
            # Compare routed decompression against direct decoding of the
            # expected front/back streams, with a Hall of Fame overrun guard.
            for offset, suffix in ((11, "Front"), (13, "Back")):
                game.memory[0x0000] = 10
                game.memory[0x4000] = 0
                guard = address("sHallOfFame")
                game.memory[guard:guard + 32] = [0x5a] * 32
                put("wcf91", index)
                call("UncompressMonSprite", HL=offset)
                routed = get("sSpriteBuffer1", 784)
                assert game.memory[guard:guard + 32] == [0x5a] * 32
                bank, pointer = syms[entry["label"] + "Pic" + suffix]
                put("wSpriteInputPtr", pointer & 255)
                game.memory[address("wSpriteInputPtr") + 1] = pointer >> 8
                call("UncompressSpriteData", A=bank)
                assert routed == get("sSpriteBuffer1", 784)
                assert get("wSpriteWidth")[0] in (32, 40, 48, 56)
                assert get("wSpriteHeight")[0] in (32, 40, 48, 56)
            # A real party insertion exercises stats, moves, PP and extended
            # Pokédex flag writes without the naming UI.
            put("wPartyCount", 0)
            put("wMonDataLocation", 0x80)
            put("wIsInBattle", 0)
            put("wCurEnemyLVL", 30)
            put("wcf91", index)
            put("wNumBagItems", 7)
            call("AddPartyMon")
            assert get("wPartyCount")[0] == 1
            assert get("wPartyMon1")[0] == index
            for field in ("wPokedexOwned", "wPokedexSeen"):
                flags = get(field, 22)
                bit = entry["dex"] - 1
                assert flags[bit // 8] & (1 << (bit % 8))
            assert get("wNumBagItems")[0] == 7
            call("UniqueSpeciesToOriginal", A=index)
            assert game.register_file.A == entry["base_index"]
            for attack_dv in (0, 15):
                call("DetermineMonGender", D=index, E=attack_dv)
                gender = game.register_file.D
                call("DetermineMonGender", D=entry["base_index"], E=attack_dv)
                assert gender == game.register_file.D
        # Save/load both expanded bitfields through the actual SRAM routines.
        owned, seen = get("wPokedexOwned", 22), get("wPokedexSeen", 22)
        call("SaveSAVtoSRAM0")
        for name in ("wPokedexOwned", "wPokedexSeen"):
            start = address(name)
            game.memory[start:start + 22] = [0] * 22
        call("LoadSAV0")
        assert not (game.register_file.F & 0x10), "save checksum failed"
        assert get("wPokedexOwned", 22) == owned
        assert get("wPokedexSeen", 22) == seen
    finally:
        game.stop(save=False)
    print(f"{version}: 172 dex/header round-trips, 42 sprite decodes, 21 party additions, extended flags and SRAM save/load passed")


if __name__ == "__main__":
    for version in ("pokered", "pokeblue"):
        validate(version)
