#!/usr/bin/env python3
"""Verify shared type chart behavior in actual damage and AI on both sides."""
from pyboy import PyBoy
from test_unique_species import ROOT, symbols
import re


def validate(version):
    syms = symbols(ROOT / (version + '.sym'))
    source = (ROOT / 'constants/type_constants.asm').read_text()
    types = {name: int(value, 16) for name, value in re.findall(r'^(\w+)\s+EQU \$(\w+)', source, re.M)}
    game = PyBoy(str(ROOT / (version + '.gbc')), window='null', sound_emulated=False)
    game.set_emulation_speed(0)
    game.tick(90, False)
    def addr(n): return 0xfff3 if n == 'H_WHOSETURN' else syms[n][1]
    def put(n, v): game.memory[addr(n)] = v
    def call(n):
        bank, target = syms[n]
        game.memory[0x2000] = game.memory[0xffb8] = bank or 1
        game.memory[0, 0x100:0x108] = [0xf3, 0xcd, target & 255, target >> 8, 0xc3, 4, 1, 0]
        game.memory[0xffff] = game.memory[0xff0f] = 0
        game.register_file.SP = 0xdffe
        game.register_file.PC = 0x100
        for _ in range(120):
            game.tick(1, False)
            if game.register_file.PC in (0x104, 0x105, 0x106): return
        raise AssertionError((version, n, hex(game.register_file.PC)))
    cases = [
        ('GROUND', 'ICE', 'ICE', 5),
        ('GROUND', 'WATER', 'ICE', 5),
        ('GROUND', 'ICE', 'WATER', 5),
        ('GROUND', 'ICE', 'PSYCHIC', 5),
        ('GROUND', 'ICE', 'FLYING', 0),
        ('GROUND', 'FLYING', 'ICE', 0),
        ('POISON', 'BUG', 'BUG', 10),
        ('POISON', 'BUG', 'FLYING', 10),
        ('POISON', 'BUG', 'POISON', 5),
        ('POISON', 'BUG', 'GRASS', 20),
        ('POISON', 'BUG', 'GHOST', 5),
        ('POISON', 'GHOST', 'BUG', 5),
        ('FLYING', 'ICE', 'ICE', 10),
        ('BUG', 'POISON', 'POISON', 20),
        ('GROUND', 'FIRE', 'POISON', 40),
        ('ROCK', 'ICE', 'FLYING', 40),
    ]
    try:
        for turn in (0, 1):
            for attack, type1, type2, multiplier in cases:
                attacker, defender = ('wEnemyMon', 'wBattleMon') if turn else ('wBattleMon', 'wEnemyMon')
                for prefix, pair in ((attacker, ('NORMAL', 'NORMAL')), (defender, (type1, type2))):
                    game.memory[addr(prefix+'Type'):addr(prefix+'Type')+2] = [types[t] for t in pair]
                put('H_WHOSETURN', turn)
                for side in ('Player', 'Enemy'): put('w'+side+'MoveType', types[attack])
                put('wUnusedC000', 0)
                put('wDamageMultipliers', 10)
                game.memory[addr('wDamage'):addr('wDamage')+2] = [0, 100]
                call('AdjustDamageForMoveType')
                damage = game.memory[addr('wDamage')]*256+game.memory[addr('wDamage')+1]
                assert damage == multiplier*10, (version, turn, attack, type1, type2, damage)
                assert game.memory[addr('wDamageMultipliers')] == multiplier
                # AI has an explicit selector for evaluating the player's attack.
                put('wUnusedC000', 8 if turn == 0 else 0)
                call('AIGetTypeEffectiveness')
                assert game.memory[addr('wTypeEffectiveness')] == multiplier, (version, 'AI', turn, attack, type1, type2)
        print(f'{version}: {len(cases)*2} damage/message and AI matchup cases passed, including dual types, immunity and unchanged matchups')
    finally:
        game.stop(save=False)


if __name__ == '__main__':
    for version in ('pokered', 'pokeblue'): validate(version)
