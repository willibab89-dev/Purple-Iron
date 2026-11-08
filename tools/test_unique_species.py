#!/usr/bin/env python3
"""Validate species tables and execute their engine routines in headless PyBoy.

Run after make red blue. Requires pyboy==2.9.0.
The routine harness overrides only in-memory ROM entry bytes; files are unchanged.
"""
import json
from pathlib import Path
import re

from pyboy import PyBoy
from generate_unique_encounters import pools, render, habitat_tables

ROOT = Path(__file__).resolve().parents[1]
TYPES = {name: int(value, 16) for name, value in re.findall(r'^(\w+)\s+EQU \$([\dA-F]+)', (ROOT / "constants/type_constants.asm").read_text(), re.M)}
TUNING = {e["name"]:e for e in json.loads((ROOT/"data/species_tuning.json").read_text())}
SPECIES = json.loads((ROOT / "data/unique_species.json").read_text())


def symbols(path):
    result = {}
    for line in path.read_text().splitlines():
        match = re.match(r"([\da-fA-F]+):([\da-fA-F]+) (\S+)", line)
        if match:
            result[match[3]] = (int(match[1], 16), int(match[2], 16))
    return result


def validate(version):
    from test_move_patch_3 import MOVES
    rom_path = ROOT / (version + ".gbc")
    rom = rom_path.read_bytes()
    syms = symbols(ROOT / (version + ".sym"))

    def data(label, size, offset=0):
        bank, address = syms[label]
        start = (bank * 0x4000 + address - 0x4000 if bank else address) + offset
        return rom[start:start + size]

    dex_order = data("PokedexOrder", 190)
    assert sorted(n for n in dex_order if n) == list(range(1, 184))
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
        variant_tuning=next((d for d in TUNING.values() if d["dex"]==entry["dex"]),None)
        assert clone[1:6] == (bytes(variant_tuning["stats"]) if variant_tuning else next((bytes(d["before_stats"]) for d in TUNING.values() if d["dex"]==entry["base_dex"]), source[1:6])), entry["symbol"]
        assert clone[8] == entry.get("catch_rate_override", source[8])
        assert clone[9] == source[9]
        assert clone[15:20] == (bytes([MOVES[m] for m in variant_tuning["start"]]+[0]*(4-len(variant_tuning["start"])))+source[19:20] if variant_tuning else next((bytes([MOVES[m] if m!="0" else 0 for m in d["before_start"]])+source[19:20] for d in TUNING.values() if d["dex"]==entry["base_dex"]), source[15:20]))
        assert clone[27:] == source[27:]
        # Thematic TM rules allow the Rock-type Kakuna variant to differ
        # from its Poison-type source; validate all variant masks explicitly.
        tm_plan = json.loads((ROOT / 'data/tm_distribution.json').read_text())
        expected_tm = next(e['tm_bytes'] for e in tm_plan['entries'] if e['dex'] == entry['dex'])
        assert clone[20:27] == bytes(expected_tm), entry['symbol']
        types = TYPES
        original_types = next((bytes(TYPES[t] for t in e["before"]) for e in json.loads((ROOT/"data/type_changes.json").read_text()) if e["dex"]==entry["base_dex"]), source[6:8])
        expected_types = bytes([types[entry["type_override"]]] * 2) if entry["type_override"] else original_types
        own_type_change=next((e for e in json.loads((ROOT/"data/type_changes.json").read_text()) if e["dex"]==entry["dex"]),None)
        if own_type_change: expected_types=bytes(TYPES[t] for t in own_type_change["after"])
        assert clone[6:8] == expected_types
        for table, width in (("EvosMovesPointerTable", 2), ("PokedexEntryPointers", 2), ("CryData", 3)):
            if table=="EvosMovesPointerTable" and variant_tuning:
                expected_pointer=syms[variant_tuning["title"]+"EvosMoves"][1].to_bytes(2,"little")
                assert data(table,width,(entry["index"]-1)*width)==expected_pointer
            else:
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
                if suffix == "Back":
                    stream = data("CustomBackStreams", 190 * 3, (index - 1) * 3)
                    if stream[0]:
                        bank, pointer = stream[0], stream[1] + 256 * stream[2]
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
                flags = get(field, 23)
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
        owned, seen = get("wPokedexOwned", 23), get("wPokedexSeen", 23)
        call("SaveSAVtoSRAM0")
        for name in ("wPokedexOwned", "wPokedexSeen"):
            start = address(name)
            game.memory[start:start + 23] = [0] * 23
        call("LoadSAV0")
        assert not (game.register_file.F & 0x10), "save checksum failed"
        assert get("wPokedexOwned", 23) == owned
        assert get("wPokedexSeen", 23) == seen
        assert (ROOT / "data/unique_encounters.asm").read_text() == render()
        map_names = re.findall(r"^\s*mapconst\s+(\w+),", (ROOT / "constants/map_constants.asm").read_text(), re.M)
        indexes = {entry["symbol"]: entry["index"] for entry in SPECIES}
        indexes.update({entry["symbol"]: entry["index"] for entry in json.loads((ROOT / "data/new_species.json").read_text())})
        from test_move_patch_3 import constants
        indexes.update(constants(ROOT / "constants/pokemon_constants.asm"))
        habitat_pools = pools("_RED" if version == "pokered" else "_BLUE")
        for species, expected_habitats in (
            ("UNIQUE_OMANYTE_UNIQUE", {("ROCK_TUNNEL_1", 0), ("ROCK_TUNNEL_2", 0)}),
            ("UNIQUE_SQUIRTLE_UNIQUE", {("ROUTE_24", 0), ("ROUTE_25", 0)}),
        ):
            actual = {(map_name, kind) for map_name, kind, entries in habitat_pools
                      if any(name == species for level, name in entries)}
            assert actual == expected_habitats, (species, actual)
        roll_bank, roll_address = syms["UniqueEncounterRoll100"]
        roll_original = list(game.memory[roll_bank, roll_address:roll_address + 3])
        # Exhaust all 100 possible rolls in every eligible map/terrain pool.
        # Two overlapping variants must each occupy exactly one outcome.
        for map_name, kind, variants in habitat_pools:
            put("wCurMap", map_names.index(map_name))
            for roll in range(100):
                game.memory[roll_bank, roll_address:roll_address + 3] = [0x3e, roll, 0xc9]
                call("ChooseUniqueEncounter", B=99, C=kind)
                if roll < len(variants):
                    level, species = variants[roll]
                    assert game.register_file.F & 0x10
                    assert (game.register_file.B, game.register_file.C) == (level, indexes[species])
                else:
                    assert not game.register_file.F & 0x10
                    assert (game.register_file.B, game.register_file.C) == (99, kind)
        # A matching map with an ineligible habitat must never change a mon.
        put("wCurMap", map_names.index("VIRIDIAN_FOREST"))
        call("ChooseUniqueEncounter", B=99, C=1)
        assert not game.register_file.F & 0x10
        assert (game.register_file.B, game.register_file.C) == (99, 1)
        # Both real encounter wrappers must write the fields their callers use.
        game.memory[roll_bank, roll_address:roll_address + 3] = [0x3e, 0, 0xc9]
        tile = address("wTileMap") + 9 * 20 + 9
        game.memory[tile] = 0
        call("TryUniqueWildEncounter")
        assert get("wcf91")[0] == indexes["UNIQUE_BULBASAUR_UNIQUE"]
        assert get("wEnemyMonSpecies2")[0] == indexes["UNIQUE_BULBASAUR_UNIQUE"]
        put("wCurMap", map_names.index("ROUTE_12"))
        for rod, kind in ((0x4d, 2), (0x4e, 3)):
            put("wcf91", rod)
            put("wCurOpponent", 1)
            expected = next(entries[0] for map_name, habitat, entries in habitat_pools if map_name == "ROUTE_12" and habitat == kind)
            call("TryUniqueFishingEncounter")
            assert get("wCurEnemyLVL")[0] == expected[0]
            assert get("wCurOpponent")[0] == indexes[expected[1]]
            assert get("wcf91")[0] == rod, "preserve the active rod item"
        put("wcf91", 0x4c)
        put("wCurOpponent", 133)  # original Magikarp internal ID
        call("TryUniqueFishingEncounter")
        assert get("wCurOpponent")[0] == 133
        game.memory[roll_bank, roll_address:roll_address + 3] = roll_original
        # Validate the real unbiased random reducer: each output has two
        # accepted byte inputs, and a 200 input is rejected then retried.
        random_bank, random_address = syms["Random"]
        random_original = list(game.memory[random_bank, random_address:random_address + 6])
        for byte in range(200):
            game.memory[random_bank, random_address:random_address + 3] = [0x3e, byte, 0xc9]
            call("UniqueEncounterRoll100")
            assert game.register_file.A == byte % 100
        # Incrementing test RNG emits 200..255, then 0; all high bytes must be rejected.
        saved_scratch = game.memory[0xff80]
        game.memory[0xff80] = 199
        game.memory[random_bank, random_address:random_address + 6] = [0xf0, 0x80, 0x3c, 0xe0, 0x80, 0xc9]
        call("UniqueEncounterRoll100")
        assert game.register_file.A == 0 and game.memory[0xff80] == 0
        game.memory[0xff80] = saved_scratch
        game.memory[random_bank, random_address:random_address + 6] = random_original
        # AREA merges pool, ordinary grass/surf and Super Rod habitats.
        expected_locations = {}
        for map_name, kind, variants in habitat_pools:
            for level, species in variants:
                expected_locations.setdefault(species, set()).add(map_names.index(map_name))
        tables = habitat_tables("_RED" if version == "pokered" else "_BLUE")
        pointers = re.findall(r"^\s*dw\s+(\w+)", (ROOT / "data/wild_mons.asm").read_text().split("INCLUDE")[0], re.M)
        for map_id, pointer in enumerate(pointers):
            for habitat in tables[pointer]:
                for level, species in habitat:
                    if species in expected_locations:
                        expected_locations[species].add(map_id)
        fish = (ROOT / "data/super_rod.asm").read_text()
        fish_maps = re.findall(r"dbw\s+(\w+),\s*(\w+)", fish)
        for group, body in re.findall(r"(FishingGroup\d+):([^:]*)(?=FishingGroup\d+:|\Z)", fish):
            for level, species in re.findall(r"db\s+(\d+),\s*(\w+)", body):
                if species in expected_locations:
                    expected_locations[species].update(map_names.index(m) for m, g in fish_maps if g == group)
        for species, expected_maps in expected_locations.items():
            put("wd11e", indexes[species])
            call("FindWildLocationsOfMon")
            raw = get("wBuffer", len(expected_maps) + 1)
            assert raw[-1] == 255 and set(raw[:-1]) == expected_maps
    finally:
        game.stop(save=False)
    print(f"{version}: 183 dex/header round-trips, 42 sprite decodes, 21 party additions, expanded save/load; all 100 rolls in {len(habitat_pools)} encounter pools and AREA maps passed")


if __name__ == "__main__":
    for version in ("pokered", "pokeblue"):
        validate(version)
