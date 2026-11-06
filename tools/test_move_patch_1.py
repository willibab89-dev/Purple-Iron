#!/usr/bin/env python3
"""Check the approved move delta and execute move loading/reused hit effects."""
import json
import re
from pyboy import PyBoy
from test_unique_species import ROOT, symbols

PLAN = json.loads((ROOT / 'data/move_patch_1.json').read_text())
EFFECTS = {name: i for i, name in enumerate(re.findall(r'^\s*const (\w+)', (ROOT / 'constants/move_effect_constants.asm').read_text(), re.M))}
TYPES = {name: int(value, 16) for name, value in re.findall(r'^(\w+)\s+EQU \$([\dA-F]+)', (ROOT / 'constants/type_constants.asm').read_text(), re.M)}
CHARMAP = {char: int(value, 16) for char, value in re.findall(r'^charmap "(.)", \$([\dA-Fa-f]+)', (ROOT / 'charmap.asm').read_text(), re.M)}


def validate(version):
    rom = (ROOT / (version + '.gbc')).read_bytes()
    syms = symbols(ROOT / (version + '.sym'))
    def data(label, size):
        bank, address = syms[label]
        offset = bank * 0x4000 + address - 0x4000 if bank else address
        return rom[offset:offset + size]
    changes = {entry['id']: entry for entry in PLAN['changes']}
    patch2 = json.loads((ROOT / 'data/move_patch_2.json').read_text())
    cumulative = {entry['id']: entry['after'] for entry in patch2['changes']}
    patch4 = json.loads((ROOT / 'data/move_patch_4.json').read_text())
    cumulative.update({entry['id']: entry['after'] for entry in patch4['existing_changes']})
    patch5 = json.loads((ROOT / 'data/move_patch_5.json').read_text())
    cumulative.update({entry['id']: entry['after'] for entry in patch5['existing_changes']})
    patch6 = json.loads((ROOT / 'data/move_patch_6.json').read_text())
    cumulative.update({entry['id']: entry['after'] for entry in patch6['existing_changes']})
    patch7=json.loads((ROOT/'data/move_patch_7.json').read_text())
    cumulative.update({x['id']:x['after'] for x in patch7['existing_changes']})
    assert len(changes) == 56
    expected, names = [], bytearray()
    for baseline in PLAN['baseline']:
        entry = changes.get(baseline['id'])
        if entry:
            assert entry['before'] == {k: baseline[k] for k in entry['before']}
        target = entry['after'] if entry else baseline
        target = {**target, **cumulative.get(baseline['id'], {})}
        expected.append(bytes([baseline['id'], EFFECTS[target['effect']], target['power'], TYPES[target['type']], target['accuracy'] * 255 // 100, target['pp']]))
        names.extend(CHARMAP[c] for c in target['name'] + '@')
    assert len(expected) == 165
    assert data('Moves', 165 * 6) == b''.join(expected), version
    assert data('MoveNames', len(names)) == names, version
    crit = data('HighCriticalMoves', 10)
    assert set(crit) == {2, 3, 75, 82, 152, 163, 169, 172, 216, 255}, list(crit)
    game = PyBoy(str(ROOT / (version + '.gbc')), window='null', sound_emulated=False)
    game.set_emulation_speed(0)
    game.tick(90, False)
    def put(name, value):
        game.memory[syms[name][1]] = value
    def call(name):
        bank, target = syms[name]
        game.memory[0x2000] = bank or 1
        game.memory[0xffb8] = bank or 1
        game.memory[0, 0x100:0x108] = [0xf3, 0xcd, target & 255, target >> 8, 0xc3, 4, 1, 0]
        game.memory[0xffff] = game.memory[0xff0f] = 0
        game.register_file.SP = 0xdffe
        game.register_file.PC = 0x100
        for _ in range(120):
            game.tick(1, False)
            if game.register_file.PC in (0x104, 0x105, 0x106):
                return
        raise AssertionError((version, name, hex(game.register_file.PC)))
    try:
        put('wFlags_D733', 0)
        for side, turn in (('Player', 0), ('Enemy', 1)):
            game.memory[0xfff3] = turn
            for move_id in changes:
                put(f'w{side}SelectedMove', move_id)
                call('GetCurrentMove')
                address = syms[f'w{side}MoveNum'][1]
                assert bytes(game.memory[address:address + 6]) == expected[move_id - 1]
            put(f'w{side}BattleStatus1', 0)
            put(f'w{side}MoveEffect', EFFECTS['ATTACK_TWICE_EFFECT'])
            call('TwoToFiveAttacksEffect')
            for suffix in ('NumHits', 'NumAttacksLeft'):
                assert game.memory[syms[f'w{side}{suffix}'][1]] == 2
    finally:
        game.stop(save=False)
    print(f'{version}: all 165 move records/names; 56 changes loaded on both sides; fixed two-hit effect; high-crit membership verified')


if __name__ == '__main__':
    for version in ('pokered', 'pokeblue'):
        validate(version)
