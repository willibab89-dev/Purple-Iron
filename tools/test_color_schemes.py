#!/usr/bin/env python3
"""Color menu, palette routing, and existing save-data compatibility."""
from pyboy import PyBoy
from test_unique_species import ROOT, symbols


def validate(version):
    syms = symbols(ROOT / (version + '.sym'))
    game = PyBoy(str(ROOT / (version + '.gbc')), window='null', sound_emulated=False)
    game.set_emulation_speed(0)
    game.tick(90, False)
    def addr(name): return syms[name][1]
    def put(name, value): game.memory[addr(name)] = value
    def call(name, **registers):
        bank, target = syms[name]
        game.memory[0x2000] = game.memory[0xffb8] = bank or 1
        game.memory[0, 0x100:0x108] = [0xf3, 0xcd, target & 255, target >> 8, 0xc3, 4, 1, 0]
        game.memory[0xffff] = game.memory[0xff0f] = 0
        game.register_file.SP = 0xdffe
        game.register_file.PC = 0x100
        for reg, value in registers.items(): setattr(game.register_file, reg, value)
        for _ in range(500):
            game.tick(1, False)
            if game.register_file.PC in (0x104, 0x105, 0x106): return
        raise AssertionError((version, name, hex(game.register_file.PC)))
    try:
        for setting, expected in [(0,'GBCBasePalettes'),(0xa0,'GBCBasePalettes'),(0xa1,'ColorSchemeGray'),(0xa2,'SuperPalettes'),(0xa3,'ColorSchemeGreen'),(255,'GBCBasePalettes')]:
            put('wColorScheme', setting)
            for palette in (0, 4, 39):
                call('GetGBCBasePalAddress', A=palette)
                actual = game.register_file.D * 256 + game.register_file.E
                offset = 0 if setting in (0xa1,0xa3) else palette * 8
                assert actual == addr(expected) + offset, (version, setting, palette, hex(actual))
        # The reserved byte is already part of the checksummed main save data.
        assert addr('wMainDataStart') <= addr('wColorScheme') < addr('wMainDataEnd')
        assert addr('GBCBasePalettes') - addr('SuperPalettes') == 42 * 8
        for setting in (0, 0xa1, 0xa2, 0xa3):
            put('wColorScheme', setting)
            call('SaveSAVtoSRAM0')
            put('wColorScheme', 0)
            call('LoadSAV0')
            assert game.memory[addr('wColorScheme')] == setting, (version, setting, 'save/load')
        # Simulate a user moving down to the color row, cycling both ways,
        # and leaving the menu. Low-sensitivity input is deterministic here.
        inputs = [0x80,0x80,0x80,0x10,0x10,0x20,0x08]
        state = {'i':0}
        def input_hook(_):
            i = state['i']
            game.memory[0xffb5] = inputs[min(i, len(inputs)-1)]
            state['i'] = i + 1
        game.memory[syms['DelayFrame'][0], addr('DelayFrame')] = 0xc9
        bank, where = syms['JoypadLowSensitivity']
        game.memory[bank, where] = 0xc9
        game.hook_register(bank, where, input_hook, None)
        # Drawing and palette commands still execute; sound has no bearing on navigation.
        put('wColorScheme', 0)
        put('wOptions', 3)
        put('wOnSGB', 1)
        call('DisplayOptionMenu')
        assert state['i'] >= len(inputs), (version, state)
        assert game.memory[addr('wColorScheme')] == 0xa1, (version, game.memory[addr('wColorScheme')])
        assert game.memory[addr('wTopMenuItemY')] == 15
        print(f'{version}: palette routing, saved setting and options navigation passed')
    finally:
        game.stop(save=False)

if __name__ == '__main__':
    for version in ('pokered', 'pokeblue'):
        validate(version)
