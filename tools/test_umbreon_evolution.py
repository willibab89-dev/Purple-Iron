#!/usr/bin/env python3
"""Execute Eevee's real stone evolution and verify its saved species and types."""
from pyboy import PyBoy
from test_unique_species import ROOT, symbols
from test_move_patch_3 import constants

def validate(version):
    syms=symbols(ROOT/(version+'.sym')); ids=constants(ROOT/'constants/pokemon_constants.asm')
    game=PyBoy(str(ROOT/(version+'.gbc')),window='null',sound_emulated=False)
    game.set_emulation_speed(0);game.tick(90,False)
    def addr(name): return syms[name][1]
    def put(name,val): game.memory[addr(name)]=val
    def get(name): return game.memory[addr(name)]
    def patch(name,code):
        b,a=syms[name];game.memory[b,a:a+len(code)]=code
    def call(name):
        b,a=syms[name];game.memory[0x2000]=game.memory[0xffb8]=b or 1
        game.memory[0,0x100:0x108]=[0xf3,0xcd,a&255,a>>8,0xc3,4,1,0]
        game.memory[0xffff]=game.memory[0xff0f]=0;game.register_file.SP=0xdffe;game.register_file.PC=0x100
        for _ in range(600):
            game.tick(1,False)
            if game.register_file.PC in (0x104,0x105,0x106): return
        raise AssertionError((version,name,hex(game.register_file.PC)))
    try:
        for n in ('PrintText','PrintText_NoCreatingTextBox','DelayFrames','ClearScreenArea','ClearSprites','PlaySoundWaitForCurrent','WaitForSoundToFinish','ClearScreen','RenameEvolvedMon','GBPalWhiteOutWithDelay3','LoadScreenTilesFromBuffer1'):
            patch(n,[0xc9])
        patch('EvolveMon',[0xaf,0xc9]) # skip presentation, retain the real evolution logic
        put('wPartyCount',0);put('wMonDataLocation',0x80);put('wIsInBattle',0);put('wCurEnemyLVL',25);put('wcf91',ids['EEVEE']);call('AddPartyMon')
        assert get('wPartyCount')==1 and get('wPartyMon1Species')==ids['EEVEE']
        put('wWhichPokemon',0);put('wForceEvolution',1);put('wcf91',10);call('TryEvolvingMon')
        assert get('wEvolutionOccurred')==1 and get('wPartyMon1Species')==ids['UMBREON'],(version,get('wEvolutionOccurred'),get('wPartyMon1Species'))
        assert get('wPartySpecies')==ids['UMBREON']
        call('SaveSAVtoSRAM0');call('SaveSAVtoSRAM2');put('wPartyMon1Species',0);call('LoadSAV0');call('LoadSAV2')
        assert get('wPartyMon1Species')==ids['UMBREON']
        print(f'{version}: Eevee + Moon Stone evolves to Umbreon and survives save/load')
    finally: game.stop(save=False)

if __name__=='__main__':
    for version in ('pokered','pokeblue'):validate(version)
