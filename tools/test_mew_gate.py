#!/usr/bin/env python3
"""Check the diploma gate through real encounter selection and enemy loading."""
import re
from pyboy import PyBoy
from test_unique_species import ROOT, symbols
from test_move_patch_3 import constants


def validate(version):
    syms=symbols(ROOT/(version+'.sym'));rom=(ROOT/(version+'.gbc')).read_bytes()
    mons=constants(ROOT/'constants/pokemon_constants.asm')
    maps=re.findall(r'^\s*mapconst\s+(\w+),',(ROOT/'constants/map_constants.asm').read_text(),re.M)
    game=PyBoy(str(ROOT/(version+'.gbc')),window='null',sound_emulated=False)
    game.set_emulation_speed(0);game.tick(90,False)
    def addr(n):return syms[n][1]
    def put(n,v):game.memory[addr(n)]=v
    def get(n):return game.memory[addr(n)]
    def data(n,size):
        b,a=syms[n];p=b*16384+a-16384 if b else a;return rom[p:p+size]
    def patch(n,code):
        b,a=syms[n];game.memory[b,a:a+len(code)]=code
    def call(n):
        b,a=syms[n];game.memory[0x2000]=game.memory[0xffb8]=b or 1
        game.memory[0,0x100:0x108]=[0xf3,0xcd,a&255,a>>8,0xc3,4,1,0]
        game.memory[0xffff]=game.memory[0xff0f]=0
        game.register_file.SP=0xdffe;game.register_file.PC=0x100
        for _ in range(120):
            game.tick(1,False)
            if game.register_file.PC in (0x104,0x105,0x106):return
        raise AssertionError((version,n,hex(game.register_file.PC)))
    def init(diploma):
        game.memory[addr('wEventFlags'):addr('wEventFlags')+320]=[0]*320
        # Champion beaten, with or without the separately granted diploma.
        game.memory[addr('wEventFlags')+0x908//8]=1|(8 if diploma else 0)
        for n in ('wIsInBattle','wLinkState','wNPCMovementScriptPointerTableNum','wd736','wRepelRemainingSteps','wEnemyBattleStatus3','wOptions','wFontLoaded'):
            put(n,0)
        put('wCurMap',maps.index('UNKNOWN_DUNGEON_3'))
        put('wPartyMon1Level',50);put('wCurEnemyLVL',70)
    try:
        # Stub only map-edge checks and control the custom replacement RNG.
        # Actual slot selection, DisallowMew and LoadEnemyMonData execute.
        patch('IsPlayerStandingOnDoorTileOrWarpTile',[0xaf,0xc9])
        patch('IsPlayerJustOutsideMap',[0x3e,1,0xa7,0xc9])
        label=(ROOT/'data/wildPokemon/unknowndungeonb1.asm').read_text().split(':',1)[0]
        raw=data(label,21);assert raw[-1]==mons['MEW'] and raw[-2]==70
        for diploma in (False,True):
            init(diploma);patch('Random',[0x3e,99,0xc9])
            put('wGrassRate',255);put('wGrassTile',1)
            game.memory[addr('wGrassMons'):addr('wGrassMons')+20]=raw[1:21]
            game.memory[addr('wTileMap')+9*20+9]=1
            game.memory[0xffd3]=0;game.memory[0xffd4]=255
            call('TryDoWildEncounter')
            expected=mons['MEW'] if diploma else mons['DITTO']
            assert game.register_file.F&128
            assert get('wcf91')==expected and get('wEnemyMonSpecies2')==expected
            assert get('wCurEnemyLVL')==70
            put('wIsInBattle',1);call('LoadEnemyMonData')
            assert get('wEnemyMonSpecies')==expected and get('wEnemyMonLevel')==70
        # The existing 1% unique-Chansey replacement still wins when rolled.
        init(False);patch('Random',[0x3e,0,0xc9])
        put('wGrassRate',255);put('wGrassTile',1)
        game.memory[addr('wGrassMons'):addr('wGrassMons')+20]=raw[1:21]
        game.memory[addr('wTileMap')+9*20+9]=1
        game.memory[0xffd3]=0;game.memory[0xffd4]=255
        call('TryDoWildEncounter')
        assert get('wcf91')==mons['UNIQUE_CHANSEY_UNIQUE']
        assert get('wEnemyMonSpecies2')==mons['UNIQUE_CHANSEY_UNIQUE']
        # Other species, active wild gates and randomized trainer generation.
        for diploma in (False,True):
            for battle,enemy in ((0,mons['MEW']),(1,mons['MEW']),(2,mons['MEW']),(0,229),(2,229),(255,229)):
                init(diploma);put('wIsInBattle',battle)
                put('wcf91',mons['MEW']);put('wEnemyMonSpecies2',enemy)
                call('DisallowMew')
                assert get('wcf91')==(mons['MEW'] if diploma else mons['DITTO'])
                expected=mons['DITTO'] if not diploma and battle<2 and enemy==mons['MEW'] else enemy
                assert get('wEnemyMonSpecies2')==expected,(diploma,battle,enemy)
                assert get('wCurEnemyLVL')==70
            init(diploma);put('wcf91',mons['PIKACHU']);put('wEnemyMonSpecies2',mons['PIKACHU'])
            call('DisallowMew');assert get('wcf91')==get('wEnemyMonSpecies2')==mons['PIKACHU']
        print(f'{version}: actual Cave Mew slot becomes level-70 Ditto before diploma and Mew afterward; Chansey pool, active-wild states, trainer classes and non-Mew species preserved')
    finally:game.stop(save=False)


if __name__=='__main__':
    for version in ('pokered','pokeblue'):validate(version)
