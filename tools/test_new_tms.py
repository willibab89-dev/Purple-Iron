#!/usr/bin/env python3
"""Exercise expanded machines, eligibility, names, prices, teaching and saves."""
import json
import re
from pyboy import PyBoy
from test_unique_species import ROOT, symbols
from test_move_patch_1 import CHARMAP
from test_move_patch_3 import MOVES

PLAN = json.loads((ROOT / 'data/new_tms.json').read_text())


def validate(version):
    rom = (ROOT / (version + '.gbc')).read_bytes()
    syms = symbols(ROOT / (version + '.sym'))
    def addr(n):
        if n == 'hItemPrice': return 0xff8b
        return syms[n][1]
    def data(n, size):
        bank, a = syms[n]
        off = bank * 0x4000 + a - 0x4000 if bank else a
        return rom[off:off + size]
    def encoded(s):
        # RGBDS treats the contraction as one charmap token.
        result = bytearray()
        while s:
            if s.startswith("'s"):
                result.append(0xbd); s = s[2:]
            else:
                result.append(CHARMAP[s[0]]); s = s[1:]
        return bytes(result) + bytes([CHARMAP['@']])
    assert data('TechnicalMachines', 55 + len(PLAN['new_tms'])) == bytes(MOVES[x] for x in PLAN['old_machine_moves']) + bytes(d['move_id'] for d in PLAN['new_tms'])
    oldnames = re.findall(r'^\s*db "([^"@]+)@"', PLAN['baseline_item_names'], re.M)
    assert len(oldnames) == 97
    expected_names = b''.join(encoded(n) for n in oldnames + [d['name'] for d in PLAN['new_tms']])
    assert data('ItemNames', len(expected_names)) == expected_names
    def bcd(n): return bytes.fromhex(f'{n:06d}')
    oldprices = [int(n) for n in re.findall(r'^\s*money\s+(\d+)', PLAN['baseline_item_prices'], re.M)]
    assert len(oldprices) == 97
    for item,price in {11:200,12:200,18:600,19:200,59:600,60:750,61:1000}.items():
        oldprices[item]=price
    assert data('ItemPrices', (97 + len(PLAN['new_tms'])) * 3) == b''.join(bcd(n) for n in oldprices + [d['price'] for d in PLAN['new_tms']])
    masks = b''.join(e['mask'].to_bytes(2, 'little') for e in PLAN['entries'])
    assert data('ExtraTMCompatibilityTable', 2 * len(PLAN['entries'])) == masks
    byname = {e['name']: set(e['tms']) for e in PLAN['entries']}
    assert byname['mew'] == set(range(51, 64))
    for number,allowed in [(61,{'ekans','arbok','zubat','golbat','crobat','paras','parasect','tangela_erika','mew'}),(62,{'ekans','arbok','beedrill','nidoranf','nidorina','nidoqueen','nidoranm','nidorino','nidoking','bellsprout','weepinbell','victreebel','nidoking_unique','nidoking_unique2','nidoranm_unique','mew'}),(63,{'farfetchd','butterfree','beedrill','pidgey','pidgeotto','pidgeot','spearow','fearow','pikachu','raichu','growlithe','arcanine','ponyta','rapidash','doduo','dodrio','hitmonlee','horsea','seadra','goldeen','seaking','porygon','goldeen_fighting','nidoking_unique2','mew'})]:
        assert {name for name,tms in byname.items() if number in tms}==allowed
    for baby, adult in (('caterpie','butterfree'),):
        assert 51 not in byname[baby] and 51 in byname[adult]
    for mon in ('charmander','charmeleon','charizard'):
        assert 51 not in byname[mon] and 58 not in byname[mon]
    assert 56 in byname['nidoqueen'] and 56 not in byname['nidoking']
    for mon in ('growlithe','arcanine','ponyta','rapidash'):
        assert {52,63} <= byname[mon] and 58 not in byname[mon]
    for mon in ('poliwhirl','poliwrath'):assert 52 in byname[mon]
    assert {52,63} <= byname['hitmonlee'] and 56 not in byname['hitmonlee']
    assert {52,56} <= byname['hitmonchan']
    for mon in ('exeggcute','exeggutor'):assert 60 not in byname[mon]
    assert 54 not in byname['tangela'] and 56 not in byname['kangaskhan']
    for mon in ('horsea','seadra'):assert 63 in byname[mon]
    for mon in ('goldeen','seaking'):assert {52,63} <= byname[mon]
    for mon in ('staryu','starmie'):assert 53 not in byname[mon] and 59 not in byname[mon]
    assert {52,55} <= byname['scyther'] and 51 not in byname['scyther']
    for mon in ('electabuzz','magmar'):assert 52 in byname[mon] and 56 not in byname[mon]
    assert 58 not in byname['magmar']
    assert {52,56,57} <= byname['pinsir']
    for mon in ('eevee','vaporeon','jolteon','flareon'):assert 52 in byname[mon]
    assert 58 not in byname['flareon'] and not byname['ditto']
    assert {52,63} <= byname['porygon']
    for mon in ('omanyte','omastar'):assert 59 not in byname[mon]
    assert {52,55,57} <= byname['aerodactyl'] and 51 not in byname['aerodactyl']
    for mon in ('articuno','zapdos','moltres'):assert 51 in byname[mon]
    assert 51 not in byname['dragonite'] and 55 in byname['dragonite']
    for mon in ('mareanie','toxapex'):assert {53,54,59} <= byname[mon]
    assert not ({56,57} & byname['miltank'])
    assert not ({55,57} & byname['sableye']) and {58,60} <= byname['sableye']
    for mon in ('baltoy','claydol'):assert {57,60} <= byname[mon]
    for mon in ('larvitar','pupitar','tyranitar'):assert 57 in byname[mon]
    assert not byname['dittwo']
    assert 55 in byname['charizard']
    for mon in ('spearow','fearow'):
        assert 51 not in byname[mon] and {52,55,63} <= byname[mon]
    for mon in ('pikachu','raichu'):assert {52,63} <= byname[mon]
    for mon in ('zubat','golbat','crobat'):
        assert 51 not in byname[mon] and {54,55,61} <= byname[mon]
    for mon in ('jigglypuff','wigglytuff'):assert 52 in byname[mon]
    assert 51 not in byname['venomoth']
    assert 60 in byname['parasect'] and 60 not in byname['paras']
    assert 51 not in byname['doduo'] and 51 not in byname['dodrio']
    assert 55 not in byname['kabuto'] and 55 in byname['kabutops']
    assert 53 not in byname['magikarp']
    for mon in ('slowbro','starmie','lapras','gyarados','krabby','kingler','horsea','seadra'): assert 59 not in byname[mon]
    for mon in ('krabby','kingler'):assert 52 in byname[mon]
    assert 59 in byname['vaporeon']
    assert 53 in byname['goldeen'] and 53 not in byname['goldeen_fighting'] and 52 in byname['goldeen_fighting']
    assert 56 in byname['geodude_fighting'] and 56 not in byname['geodude']
    assert 57 in byname['kakuna_rock_type'] and 54 not in byname['kakuna_rock_type'] and 54 in byname['kakuna']
    item_ids = {}; value = 0
    for line in (ROOT / 'constants/item_constants.asm').read_text().splitlines():
        match = re.match(r'\s*const_value = (\$[0-9a-fA-F]+|\d+)', line)
        if match: value = int(match[1][1:], 16) if match[1].startswith('$') else int(match[1])
        match = re.match(r'\s*const (\w+)', line)
        if match: item_ids[match[1]] = value; value += 1
    # Original mart stock is retained, and all lists fit the 16-byte buffer.
    oldshops = re.sub(r';[^\n]*', '', PLAN['baseline_shops'])
    for label, stock in re.findall(r'(\w+)::\n\s*TX_MART ([^\n]+)', oldshops):
        old = [x.strip() for x in stock.split(',')]
        new = [f'TM_{d["number"]}' for d in PLAN['new_tms'] if d['shop'] == label]
        if label == 'CeladonMart3ClerkText': new += ['ABILITY_CAPSULE', 'NATURE_CAPSULE', 'FIRST_AID']
        raw = data(label, 2 + len(old) + len(new) + 1)
        assert raw[0] == 254 and raw[1] == len(old) + len(new) <= 14, label
        assert raw[-1] == 255
        assert list(raw[2:2 + len(old)]) == [item_ids[x] for x in old], label
        assert list(raw[2 + len(old):-1]) == [item_ids[x] for x in new]
    game = PyBoy(str(ROOT / (version + '.gbc')), window='null', sound_emulated=False)
    game.set_emulation_speed(0)
    game.tick(90, False)
    def put(n, v): game.memory[addr(n)] = v
    def get(n): return game.memory[addr(n)]
    def word(n, v): game.memory[addr(n):addr(n) + 2] = [v >> 8, v & 255]
    def call(n, **regs):
        bank, a = syms[n]
        game.memory[0x2000] = game.memory[0xffb8] = bank or 1
        game.memory[0, 0x100:0x108] = [0xf3, 0xcd, a & 255, a >> 8, 0xc3, 4, 1, 0]
        game.memory[0xffff] = game.memory[0xff0f] = 0
        game.register_file.SP = 0xdffe
        game.register_file.PC = 0x100
        for k, v in regs.items():
            if k in ('BC', 'DE'):
                setattr(game.register_file, k[0], v >> 8)
                setattr(game.register_file, k[1], v & 255)
            else:
                setattr(game.register_file, k, v)
        for _ in range(90):
            game.tick(1, False)
            if game.register_file.PC in (0x104, 0x105, 0x106): return
        raise AssertionError((version, n, hex(game.register_file.PC)))
    def patch(n, code):
        bank, a = syms[n]
        game.memory[bank, a:a + len(code)] = code
    try:
        order = data('PokedexOrder', 190)
        for e in PLAN['entries']:
            index = order.index(e['dex']) + 1
            for d in PLAN['new_tms']:
                put('wcf91', index); put('wMoveNum', d['move_id']); put('wd11e', 77)
                call('CanLearnTM')
                assert bool(game.register_file.C) == (d['number'] in e['tms']), (e['name'], d['number'])
                assert get('wd11e') == 77
        # Invalid non-machine lookup is bounded rather than running beyond ROM.
        put('wMoveNum', MOVES['POUND']); call('CanLearnTM'); assert game.register_file.C == 0
        items = [(201 + i, 1 + i, False) for i in range(50)] + [(196 + i, 51 + i, True) for i in range(5)]
        items += [(d['item_id'], d['internal_number'], False) for d in PLAN['new_tms']]
        legacy_names = re.findall(r'^\s*db "([^"@]+)@"', (ROOT / 'text/tmhm_names.asm').read_text(), re.M)
        for item, internal, hm in items:
            put('wcf91', item); call('DecodeMachineItem')
            assert get('wd11e') == internal and bool(game.register_file.F & 16) == hm, item
            call('TMToMove'); assert get('wd11e') == data('TechnicalMachines', 55 + len(PLAN['new_tms']))[internal - 1]
            put('wd11e', item); put('wNameListType', 2); call('GetItemName')
            name = legacy_names[item - 196] if item >= 196 else next(d['name'] for d in PLAN['new_tms'] if d['item_id'] == item)
            assert bytes(game.memory[addr('wcd6d'):addr('wcd6d') + len(name) + 1]) == encoded(name), item
        for d in PLAN['new_tms']:
            put('wd11e', d['item_id']); put('wNameListType', 2); call('GetItemName')
            assert bytes(game.memory[addr('wcd6d'):addr('wcd6d') + len(d['name']) + 1]) == encoded(d['name'])
            put('wcf91', d['item_id']); put('wListMenuID', 0)
            word('wItemPrices', 0) # pointer fields are little endian, unlike HP
            game.memory[addr('wItemPrices'):addr('wItemPrices') + 2] = [addr('ItemPrices') & 255, addr('ItemPrices') >> 8]
            call('GetItemPrice'); assert bytes(game.memory[addr('hItemPrice'):addr('hItemPrice') + 3]) == bcd(d['price'])
            call('IsKeyItem_'); assert get('wIsKeyItem') == 0
            call('IsItemHM', A=d['item_id']); assert not(game.register_file.F & 16)
        # Display, charge and affordability use the revised drink prices.
        assert data('DrinkPriceText', len(encoded('¥600')) - 1) == encoded('¥600')[:-1]
        for index,(item,price) in enumerate([(60,600),(61,750),(62,1000)]):
            put('wCurrentMenuItem',index);call('LoadVendingMachineItem')
            assert game.memory[0xffdb]==item
            assert bytes(game.memory[0xffdc:0xffdf])==bcd(price)
            assert bytes(game.memory[0xff9f:0xffa2])==bcd(price)
            put('wcf91',item);call('GetItemPrice')
            assert bytes(game.memory[0xff8b:0xff8e])==bcd(price)
            for money in (price-1,price,price+1):
                game.memory[addr('wPlayerMoney'):addr('wPlayerMoney')+3]=bcd(money)
                call('HasEnoughMoney');assert bool(game.register_file.F&16)==(money<price)
        # Purchase through the real vending menu, bag and BCD subtraction.
        presentation=('PrintText','DisplayTextBoxID','TextBoxBorder','UpdateSprites',
                      'PlaceString','HandleMenuInput','DelayFrames','PlaySound')
        originals={n:data(n,1) for n in presentation}
        for n in presentation:patch(n,[0xc9])
        choice={'index':0}
        def choose_drink(s):
            put('wCurrentMenuItem',s['index']);game.register_file.A=1
        bank,address=syms['HandleMenuInput'];game.hook_register(bank,address,choose_drink,choice)
        for index,(item,price) in enumerate([(60,600),(61,750),(62,1000)]):
            choice['index']=index
            for money in (price-1,price,price+1):
                put('wNumBagItems',0);put('wBagItems',255)
                game.memory[addr('wPlayerMoney'):addr('wPlayerMoney')+3]=bcd(money)
                call('VendingMachineMenu')
                success=money>=price
                assert get('wNumBagItems')==int(success)
                if success:assert bytes(game.memory[addr('wBagItems'):addr('wBagItems')+3])==bytes([item,1,255])
                assert bytes(game.memory[addr('wPlayerMoney'):addr('wPlayerMoney')+3])==bcd(money-price if success else money)
            put('wNumBagItems',20)
            game.memory[addr('wBagItems'):addr('wBagItems')+41]=[20,99]*20+[255]
            game.memory[addr('wPlayerMoney'):addr('wPlayerMoney')+3]=bcd(10000)
            call('VendingMachineMenu')
            assert get('wNumBagItems')==20 and bytes(game.memory[addr('wPlayerMoney'):addr('wPlayerMoney')+3])==bcd(10000)
        game.hook_deregister(bank,address)
        for n,code in originals.items():patch(n,code)
        # Legacy machine prices still use their original nibble table.
        prices = [int(x) * 1000 for row in re.findall(r'^\s*dn (\d+), (\d+)', (ROOT / 'data/tm_prices.asm').read_text(), re.M) for x in row]
        for i, price in enumerate(prices):
            put('wcf91', 201 + i); call('GetItemPrice')
            assert bytes(game.memory[0xff8b:0xff8e]) == bcd(price)
        # New items stack in the existing bag layout.
        put('wNumBagItems', 0); game.memory[addr('wBagItems')] = 255
        for d in PLAN['new_tms']:
            put('wcf91', d['item_id']); put('wItemQuantity', 2)
            call('AddItemToInventory', HL=addr('wNumBagItems')); assert game.register_file.F & 16
        assert get('wNumBagItems') == len(PLAN['new_tms'])
        bag = bytes(game.memory[addr('wNumBagItems'):addr('wNumBagItems') + 2 + 2*len(PLAN['new_tms'])])
        call('SaveSAVtoSRAM0'); call('SaveSAVtoSRAM2')
        game.memory[addr('wNumBagItems'):addr('wNumBagItems') + 2 + 2*len(PLAN['new_tms'])] = [0] * (2 + 2*len(PLAN['new_tms']))
        call('LoadSAV0'); call('LoadSAV2'); assert not(game.register_file.F & 16)
        assert bytes(game.memory[addr('wNumBagItems'):addr('wNumBagItems') + 2 + 2*len(PLAN['new_tms'])]) == bag
        # Teach through the real item dispatch/eligibility/LearnMove/consumption
        # paths. Only presentation and player selections are replaced.
        for n in ('PrintText', 'DisplayTextBoxID', 'SaveScreenTilesToBuffer1', 'GetPartyMonName', 'PlaySound',
                  'WaitForTextScrollButtonPress', 'GBPalWhiteOutWithDelay3', 'ClearSprites', 'RunDefaultPaletteCommand',
                  'LoadScreenTilesFromBuffer1', 'PlaySoundWaitForCurrent'):
            patch(n, [0xc9])
        patch('DisplayPartyMenu', [0xc9])
        selection = {'species': order.index(151) + 1, 'calls': 0, 'cancel_after': 99}
        def choose(s):
            put('wWhichPokemon', 0); put('wcf91', s['species'])
            game.register_file.F = 16 if s['calls'] >= s['cancel_after'] else 0
            s['calls'] += 1
        bank, a = syms['DisplayPartyMenu']; game.hook_register(bank, a, choose, selection)
        put('wIsInBattle', 0); put('wPartyCount', 1); put('wPartySpecies', selection['species'])
        for i, d in enumerate(PLAN['new_tms']):
            game.memory[addr('wPartyMon1Moves'):addr('wPartyMon1Moves') + 4] = [0] * 4
            game.memory[addr('wPartyMon1PP'):addr('wPartyMon1PP') + 4] = [0] * 4
            put('wcf91', d['item_id']); put('wWhichPokemon', i); put('wCurrentMenuItem', 0)
            selection.update(calls=0, cancel_after=99)
            call('UseItem_')
            assert get('wPartyMon1Moves') == d['move_id'], d['number']
            assert get('wPartyMon1PP') == data('Moves', 219 * 6)[(d['move_id'] - 1) * 6 + 5]
            assert game.memory[addr('wBagItems') + i * 2 + 1] == 1, d['number']
            # Already-known and incompatible choices do not consume another TM.
            for incompatible in (False, True):
                selection.update(species=76 if incompatible else order.index(151) + 1, calls=0, cancel_after=1)
                put('wcf91', d['item_id']); put('wWhichPokemon', i); put('wCurrentMenuItem', 0)
                call('UseItem_'); assert game.memory[addr('wBagItems') + i * 2 + 1] == 1
            # Declining at the first prompt or trying during battle is safe.
            put('wcf91', d['item_id']); put('wWhichPokemon', i); put('wCurrentMenuItem', 1)
            call('UseItem_'); assert game.memory[addr('wBagItems') + i * 2 + 1] == 1
            put('wIsInBattle', 2); put('wcf91', d['item_id']); call('UseItem_')
            assert game.memory[addr('wBagItems') + i * 2 + 1] == 1
            put('wIsInBattle', 0)
            selection['species'] = order.index(151) + 1
        print(f'{version}: {len(PLAN['entries']) * len(PLAN['new_tms'])} eligibility cases; all 68 machine mappings; new names/prices/key flags; shop limits; bag saves; thirteen real teaching/consumption and refusal paths passed')
    finally:
        game.stop(save=False)


if __name__ == '__main__':
    for version in ('pokered', 'pokeblue'):
        validate(version)
