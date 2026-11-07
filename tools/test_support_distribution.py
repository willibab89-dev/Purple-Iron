#!/usr/bin/env python3
"""Check real level-up offers and the Eevee-only Charm relearner restriction."""
from pyboy import PyBoy
from test_unique_species import ROOT, symbols
from test_move_patch_3 import MOVES


def validate(version):
    syms = symbols(ROOT/(version+'.sym'))
    game = PyBoy(str(ROOT/(version+'.gbc')), window='null', sound_emulated=False)
    game.set_emulation_speed(0)
    game.tick(90, False)
    def addr(n): return syms[n][1]
    def put(n, v): game.memory[addr(n)] = v
    def get(n, size=1): return bytes(game.memory[addr(n):addr(n)+size])
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
    bank, start = syms['PokedexOrder']
    order = bytes(game.memory[bank, start:start+190])
    def mon(dex, level):
        index = order.index(dex)+1
        put('wPartyCount', 0)
        put('wIsInBattle', 0)
        put('wMonDataLocation', 0x80)
        put('wcf91', index)
        put('wCurEnemyLVL', level)
        call('AddPartyMon')
        put('wWhichPokemon', 0)
        game.memory[addr('wPartyMon1Moves'):addr('wPartyMon1Moves')+4] = [MOVES['TACKLE'], 0, 0, 0]
        put('wMonDataLocation', 0)
        put('wd11e', index)
        return index
    def relearn(dex, level):
        mon(dex, level)
        call('PrepareRelearnableMoveList')
        return get('wMoveBuffer', 1+get('wMoveBuffer')[0])[1:]
    try:
        # Keep real learning and PP writes; suppress presentation only. An
        # empty slot avoids the interactive replace-move menu.
        for n in ('PrintText', 'SaveScreenTilesToBuffer1'):
            bank, target = syms[n]
            game.memory[bank, target] = 0xc9
        for dex, level, move in [(133,40,'CHARM'),(124,25,'ICE_PUNCH'),(124,26,'CHARM'),(40,49,'HEAL_BELL'),(131,45,'HEAL_BELL'),(53,27,'SNARL'),(58,28,'SNARL'),(59,28,'SNARL')]:
            mon(dex, level)
            call('LearnMoveFromLevelUp')
            assert get('wPartyMon1Moves', 4)[1] == MOVES[move], (dex, level, move)
            expected_pp = {'CHARM':20,'ICE_PUNCH':15,'HEAL_BELL':5,'SNARL':15}[move]
            assert get('wPartyMon1PP', 4)[1] == expected_pp, (dex, level, move)
        assert MOVES['CHARM'] not in relearn(133,39)
        assert MOVES['CHARM'] in relearn(133,40)
        for dex in (134,135,136):
            assert MOVES['CHARM'] not in relearn(dex,100), dex
        assert MOVES['ICE_PUNCH'] in relearn(124,25)
        assert MOVES['CHARM'] not in relearn(124,25)
        assert MOVES['CHARM'] in relearn(124,26)
        print(f'{version}: eight live level-up/PP cases, Eevee 39/40 boundary, evolved Charm exclusion and separate Jynx 25/26 moves passed')
    finally:
        game.stop(save=False)


if __name__ == '__main__':
    for version in ('pokered','pokeblue'): validate(version)
