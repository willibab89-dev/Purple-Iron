#!/usr/bin/env python3
"""Exercise supply item dispatch, consumption, saves and deterministic loot."""
from collections import Counter
import re
from generate_curated_loot import pools,render as loot_render,report,LATE_MAPS,PREMIUM
from pathlib import Path
from pyboy import PyBoy
from generate_natures import definitions,render,ROOT,ATTRIBUTES
import os
from test_unique_species import symbols,TYPES
from test_move_patch_3 import constants,MOVES


def validate(version):
    assert (ROOT/'data/natures.asm').read_text()==render()
    syms=symbols(ROOT/(version+'.sym'));ids=constants(ROOT/'constants/pokemon_constants.asm')
    rom=(ROOT/(version+'.gbc')).read_bytes()
    def data(n,size):
        b,a=syms[n];start=b*16384+a-16384 if b else a
        return rom[start:start+size]
    table=definitions();assert data('NatureDefinitions',392)==bytes(v for pair in table for v in pair)
    game=PyBoy(str(ROOT/(version+'.gbc')),window='null',sound_emulated=False)
    game.set_emulation_speed(0);game.tick(90,False)
    def addr(n):return {'turn':0xfff3,'hSpriteIndexOrTextID':0xff8c}.get(n) or syms[n][1]
    def put(n,v):game.memory[addr(n)]=v
    def get(n):return game.memory[addr(n)]
    def word(n,v):game.memory[addr(n):addr(n)+2]=[v>>8,v&255]
    def readword(n):return get(n)*256+game.memory[addr(n)+1]
    def patch(n,code):
        b,a=syms[n];game.memory[b,a:a+len(code)]=code
    def call(n,**regs):
        b,a=syms[n];game.memory[0x2000]=game.memory[0xffb8]=b or 1
        game.memory[0,0x100:0x108]=[0xf3,0xcd,a&255,a>>8,0xc3,4,1,0]
        game.memory[0xffff]=game.memory[0xff0f]=0;game.register_file.SP=0xdffe;game.register_file.PC=0x100
        game.memory[0xdf42:0xdf62]=[0xa5]*32
        for k,v in regs.items():
            if k in ('BC','DE'):
                setattr(game.register_file,k[0],v>>8);setattr(game.register_file,k[1],v&255)
            else:setattr(game.register_file,k,v)
        for _ in range(180):
            game.tick(1,False)
            if game.register_file.PC in (0x104,0x105,0x106):
                assert bytes(game.memory[0xdf42:0xdf62])==bytes([0xa5]*32),('stack guard',n)
                return
        raise AssertionError((version,n,hex(game.register_file.PC),hex(game.register_file.SP)))
    state={'values':[0],'index':0}
    def rng(*values):state.update(values=list(values),index=0)
    def on_rng(s):
        i=s['index'];s['index']+=1;game.register_file.A=s['values'][min(i,len(s['values'])-1)]
    patch('Random',[0xc9]);b,a=syms['Random'];game.hook_register(b,a,on_rng,state)
    def source(label):word('wNatureInputHL',addr(label))
    def stored(label,id,slot=1,t1=0,t2=0):
        put(label+'Species',ids['BULBASAUR']);put(label+'Type1',t1|(slot<<5));put(label+'Type2',t2|224);put(label+'CatchRate',id)
    def inspect(label):
        source(label);call('NatureEnsureMon');return get('wNatureID'),get('wNatureSlot')
    def item_constants():
        result={};value=0
        for line in (ROOT/'constants/item_constants.asm').read_text().splitlines():
            m=re.match(r'const_value = (\$[\da-fA-F]+|\d+)',line)
            if m:value=int(m[1][1:],16) if m[1].startswith('$') else int(m[1])
            m=re.match(r'\s*const (\w+)',line)
            if m:result[m[1]]=value;value+=1
        return result
    items=item_constants();pool,tms,moves=pools()
    maps={n:i for i,n in enumerate(re.findall(r'^\s*mapconst (\w+)',(ROOT/'constants/map_constants.asm').read_text(),re.M))}
    def bag(item,qty=2):
        put('wNumBagItems',2)
        game.memory[addr('wBagItems'):addr('wBagItems')+5]=[items['POTION'],7,item,qty,255]
        put('wWhichPokemon',1);put('wcf91',item)
    def quantity():return game.memory[addr('wBagItems')+3]
    def initmon(index,species='BULBASAUR',nature=0,slot=1,hp=100,maximum=100):
        label='wPartyMon'+str(index+1)
        game.memory[addr(label):addr(label)+44]=[0]*44
        put(label+'Species',ids[species]);put(label+'Type1',slot<<5);put(label+'Type2',224);put(label+'CatchRate',nature)
        put(label+'Level',40);put(label+'DVs',0xaa);game.memory[addr(label+'DVs')+1]=0xbb
        word(label+'HP',hp);word(label+'MaxHP',maximum)
        put(label+'Status',8);put(label+'Moves',MOVES['TACKLE']);put(label+'PP',12)
        return label
    def raw(label,size=44):return bytes(game.memory[addr(label):addr(label)+size])
    select={'cancel':False,'mon':0}
    def on_select(_):
        put('wWhichPokemon',select['mon']);put('wcf91',0)
        game.register_file.F=16 if select['cancel'] else 0
    try:
        assert (ROOT/'data/curated_loot.asm').read_text()==loot_render()
        assert (ROOT/'docs/CURATED-LOOT-AND-SUPPLIES.md').read_text()==report()
        assert [items[x] for x in ('ABILITY_CAPSULE','NATURE_CAPSULE','FIRST_AID')]==[111,112,113]
        assert syms['wNatureInputHL'][1]==0xdf22 and syms['wNatureScratchEnd'][1]==0xdf42
        for n in ('PrintText','PlaySound','WaitForTextScrollButtonPress'):patch(n,[0xc9])
        patch('DisplayPartyMenu',[0xc9]);b,a=syms['DisplayPartyMenu'];game.hook_register(b,a,on_select,None)
        for name,price,display in [('ABILITY_CAPSULE',30000,'ABILITY CAP'),('NATURE_CAPSULE',30000,'NATURE CAP'),('FIRST_AID',10000,'FIRST AID')]:
            item=items[name];put('wd11e',item);put('wNameListType',2);call('GetItemName')
            from test_move_patch_1 import CHARMAP
            assert bytes(game.memory[addr('wcd6d'):addr('wcd6d')+len(display)+1])==bytes(CHARMAP[c] for c in display+'@')
            put('wcf91',item);put('wListMenuID',0)
            game.memory[addr('wItemPrices'):addr('wItemPrices')+2]=[syms['ItemPrices'][1]&255,syms['ItemPrices'][1]>>8]
            call('GetItemPrice');assert bytes(game.memory[0xff8b:0xff8b+3])==bytes.fromhex(f'{price:06d}')
            call('IsKeyItem_');assert get('wIsKeyItem')==0
            call('IsItemHM',A=item);assert not(game.register_file.F&16)
            # Battle and empty-party uses fail, with no consumption or party change.
            for battle,count in [(1,1),(2,1),(0,0)]:
                initmon(0);before=raw('wPartyMon1');put('wIsInBattle',battle);put('wPartyCount',count);bag(item)
                call('UseItem_');assert quantity()==2 and get('wActionResultOrTookBattleTurn')==0 and raw('wPartyMon1')==before
        put('wIsInBattle',0);put('wPartyCount',2)
        # Real dispatch and bag index restoration; each possible old slot excludes itself.
        for species in ('BULBASAUR','IVYSAUR','VENUSAUR','CHARMANDER','CHARMELEON','CHARIZARD'):
            for old in range(1,6):
                for new in range(1,6):
                    if new==old:continue
                    initmon(0);label=initmon(1,species,nature=17,slot=old);before=raw(label)
                    select.update(cancel=False,mon=1);bag(items['ABILITY_CAPSULE']);rng(old-1,new-1)
                    call('UseItem_');after=raw(label)
                    assert quantity()==1 and get('wWhichPokemon')==1
                    assert get(label+'Type1')>>5==new and after[:5]==before[:5] and after[6:]==before[6:]
                    assert state['index']==2
        for item in ('ABILITY_CAPSULE','NATURE_CAPSULE'):
            for cancel in (True,False):
                initmon(0);label=initmon(1,'PIKACHU');before=raw(label);select.update(cancel=cancel,mon=1);bag(items[item]);rng(9)
                if not cancel and item=='NATURE_CAPSULE':continue
                call('UseItem_');assert quantity()==2 and raw(label)==before and get('wActionResultOrTookBattleTurn')==0
        select.update(cancel=False,mon=1)
        # Every nature change uses native stat recalculation and preserves missing HP.
        for old,new,hp in [(0,1,75),(1,0,75),(0,195,0),(195,0,1),(7,33,1)]:
            initmon(0);label=initmon(1,nature=old,slot=4,hp=100,maximum=100)
            word('wNatureMonPtr',addr(label));put('wNatureMode',0);call('NatureMigrateOne')
            maximum=readword(label+'MaxHP');word(label+'HP',min(hp,maximum));missing=maximum-min(hp,maximum);before=raw(label)
            bag(items['NATURE_CAPSULE']);rng(old,new);call('UseItem_')
            assert quantity()==1 and get(label+'CatchRate')==new and get(label+'Type1')>>5==4
            assert readword(label+'HP')==(max(1,readword(label+'MaxHP')-missing) if hp else 0)
            after=raw(label);assert after[3:7]==before[3:7] and after[8:34]==before[8:34]
            # Re-running native migration must reproduce the same recalculated stats.
            expected=after[34:44];word('wNatureMonPtr',addr(label));call('NatureMigrateOne');assert raw(label)[34:44]==expected
        # Party-wide heal, odd maxima, cap, 16-bit HP, status unchanged, no revival.
        put('wPartyCount',6)
        for i,(hp,maximum) in enumerate([(1,101),(90,101),(0,101),(200,600),(999,999),(1,1)]):initmon(i,hp=hp,maximum=maximum)
        before=[raw('wPartyMon'+str(i+1)) for i in range(6)]
        bag(items['FIRST_AID']);call('UseItem_');assert quantity()==1
        assert [readword('wPartyMon'+str(i+1)+'HP') for i in range(6)]==[51,101,0,500,999,1]
        for i in range(6):
            after=raw('wPartyMon'+str(i+1));assert after[:1]+after[3:]==before[i][:1]+before[i][3:]
        # No effect: all full or fainted; last item disappears only on success.
        put('wPartyCount',2);initmon(0,hp=100);initmon(1,hp=0);bag(items['FIRST_AID']);call('UseItem_')
        assert quantity()==2 and get('wActionResultOrTookBattleTurn')==0
        word('wPartyMon1HP',1);bag(items['FIRST_AID'],1);call('UseItem_');assert get('wNumBagItems')==1 and game.memory[addr('wBagItems')+2]==255
        # Capsule records and ordinary bag items survive the existing save/load format.
        put('wPartyCount',2);bag(items['NATURE_CAPSULE']);savedparty=raw('wPartyMon1',88);savedbag=raw('wNumBagItems',6)
        call('SaveSAVtoSRAM0');call('SaveSAVtoSRAM2')
        game.memory[addr('wPartyMon1'):addr('wPartyMon1')+88]=[0]*88
        call('LoadSAV0');call('LoadSAV2');assert raw('wPartyMon1',88)==savedparty and raw('wNumBagItems',6)==savedbag
        # Every pool, all 256 hashes. Changing ID's high byte sweeps the hash space.
        put('wCurMap',maps['MT_MOON_1']);put('hSpriteIndexOrTextID',9);game.memory[0xffdb]=123
        for original,choices in pool.items():
            got=[]
            for tid in range(256):
                word('wPlayerID',tid<<8);put('wLootItem',items[original]);rng(99);call('SelectCuratedLoot')
                got.append(get('wLootItem'));assert state['index']==0 and game.memory[0xffdb]==123
            assert set(got)=={items[x] for x in choices},original
            counts=Counter(got);assert all(abs(counts[k]-256*choices.count(next(x for x in set(choices) if items[x]==k))/len(choices))<=len(choices) for k in counts)
        for mapname in LATE_MAPS:
            put('wCurMap',maps[mapname])
            for original in PREMIUM:
                got=[]
                for tid in range(256):
                    word('wPlayerID',tid<<8);put('wLootItem',items[original]);call('SelectCuratedLoot');got.append(get('wLootItem'))
                assert Counter(got)=={items[original]:160,items['FIRST_AID']:64,items['NATURE_CAPSULE']:16,items['ABILITY_CAPSULE']:16}
            for fixed in ['SECRET_KEY','CARD_KEY','LIFT_KEY','SILPH_SCOPE','OAKS_PARCEL','MOON_STONE','DOME_FOSSIL','MASTER_BALL','EXP_ALL','HM_01','HM_03','NUGGET']:
                put('wLootItem',items[fixed]);call('SelectCuratedLoot');assert get('wLootItem')==items[fixed]
        # Actual pickup handler: bag full leaves object, no RNG advance, same roll on retry.
        for n in ('EnableAutoTextBoxDrawing','HideObject'):patch(n,[0xc9])
        hidden={'count':0}
        b,a=syms['HideObject'];game.hook_register(b,a,lambda s:s.update(count=s['count']+1),hidden)
        put('wCurMap',maps['MANSION_3']);word('wPlayerID',0x1234);put('hSpriteIndexOrTextID',3)
        game.memory[addr('wMissableObjectList'):addr('wMissableObjectList')+3]=[3,77,255]
        game.memory[addr('wMapSpriteExtraData')+4]=items['MAX_POTION']
        put('wLootItem',items['MAX_POTION']);call('SelectCuratedLoot');expected=get('wLootItem')
        put('wNumBagItems',20);game.memory[addr('wBagItems'):addr('wBagItems')+41]=[items['POTION'],99]*20+[255]
        rng(88);call('PickUpItem');assert get('wLootItem')==expected and hidden['count']==0 and state['index']==0
        put('wNumBagItems',0);game.memory[addr('wBagItems')]=255;call('PickUpItem')
        assert get('wNumBagItems')==1 and game.memory[addr('wBagItems')]==expected and hidden['count']==1 and get('wMissableObjectIndex')==77
        assert game.memory[addr('wMapSpriteExtraData')+4]==items['MAX_POTION']
        # New vendor stock retains all seven previous items; existing gate remains.
        stock=data('CeladonMart3ClerkText',13);assert stock[:2]==bytes([254,10]) and stock[-4:]==bytes([111,112,113,255])
        script=(ROOT/'scripts/celadonmart3.asm').read_text();assert 'CheckEvent EVENT_908' in script and 'HS_CELADON_MART_3_BLOCKER' in script
        print(f'{version}: capsule slots/natures, HP recalculation, refusal/cancel/consumption, whole-party First Aid, saves, all loot pools/rare weights/progression guards, actual bag-full pickup and late shop passed')
    finally:game.stop(save=False)

if __name__=='__main__':
    for v in ('pokered','pokeblue'):validate(v)
