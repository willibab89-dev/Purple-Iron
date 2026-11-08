#!/usr/bin/env python3
"""Audit route probabilities and execute compiled grass/surf selection in PyBoy."""
from collections import Counter
import json
import re
from pyboy import PyBoy
from generate_unique_encounters import ROOT, habitat_tables, pools
from test_unique_species import symbols
from test_move_patch_3 import constants

WEIGHTS = [51, 51, 39, 25, 25, 25, 13, 13, 11, 3]
GRASS_RATES = {1:25, 2:25, 3:20, 4:20, 5:15, 6:15, 7:15, 8:15,
               9:15, 10:15, 11:15, 12:15, 13:20, 14:15, 15:15,
               16:25, 17:25, 18:25, 21:25, 22:25, 23:10, 24:25, 25:15}


def validate(version):
    ver = '_RED' if version == 'pokered' else '_BLUE'
    tables = habitat_tables(ver)
    custom = {(m,k): p for m,k,p in pools(ver)}
    mons = constants(ROOT/'constants/pokemon_constants.asm')
    maps = re.findall(r'^\s*mapconst\s+(\w+),', (ROOT/'constants/map_constants.asm').read_text(), re.M)
    pointers = re.findall(r'^\s*dw\s+(\w+)', (ROOT/'data/wild_mons.asm').read_text().split('INCLUDE')[0], re.M)
    syms = symbols(ROOT/(version+'.sym'))
    rom = (ROOT/(version+'.gbc')).read_bytes()
    def data(label,n):
        bank,addr = syms[label]; offset = bank*16384+addr-16384 if bank else addr
        return rom[offset:offset+n]
    # Read the compiled pointers, activation bytes and both ten-slot tables.
    habitats = []
    for route in range(1,26):
        m = f'ROUTE_{route}'; label = pointers[maps.index(m)]
        ptr = data('WildDataPointers', len(pointers)*2)[maps.index(m)*2:maps.index(m)*2+2]
        assert int.from_bytes(ptr, 'little') == syms[label][1]
        raw = data(label,43); pos = 0
        for kind in range(2):
            rate = raw[pos]; pos += 1
            expected_rate = (GRASS_RATES.get(route,0) if kind == 0 else (5 if route in (19,20,21) else 0))
            assert rate == expected_rate, (version,m,kind,rate,expected_rate)
            if not rate:continue
            rows = tables[label][kind]
            compiled = list(raw[pos:pos+20]); pos += 20
            assert compiled == [v for level,s in rows for v in (int(level),mons[s])]
            habitats.append((m,kind,rows,compiled))
    def distribution(route,kind=0):
        m=f'ROUTE_{route}'; rows=tables[pointers[maps.index(m)]][kind]
        pool=custom.get((m,kind),[]); total=Counter()
        # Enumerate every base byte and unbiased percent outcome: no sampling.
        for weight,(level,species) in zip(WEIGHTS,rows):
            total[species] += weight*(100-len(pool))
        for level,species in pool:total[species]+=256
        assert sum(total.values())==25600
        return {s:n/256 for s,n in total.items()}
    for route,species,low,high in [(1,'MEOWTH',5,5),(2,'PIKACHU',2,2),(4,'CLEFAIRY',2,2),
        (5,'MEOWTH',14,16),(7,'MEOWTH',20,30),(8,'MEOWTH',20,30),
        (7,'PONYTA',5,5),(17,'PONYTA',19,21),(7,'EEVEE',2,2),
        (21,'EEVEE',10,16),(15,'TANGELA',5,5),(21,'TANGELA',15,20),
        (22,'MANKEY',5,5),(24,'PSYDUCK',5,5),(25,'PSYDUCK',5,5),
        (6,'KRABBY',5,5),(9,'CUBONE',5,5),(11,'FARFETCHD',2,2),
        (12,'SLOWPOKE',5,5),(12,'FARFETCHD',4.8,10),(13,'FARFETCHD',5,10),
        (16,'RHYHORN',5,5),(18,'LICKITUNG',5,5),(23,'RHYDON',5,5)]:
        actual=distribution(route).get(species,0)
        assert low<=actual<=high,(version,route,species,actual)
    for route,species in [(19,'HORSEA'),(20,'SHELLDER'),(21,'STARYU')]:
        d=distribution(route,1);assert d[species]==5 and d['UNIQUE_TENTACOOL_BIG']==1
        rows=tables[pointers[maps.index(f'ROUTE_{route}')]][1]
        assert all(20<=int(l)<=35 for l,s in rows)
    # Normal starter finds and approved source-triggered/fixed variants remain.
    for route,s in [(4,'BULBASAUR'),(6,'SQUIRTLE'),(25,'CHARMANDER')]:
        assert distribution(route)[s]>1
    for route in (24,25):assert distribution(route)['UNIQUE_SQUIRTLE_UNIQUE']==1
    for route in (14,15):assert distribution(route)['MILTANK']==2
    assert distribution(22)['UNIQUE_NIDORANM_UNIQUE']==1
    assert all(int(l)>=42 for l,s in custom[('ROUTE_23',0)] if s=='RHYDON')
    assert all(28<=int(l)<=32 for l,s in tables['Route21Mons'][0] if s=='EEVEE')
    # Every existing unique/additional-species rule retains its own full rate.
    rules=json.loads((ROOT/'data/unique_encounter_rules.json').read_text())
    for (m,k),rows in custom.items():
        for rule in rules:
            hits=[pair for pair in rows if pair[1]==rule['species']]
            if hits:assert len(hits)==rule.get('percent',1),(m,k,rule)

    game=PyBoy(str(ROOT/(version+'.gbc')),window='null',sound_emulated=False)
    game.set_emulation_speed(0);game.tick(90,False)
    def addr(n):return syms[n][1]
    def put(n,v):game.memory[addr(n)]=v
    def get(n):return game.memory[addr(n)]
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
    try:
        game.memory[addr('wEventFlags'):addr('wEventFlags')+320]=[0]*320
        for n in ('wIsInBattle','wLinkState','wNPCMovementScriptPointerTableNum','wd736','wRepelRemainingSteps','wEnemyBattleStatus3','wOptions','wFontLoaded'):
            put(n,0)
        patch('IsPlayerStandingOnDoorTileOrWarpTile',[0xaf,0xc9])
        patch('IsPlayerJustOutsideMap',[0x3e,1,0xa7,0xc9])
        put('wGrassRate',255);put('wWaterRate',255);put('wGrassTile',1)
        game.memory[0xffd3]=0
        for m,k,rows,compiled in habitats:
            put('wCurMap',maps.index(m))
            game.memory[addr('wTileMap')+9*20+9]=0x14 if k else 1
            target=addr('wWaterMons' if k else 'wGrassMons')
            game.memory[target:target+20]=compiled
            patch('Random',[0x3e,99,0xc9])
            # Both endpoints of each inclusive base slot, through real selection.
            start=0
            for weight,(level,species) in zip(WEIGHTS,rows):
                for byte in (start,start+weight-1):
                    game.memory[0xffd4]=byte;call('TryDoWildEncounter')
                    assert game.register_file.F&128
                    assert (get('wCurEnemyLVL'),get('wEnemyMonSpecies2'),get('wcf91'))==(int(level),mons[species],mons[species]),(m,k,byte,species)
                start+=weight
            # Full percent rolls through the grass/surf wrapper, including fallback.
            game.memory[0xffd4]=0
            for roll in range(100):
                patch('Random',[0x3e,roll,0xc9]);call('TryDoWildEncounter')
                pool=custom.get((m,k),[])
                level,species=pool[roll] if roll<len(pool) else rows[0]
                assert (get('wCurEnemyLVL'),get('wEnemyMonSpecies2'),get('wcf91'))==(int(level),mons[species],mons[species]),(m,k,roll,species)
    finally:game.stop(save=False)
    print(f'{version}: all 25 routes, exact final odds, unchanged activation rates, slot endpoints and 100 real grass/surf rolls per habitat passed')


if __name__=='__main__':
    for version in ('pokered','pokeblue'):validate(version)
