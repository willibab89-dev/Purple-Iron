#!/usr/bin/env python3
"""Expanded dex flags while retaining the original SRAM layout and checksum."""
from pyboy import PyBoy
from test_unique_species import ROOT, symbols


def validate(version):
    syms=symbols(ROOT/(version+'.sym'))
    game=PyBoy(str(ROOT/(version+'.gbc')),window='null',sound_emulated=False)
    game.set_emulation_speed(0);game.tick(90,False)
    def addr(n):return syms[n][1]
    def put(n,v):game.memory[addr(n)]=v
    def byte(n):return game.memory[addr(n)]
    def call(n):
        bank,target=syms[n];game.memory[0x2000]=game.memory[0xffb8]=bank or 1
        game.memory[0,0x100:0x108]=[0xf3,0xcd,target&255,target>>8,0xc3,4,1,0]
        game.memory[0xffff]=game.memory[0xff0f]=0
        game.register_file.SP=0xdffe;game.register_file.PC=0x100
        for _ in range(200):
            game.tick(1,False)
            if game.register_file.PC in (0x104,0x105,0x106):return
        raise AssertionError((version,n,hex(game.register_file.PC)))
    def enable():
        game.memory[0]=0x0a;game.memory[0x6000]=1;game.memory[0x4000]=1
    def read(n,count):return bytes(game.memory[addr(n):addr(n)+count])
    try:
        assert addr('wPokedexSeen')-addr('wPokedexOwned')==25
        assert addr('wPokedexSeenEnd')-addr('wPokedexSeen')==25
        # These addresses are from the previous release and must never move.
        for name,want in {'wMainDataStart':0xd2f7,'wMainDataEnd':0xda88,'wBoxDataEnd':0xdeea,
                          'sMainData':0xa5a3,'sSpriteData':0xad34,'sPartyData':0xaf34,
                          'sCurBoxData':0xb0c8,'sMainDataCheckSum':0xb52b}.items():
            assert addr(name)==want,(version,name,hex(addr(name)))
        enable()
        start=addr('sPlayerName'); checksum=addr('sMainDataCheckSum')
        # A synthetic old-format image with distinct values through all fields.
        original=bytes(((i*37+19)&255) for i in range(checksum-start))
        game.memory[start:checksum]=original
        reserve=addr('sMainData')+(addr('wPokedexExtensionPadding')-addr('wMainDataStart'))-4
        game.memory[reserve:reserve+7]=[0]*7
        legacy=bytes(game.memory[start:checksum])
        game.memory[checksum]=(~sum(legacy))&255
        call('LoadSAV0');assert not(game.register_file.F&16)
        call('LoadSAV2');assert not(game.register_file.F&16)
        oldowned=legacy[addr('sMainData')-start:addr('sMainData')-start+23]
        oldseen=legacy[addr('sMainData')-start+23:addr('sMainData')-start+46]
        assert read('wPokedexOwned',25)==oldowned+b'\0\0'
        assert read('wPokedexSeen',25)==oldseen+b'\0\0'
        for n in ('wPlayerID','wPlayerMoney','wRivalName','wCurMapScript','wPlayTimeHours'):
            offset=addr('wPlayTimeHours')-addr('wMainDataStart') if n=='wPlayTimeHours' else addr(n)-addr('wMainDataStart')-4
            assert byte(n)==legacy[addr('sMainData')-start+offset],(version,n)
        call('SAVCheckRandomID');assert game.register_file.F&0x80, (version,'legacy ID check')
        # New flag bytes survive both full and partial saves and remain
        # checksummed, while the original 46 bytes stay at their old offsets.
        game.memory[addr('wPokedexOwned')+23:addr('wPokedexOwned')+25]=[0x81,0x41]
        game.memory[addr('wPokedexSeen')+23:addr('wPokedexSeen')+25]=[0x62,0x24]
        call('SaveSAVtoSRAM0');call('SaveSAVtoSRAM2');enable()
        assert bytes(game.memory[reserve:reserve+7])==bytes([0x4b,0x32,0x58,0x81,0x41,0x62,0x24])
        assert bytes(game.memory[addr('sMainData'):addr('sMainData')+23])==oldowned
        assert bytes(game.memory[addr('sMainData')+23:addr('sMainData')+46])==oldseen
        game.memory[addr('wPokedexOwned'):addr('wPokedexOwned')+25]=[0]*25
        game.memory[addr('wPokedexSeen'):addr('wPokedexSeen')+25]=[0]*25
        call('LoadSAV0');call('LoadSAV2')
        assert read('wPokedexOwned',25)==oldowned+bytes([0x81,0x41])
        assert read('wPokedexSeen',25)==oldseen+bytes([0x62,0x24])
        call('SAVCheckRandomID');assert game.register_file.F&0x80, (version,'new ID check')
        print(f'{version}: legacy saves, 200 dex bits, player ID, SRAM offsets and checksum round-trip passed')
    finally:game.stop(save=False)

if __name__=='__main__':
    for version in ('pokered','pokeblue'):validate(version)
