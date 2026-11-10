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
    def mon(dex, level, reset_moves=True):
        index = order.index(dex)+1
        put('wPartyCount', 0)
        put('wIsInBattle', 0)
        put('wMonDataLocation', 0x80)
        put('wcf91', index)
        put('wCurEnemyLVL', level)
        call('AddPartyMon')
        put('wWhichPokemon', 0)
        if reset_moves: game.memory[addr('wPartyMon1Moves'):addr('wPartyMon1Moves')+4] = [MOVES['TACKLE'], 0, 0, 0]
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
        # Ability-preparation additions: real learning and PP writes, not just table reads.
        additions=[(68,36,'DOUBLESLAP'),(68,49,'TRIPLE_KICK'),(68,56,'PIERCE'),(68,63,'MEGA_KICK'),
                   (62,35,'FIRE_PUNCH'),(62,41,'ICE_PUNCH'),(62,47,'THUNDERPUNCH'),(62,54,'HYDRO_PUMP'),(62,60,'SUBMISSION'),
                   (69,10,'ACID'),(69,25,'SLUDGE'),(70,10,'ACID'),(70,25,'SLUDGE'),(71,25,'SLUDGE'),
                   (90,20,'ICICLE_SPEAR'),(91,20,'ICICLE_SPEAR'),(84,12,'BITE'),(85,12,'BITE'),(95,25,'DIG'),
                   (96,22,'MUD_WAVE'),(97,22,'MUD_WAVE'),(102,25,'MEGA_DRAIN'),(103,25,'MEGA_DRAIN'),
                   (104,30,'TAKE_DOWN'),(105,30,'TAKE_DOWN'),(122,18,'DOUBLESLAP'),(126,21,'WILL_O_WISP'),
                   (127,17,'LUNGE'),(127,41,'X_SCISSOR'),(127,57,'BULK_UP'),(127,65,'GUILLOTINE'),
                   (140,29,'SLASH'),(141,29,'SLASH')]
        mb,ma=syms['Moves']
        for dex,level,move in additions:
            mon(dex,level);call('LearnMoveFromLevelUp')
            assert get('wPartyMon1Moves',4)[1]==MOVES[move],(dex,level,move)
            assert get('wPartyMon1PP',4)[1]==game.memory[mb,ma+(MOVES[move]-1)*6+5],(dex,level,'PP')
            assert MOVES[move] in relearn(dex,level),(dex,level,'relearn')
            if (dex,move)!=(68,'DOUBLESLAP'):
                assert MOVES[move] not in relearn(dex,level-1),(dex,level,'early relearn')
        # Creation uses the same native move initialization as fossil revival.
        for level in (1,5,20,30):
            mon(142,level,False)
            assert MOVES['TAKE_DOWN'] in get('wPartyMon1Moves',4),('Aerodactyl creation',level)
        mon(68,1,False);assert MOVES['DOUBLESLAP'] in get('wPartyMon1Moves',4)
        print(f'{version}: existing support/Charm cases; {len(additions)} live ability-preparation level-up/PP/relearner boundaries; Machamp starting move and Aerodactyl creation at four levels passed')
    finally:
        game.stop(save=False)


if __name__ == '__main__':
    for version in ('pokered','pokeblue'): validate(version)
