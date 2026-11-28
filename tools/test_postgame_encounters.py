#!/usr/bin/env python3
"""Check post-Hall-of-Fame encounters through the actual wild encounter path."""
import re
from pyboy import PyBoy
from test_unique_species import ROOT, symbols
from test_move_patch_3 import constants
from generate_unique_encounters import habitat_tables, pools

ROWS = [
    ('ROUTE_20',1,55,'UNIQUE_BLASTOISE_UNIQUE'),
    ('MANSION_3',0,50,'UNIQUE_GRIMER_POISON'),
    ('ROUTE_12',0,50,'UNIQUE_IVYSAUR_ERIKA'),
    ('ROUTE_22',0,55,'UNIQUE_NIDOKING_UNIQUE'),
    ('ROCK_TUNNEL_1',0,50,'UNIQUE_ONIX_BROCK'),
    ('POWER_PLANT',0,55,'UNIQUE_RAICHU_UNIQUE'),
    ('ROUTE_15',0,50,'UNIQUE_TANGELA_ERIKA'),
    ('ROUTE_13',0,55,'UNIQUE_VENUSAUR_ERIKA'),
]

def validate(version):
    syms=symbols(ROOT/(version+'.sym')); mons=constants(ROOT/'constants/pokemon_constants.asm')
    variant_names={row[3] for row in ROWS}; ver='_RED' if version=='pokered' else '_BLUE'
    assert not any(species in variant_names for _,_,pool in pools(ver) for _,species in pool)
    assert not any(species in variant_names for table in habitat_tables(ver).values() for habitat in table for _,species in habitat)
    maps=re.findall(r'^\s*mapconst\s+(\w+),',(ROOT/'constants/map_constants.asm').read_text(),re.M)
    game=PyBoy(str(ROOT/(version+'.gbc')),window='null',sound_emulated=False)
    game.set_emulation_speed(0);game.tick(90,False)
    def addr(name):return syms[name][1]
    def put(name,v):game.memory[addr(name)]=v
    def get(name):return game.memory[addr(name)]
    def patch(name,code):
        b,a=syms[name];game.memory[b,a:a+len(code)]=code
    def call(name,**regs):
        b,a=syms[name];game.memory[0x2000]=game.memory[0xffb8]=b or 1
        game.memory[0,0x100:0x108]=[0xf3,0xcd,a&255,a>>8,0xc3,4,1,0]
        game.memory[0xffff]=game.memory[0xff0f]=0;game.register_file.SP=0xdffe;game.register_file.PC=0x100
        for k,v in regs.items():setattr(game.register_file,k,v)
        for _ in range(120):
            game.tick(1,False)
            if game.register_file.PC in (0x104,0x105,0x106):return
        raise AssertionError((version,name,hex(game.register_file.PC)))
    try:
        game.memory[addr('wEventFlags'):addr('wEventFlags')+320]=[0]*320
        for n in ('wIsInBattle','wLinkState','wNPCMovementScriptPointerTableNum','wd736','wRepelRemainingSteps','wEnemyBattleStatus3','wOptions','wFontLoaded','wPartyCount'):
            put(n,0)
        patch('IsPlayerStandingOnDoorTileOrWarpTile',[0xaf,0xc9])
        patch('IsPlayerJustOutsideMap',[0x3e,1,0xa7,0xc9])
        put('wGrassRate',255);put('wWaterRate',255);put('wGrassTile',1)
        game.memory[0xffd3]=0;game.memory[0xffd4]=0
        gate=addr('wEventFlags')+0x121 # EVENT_908, bit 0
        for map_name,kind,level,species in ROWS:
            put('wCurMap',maps.index(map_name));put('wd11e',mons[species])
            game.memory[addr('wTileMap')+9*20+9]=0x14 if kind else 1
            ptr=addr('wWaterMons' if kind else 'wGrassMons')
            game.memory[ptr:ptr+20]=[10,mons['PIDGEY']]*10
            game.memory[gate]&=0xfe
            patch('Random',[0x3e,0,0xc9]);call('TryDoWildEncounter')
            assert get('wEnemyMonSpecies2')!=mons[species],(version,map_name,'pre-Hall of Fame')
            call('FindUniqueWildLocations');assert not(game.register_file.F&16),(version,species,'hidden location before Hall of Fame')
            game.memory[gate]|=1
            call('FindUniqueWildLocations');assert game.register_file.F&16,(version,species,'location missing')
            assert list(game.memory[addr('wBuffer'):addr('wBuffer')+2])==[maps.index(map_name),255]
            for roll in range(100):
                patch('Random',[0x3e,roll,0xc9]);call('TryDoWildEncounter')
                if roll<3:
                    assert (get('wEnemyMonSpecies2'),get('wCurEnemyLVL'),get('wcf91'))==(mons[species],level,mons[species]),(version,map_name,roll,'encounter')
                else:
                    assert get('wEnemyMonSpecies2')!=mons[species],(version,map_name,roll,'unexpected encounter')
            # A different habitat on the same map cannot select the variant.
            put('wCurMap',maps.index(map_name));patch('Random',[0x3e,0,0xc9]);call('ChoosePostgameUniqueEncounter',C=kind^1)
            assert not(game.register_file.F&16),(version,map_name,'wrong habitat')
        # The existing Hall of Fame event survives the game's SRAM round-trip.
        game.memory[gate]|=1;put('wNumBagItems',0);put('wBagItems',255)
        call('SaveSAVtoSRAM0');call('SaveSAVtoSRAM2');game.memory[gate]&=0xfe
        call('LoadSAV0');call('LoadSAV2');assert game.memory[gate]&1,(version,'postgame flag save/load')
        put('wCurMap',maps.index('ROUTE_22'));patch('Random',[0x3e,0,0xc9])
        call('ChoosePostgameUniqueEncounter',C=0)
        assert game.register_file.F&16 and game.register_file.C==mons['UNIQUE_NIDOKING_UNIQUE'],(version,'postgame encounter after reload')
        print(f'{version}: all eight variants gated until Hall of Fame, 3/100 actual wild rolls, habitat, level and Pokédex AREA passed')
    finally:game.stop(save=False)

if __name__=='__main__':
    for version in ('pokered','pokeblue'):validate(version)
