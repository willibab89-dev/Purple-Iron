#!/usr/bin/env python3
"""Verify full-size sprite routing and all four new species in both ROMs."""
import hashlib
import json
from collections import Counter
from pathlib import Path
from PIL import Image
from pyboy import PyBoy
from test_unique_species import ROOT, symbols, TUNING
from test_move_patch_3 import MOVES
from test_move_patch_1 import TYPES
from generate_unique_encounters import pools

PLAN=json.loads((ROOT/'data/backsprite_import.json').read_text())
NEW=json.loads((ROOT/'data/new_species.json').read_text())
TYPE_CHANGES={e['dex']:e for e in json.loads((ROOT/'data/type_changes.json').read_text())}


def gb_bytes(path):
    im=path if isinstance(path,Image.Image) else Image.open(path).convert('P')
    values=list(im.getdata());w,h=im.size;out=[]
    for tx in range(w//8):
        for ty in range(h//8):
            for row in range(8):
                pixels=[values[(ty*8+row)*w+tx*8+x] for x in range(8)]
                out += [sum((p&1)<<(7-x) for x,p in enumerate(pixels)),sum(((p>>1)&1)<<(7-x) for x,p in enumerate(pixels))]
    return bytes(out)


def validate(version):
    syms=symbols(ROOT/(version+'.sym'));rom=(ROOT/(version+'.gbc')).read_bytes()
    def addr(n):return syms[n][1]
    def data(n,size,offset=0):
        b,a=syms[n];start=(b*16384+a-16384 if b else a)+offset;return rom[start:start+size]
    for source,digest in PLAN['source_hashes'].items():
        assert hashlib.sha256((ROOT/source).read_bytes()).hexdigest()==digest
    for entry in PLAN['backs']:
        assert hashlib.sha256((ROOT/entry['source']).read_bytes()).hexdigest()==entry['sha256']
        assert Image.open(ROOT/entry['png']).size==(56,56)
    assert len(rom)==1024*1024
    headers=data('BaseStats',183*28);order=data('PokedexOrder',190)
    assert sorted(n for n in order if n)==list(range(1,184))
    assert (183+7)//8==23
    assert addr('wPokedexSeen')-addr('wPokedexOwned')==23
    for i,old in enumerate(PLAN['previous_headers']):
        before=bytes.fromhex(old);now=headers[i*28:(i+1)*28]
        if i+1 in TYPE_CHANGES:
            change=TYPE_CHANGES[i+1]
            assert before[6:8]==bytes(TYPES[t] for t in change['before'])
            before=before[:6]+bytes(TYPES[t] for t in change['after'])+before[8:]
        tuning=next((d for d in TUNING.values() if d['dex']==i+1),None)
        if tuning:
            starts=bytes([MOVES[m] for m in tuning['start']]+[0]*(4-len(tuning['start'])))
            before=before[:1]+bytes(tuning['stats'])+before[6:15]+starts+before[19:20]+bytes(next(e['tm_bytes'] for e in json.loads((ROOT/'data/tm_distribution.json').read_text())['entries'] if e['dex']==i+1))+before[27:]
        assert before[:11]+before[15:]==now[:11]+now[15:],i+1
    for d in NEW:
        h=headers[(d['dex']-1)*28:d['dex']*28]
        assert list(h[1:6])==d['stats']
        assert list(h[6:8])==[TYPES[t] for t in d['types']]
        assert order[d['index']-1]==d['dex']
        assert h[8]==d['catch'] and h[9]==d['xp']
    game=PyBoy(str(ROOT/(version+'.gbc')),window='null',sound_emulated=False)
    game.set_emulation_speed(0);game.tick(90,False)
    def put(n,v):game.memory[addr(n)]=v
    def get(n,size=1):return bytes(game.memory[addr(n):addr(n)+size])
    def call(n,**regs):
        b,a=syms[n];game.memory[0x2000]=game.memory[0xffb8]=b or 1
        game.memory[0,0x100:0x108]=[0xf3,0xcd,a&255,a>>8,0xc3,4,1,0]
        game.memory[0xffff]=game.memory[0xff0f]=0;game.register_file.SP=0xdffe;game.register_file.PC=0x100
        for k,v in regs.items():
            if k in ('BC','DE'):
                setattr(game.register_file,k[0],v>>8);setattr(game.register_file,k[1],v&255)
            else:setattr(game.register_file,k,v)
        for _ in range(120):
            game.tick(1,False)
            if game.register_file.PC in (0x104,0x105,0x106):return
        raise AssertionError((version,n,hex(game.register_file.PC)))
    def patch(n,code):
        b,a=syms[n];game.memory[b,a:a+len(code)]=code
    try:
        for n in ('CopyVideoData','ClearScreenArea','PrintText','PrintEmptyString','DelayFrames'):
            patch(n,[0xc9])
        bylabel={e['label']:ROOT/e['png'] for e in PLAN['backs']}
        for d in NEW:bylabel[d['name'].title()+'PicBack']=ROOT/f'pic/new_species/{d["name"]}_b.png'
        expected_labels={e['index']:e['label'] for e in PLAN['backs']}
        for variant in json.loads((ROOT/'data/unique_species.json').read_text()):
            expected_labels[variant['index']]=expected_labels[variant['base_index']]
        for d in NEW:expected_labels[d['index']]=d['name'].title()+'PicBack'
        # Full public back loader for every original, variant and new species.
        # Copied VRAM transfer is stubbed, but decompression and 2bpp preparation run.
        for index,dex in enumerate(order,1):
            if not dex:continue
            put('wd0b5',index);call('GetMonHeader');put('wBattleMonSpecies2',index);put('wSpriteFlipped',0)
            if dex in TYPE_CHANGES:assert get('wMonHType1',2)==bytes(TYPES[t] for t in TYPE_CHANGES[dex]['after'])
            game.memory[0x0000]=10;game.memory[0x4000]=0
            game.memory[addr('sHallOfFame'):addr('sHallOfFame')+32]=[0x5a]*32
            # Graphic routing must not corrupt move-effect scratch while an animation loads it.
            put('wCustomChance',91);put('wCustomRandomValue',93)
            call('LoadMonBackPic')
            assert get('sHallOfFame',32)==bytes([0x5a]*32)
            assert get('wCustomChance')[0]==91 and get('wCustomRandomValue')[0]==93
            stream=data('CustomBackStreams',3,(index-1)*3)
            if stream[0]:
                b,pointer=stream[0],stream[1]+256*stream[2]
                label=expected_labels[index]
                assert syms[label]==(b,pointer),(index,label,b,pointer)
                actual=get('sSpriteBuffer1',784);expected=gb_bytes(bylabel[label])
                assert actual==expected,(index,dex,label)
            else:
                assert index==2 # Kangaskhan, the only missing supplied back
        # New fronts and the approved Snorlax front use the ordinary front
        # alignment routine and the selected species' graphics bank.
        front_cases=[(d['index'],ROOT/f'pic/new_species/{d["name"]}.png') for d in NEW]+[(132,ROOT/'pic/bmon/snorlax.png')]
        for index,path in front_cases:
            put('wd0b5',index);call('GetMonHeader');put('wcf91',index)
            im=Image.open(path).convert('P');w,h=im.size
            canvas=Image.new('P',(56,56),0);canvas.putpalette(im.getpalette())
            canvas.paste(im,(((8-w//8)//2)*8,(7-h//8)*8))
            call('LoadMonFrontSprite',DE=0x9000)
            assert get('sSpriteBuffer1',784)==gb_bytes(canvas),index
        # New species can enter parties, use their levels/moves/PP and save all
        # four formerly unused high bits without moving later fields.
        put('wPartyCount',0);put('wMonDataLocation',0x80);put('wIsInBattle',0);put('wNumBagItems',7)
        for d in NEW:
            put('wPartyCount',0)
            put('wCurEnemyLVL',40);put('wcf91',d['index']);call('AddPartyMon')
            assert get('wPartyCount')[0]==1
            assert get('wNumBagItems')[0]==7
            slot=addr('wPartyMon1')
            known=list(d['start'])
            for level,move in d['learn']:
                if level<=40 and move not in known:known=(known+[move])[-4:]
            expected_moves=[MOVES[move] for move in known[-4:]]
            expected_moves += [0]*(4-len(expected_moves))
            off=addr('wPartyMon1Moves')-addr('wPartyMon1')
            assert list(game.memory[slot+off:slot+off+4])==expected_moves,d['name']
            off=addr('wPartyMon1PP')-addr('wPartyMon1')
            assert list(game.memory[slot+off:slot+off+4])==[data('Moves',max(MOVES.values())*6)[(move-1)*6+5] if move else 0 for move in expected_moves]
            flag=d['dex']-1;assert get('wPokedexOwned',23)[flag//8]&(1<<(flag%8))
            for dv in range(16):
                call('DetermineMonGender',D=d['index'],E=dv)
                assert game.register_file.D==(0 if d['symbol'] in ('BALTOY','CLAYDOL','DITTWO') else 0xf5 if d['symbol']=='MILTANK' or dv<8 else 0xef)
        snapshot=get('wPokedexOwned',23);assert snapshot[-1]&127==127
        call('SaveSAVtoSRAM0');call('SaveSAVtoSRAM2')
        for n in ('wPokedexOwned','wPokedexSeen'):game.memory[addr(n):addr(n)+23]=[0]*23
        call('LoadSAV0');call('LoadSAV2');assert not(game.register_file.F&16)
        assert get('wPokedexOwned',23)==snapshot
        stride=addr('wPartyMon2')-addr('wPartyMon1')
        assert game.memory[addr('wPartyMon1')]==NEW[-1]['index']
        for name,level,target in [('Baltoy',36,146),('Larvitar',30,161),('Pupitar',55,162),('Golbat',40,156)]:
            assert data(name+'EvosMoves',4)==bytes([1,level,target,0])
        for name,d in TUNING.items():
            index=order.index(d['dex'])+1
            put('wPartyCount',0);put('wCurEnemyLVL',60);put('wcf91',index);call('AddPartyMon')
            known=list(d['start'])
            for level,move in d['learn']:
                if move not in known:known=(known+[move])[-4:]
            expected=[MOVES[move] for move in known]+[0]*(4-len(known))
            assert get('wPartyMon1Moves',4)==bytes(expected),name
            assert get('wPartyMon1PP',4)==bytes(data('Moves',max(MOVES.values())*6)[(move-1)*6+5] if move else 0 for move in expected),name
            b,pointer=syms[d['title']+'EvosMoves']
            pos=pointer
            while game.memory[b,pos]:pos+=1
            pos+=1;actual=[]
            while game.memory[b,pos]:
                actual.append([game.memory[b,pos],game.memory[b,pos+1]]);pos+=2
            assert actual==[[level,MOVES[move]] for level,move in d['learn']],name
        # Evolution record is a real level-38 evolution to Toxapex.
        assert data('MareanieEvosMoves',4)==bytes([1,38,134,0])
        expected={'MAREANIE':5,'MILTANK':2,'SABLEYE':2,'BALTOY':2,'LARVITAR':2,'DITTWO':1}
        for mapname,kind,variants in pools('_RED' if version=='pokered' else '_BLUE'):
            counts=Counter(name for level,name in variants)
            for name,rate in expected.items():
                if name in counts:assert counts[name]==rate,(mapname,kind,name)
            if 'UNIQUE_OMANYTE_UNIQUE' in counts:assert counts['UNIQUE_OMANYTE_UNIQUE']==1
        print(f'{version}: 183 back-loader paths/pixel comparisons; eleven species/party/gender/evolution/save flags; old stats and encounter shares passed')
    finally:game.stop(save=False)


if __name__=='__main__':
    for name in ('pokered','pokeblue'):validate(name)
