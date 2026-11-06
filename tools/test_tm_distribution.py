#!/usr/bin/env python3
"""Check the bounded TM data delta and real item compatibility on both ROMs."""
import json
from pyboy import PyBoy
from test_unique_species import ROOT, symbols, TUNING
from test_move_patch_1 import TYPES
TYPE_CHANGES={e["dex"]:e for e in json.loads((ROOT/"data/type_changes.json").read_text())}

PLAN = json.loads((ROOT / 'data/tm_distribution.json').read_text())


def validate(version):
    from test_move_patch_3 import MOVES
    rom = (ROOT / (version + '.gbc')).read_bytes()
    syms = symbols(ROOT / (version + '.sym'))
    def data(label, size):
        bank, address = syms[label]
        offset = bank * 0x4000 + address - 0x4000 if bank else address
        return rom[offset:offset + size]
    headers = data('BaseStats', 28 * len(PLAN['entries']))
    reviewed = set(PLAN['reviewed_tms'])
    assert reviewed == {6, 9, 10, 20, 31, 32, 34, 50}
    for entry, old_hex in zip(PLAN['entries'], PLAN['baseline_headers']):
        old = bytes.fromhex(old_hex)
        expected = old[:20] + bytes(entry['tm_bytes']) + old[27:]
        if entry['dex'] in TYPE_CHANGES:
            expected=expected[:6]+bytes(TYPES[t] for t in TYPE_CHANGES[entry['dex']]['after'])+expected[8:]
        tuning=TUNING.get(entry['name'])
        if tuning:
            starts=bytes([MOVES[m] for m in tuning['start']]+[0]*(4-len(tuning['start'])))
            expected=expected[:1]+bytes(tuning['stats'])+expected[6:15]+starts+expected[19:]
        actual = headers[(entry['dex'] - 1) * 28:entry['dex'] * 28]
        assert actual == expected, entry['name']
        assert (set(entry['new']) ^ set(entry['old'])) <= reviewed | set(tuning['remove'] if tuning else []), entry['name']
        assert (44 in entry['new']) == (44 in entry['old']), entry['name']
        assert {n for n in entry['new'] if n > 50} == {n for n in entry['old'] if n > 50}
    entries = {e['name']: e for e in PLAN['entries']}
    assert set(range(1, 56)) <= set(entries['mew']['new'])
    for entry in PLAN['entries']:
        if 151 < entry['dex'] <= 172 and entry['name'] != 'kakuna_rock_type':
            if entry['source'] not in TUNING:
                assert entry['new'] == entries[entry['source']]['new'], entry['name']
    assert 6 in entries['kakuna']['new'] and 6 not in entries['kakuna_rock_type']['new']
    assert 6 in entries['paras']['new'] and 6 in entries['parasect']['new']
    assert 32 in entries['electrode']['new'] and 32 not in entries['snorlax']['new']
    assert 20 in entries['primeape']['new'] and 20 not in entries['chansey']['new']
    assert 31 in entries['mrmime']['new'] and 31 not in entries['tauros']['new']
    game = PyBoy(str(ROOT / (version + '.gbc')), window='null', sound_emulated=False)
    game.set_emulation_speed(0)
    game.tick(90, False)
    def addr(n): return syms[n][1]
    def call(n):
        bank, address = syms[n]
        game.memory[0x2000] = game.memory[0xffb8] = bank or 1
        game.memory[0, 0x100:0x108] = [0xf3, 0xcd, address & 255, address >> 8, 0xc3, 4, 1, 0]
        game.memory[0xffff] = game.memory[0xff0f] = 0
        game.register_file.SP = 0xdffe
        game.register_file.PC = 0x100
        for _ in range(30):
            game.tick(1, False)
            if game.register_file.PC in (0x104, 0x105, 0x106): return
        raise AssertionError((version, n, hex(game.register_file.PC)))
    try:
        order = data('PokedexOrder', 190)
        machines = data('TechnicalMachines', 55)
        calls = 0
        for entry in PLAN['entries']:
            index = order.index(entry['dex']) + 1
            # All nine reviewed/preserved TMs plus the five HMs through the
            # game's actual CanLearnTM/GetMonHeader/FlagAction path.
            for tm in sorted(reviewed | {44} | set(range(51, 56))):
                game.memory[addr('wcf91')] = index
                game.memory[addr('wMoveNum')] = machines[tm - 1]
                call('CanLearnTM')
                assert bool(game.register_file.C) == (tm in entry['new']), (entry['name'], tm)
                calls += 1
        print(f'{version}: all {len(PLAN['entries'])} headers bounded to eight TM bits; Rest/HMs/other TMs preserved; {calls} real compatibility checks passed')
    finally:
        game.stop(save=False)


if __name__ == '__main__':
    for name in ('pokered', 'pokeblue'):
        validate(name)
