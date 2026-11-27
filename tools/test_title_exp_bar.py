#!/usr/bin/env python3
"""Title tiles and battle EXP graphics/palette selection."""
from pyboy import PyBoy
from test_unique_species import ROOT, symbols


def validate(version):
    syms=symbols(ROOT/(version+'.sym'))
    rom=(ROOT/(version+'.gbc')).read_bytes()
    def data(name, size, offset=0):
        bank,address=syms[name]; start=bank*16384+address-16384+offset
        return rom[start:start+size]
    original=(ROOT/'gfx/exp_bar.2bpp').read_bytes()
    graphics=data('EXPBarGraphics',len(original))
    for tile in range(9):
        old=original[tile*16:(tile+1)*16]; actual=graphics[tile*16:(tile+1)*16]
        assert actual==old[:4]+b'\xff\xff'+old[6:], (version,'EXP divider',tile)
    attrs=data('BGMapAttributes_Battle',16+32*18)
    assert attrs[16+11*32+10:16+11*32+18]==bytes([4]*8)
    assert attrs[16+10*32+10:16+10*32+18]==bytes([0]*8)
    if version=='pokered':
        assert data('VersionOnTitleScreenText',13)==bytes([0x5f,0x60,0x61,0x62,0x63,0x64,0x7f,0x65,0x66,0x67,0x68,0x69,0x50])
        font=(ROOT/'gfx/font.1bpp').read_bytes()
        glyphs=b''.join(font[i*8:(i+1)*8] for i in (10,32,45,51,54,46))
        assert data('Version_GFX',48)==glyphs
    else:
        assert data('VersionOnTitleScreenText',9)==bytes([0x61,0x62,0x63,0x64,0x65,0x66,0x67,0x68,0x50])
    game=PyBoy(str(ROOT/(version+'.gbc')),window='null',sound_emulated=False)
    game.set_emulation_speed(0);game.tick(90,False)
    def addr(n):return syms[n][1]
    def call(name):
        bank,address=syms[name];game.memory[0x2000]=game.memory[0xffb8]=bank
        game.memory[0,0x100:0x108]=[0xf3,0xcd,address&255,address>>8,0xc3,4,1,0]
        game.memory[0xffff]=game.memory[0xff0f]=0;game.register_file.SP=0xdffe;game.register_file.PC=0x100
        for _ in range(120):
            game.tick(1,False)
            if game.register_file.PC in (0x104,0x105,0x106):return
        raise AssertionError((version,name,hex(game.register_file.PC)))
    try:
        game.memory[0xff40]=0;game.memory[0xff47]=0xe4
        cases=[(0,'GBCBasePalettes',12*8),(0xa0,'GBCBasePalettes',12*8),
               (0xa1,'ColorSchemeGray',0),(0xa2,'SuperPalettes',12*8),
               (0xa3,'ColorSchemeGreen',0),(0xa4,'ColorSchemeNight',0),
               (0xa5,'ColorSchemeMononoke',0),(0xa6,'ColorSchemeHollow',0)]
        for setting,label,offset in cases:
            game.memory[addr('wColorScheme')]=setting;call('RefreshEXPBarPalette')
            assert bytes(game.memory[addr('wGBCPal'):addr('wGBCPal')+8])==data(label,8,offset),(version,setting)
            game.memory[0xff68]=0x20
            hardware=[]
            for i in range(8):
                game.memory[0xff68]=0x20+i;hardware.append(game.memory[0xff69])
            assert bytes(hardware)==data(label,8,offset),(version,'hardware BG palette 4',setting,hardware)
        default=data('GBCBasePalettes',8,12*8)
        blue=int.from_bytes(default[2:4],'little')
        assert blue & 31 < (blue >> 10) & 31, (version,'default EXP shade is blue')
        print(f'{version}: EXP divider, dedicated palette and all color modes passed; title tiles verified')
    finally:game.stop(save=False)

if __name__=='__main__':
    for version in ('pokered','pokeblue'):validate(version)
