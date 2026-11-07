#!/usr/bin/env python3
"""Verify final Gym parties after natural learnsets and special-move overrides."""
import re
from pyboy import PyBoy
from test_unique_species import ROOT, SPECIES, symbols
from test_move_patch_3 import MOVES

TRAINERS = {name: i for i, name in enumerate(re.findall(r'^\s*trainer_const (\w+)', (ROOT/'constants/trainer_constants.asm').read_text(), re.M), 1)}


def validate(version):
    syms = symbols(ROOT/(version+'.sym'))
    game = PyBoy(str(ROOT/(version+'.gbc')), window='null', sound_emulated=False)
    game.set_emulation_speed(0)
    game.tick(90, False)
    def addr(name): return syms[name][1]
    def put(name, value): game.memory[addr(name)] = value
    def get(name, count=1): return bytes(game.memory[addr(name):addr(name)+count])
    def call(name):
        bank, target = syms[name]
        game.memory[0x2000] = game.memory[0xffb8] = bank or 1
        game.memory[0, 0x100:0x108] = [0xf3, 0xcd, target & 255, target >> 8, 0xc3, 4, 1, 0]
        game.memory[0xffff] = game.memory[0xff0f] = 0
        game.register_file.SP = 0xdffe
        game.register_file.PC = 0x100
        for _ in range(120):
            game.tick(1, False)
            if game.register_file.PC in (0x104, 0x105, 0x106): return
        raise AssertionError((version, name, hex(game.register_file.PC)))
    def load(trainer, number):
        # Default, unscaled battles; execute ReadTrainer and all of its
        # party generation and additional-move writes without stubbing them.
        game.memory[addr('wEventFlags'):addr('wEventFlags')+320] = [0]*320
        put('wLinkState', 0)
        put('wIsInBattle', 2)
        put('wPartyCount', 0)
        put('wTrainerClass', TRAINERS[trainer])
        put('wTrainerNo', number)
        game.memory[addr('wTrainerBaseMoney'):addr('wTrainerBaseMoney')+3] = [0, 0, 0x50]
        call('ReadTrainer')
    try:
        cases = [
            ('BROCK', 1, 2, 167, 15, ['TACKLE', 'SCREECH', 'HARDEN', 'WRAP']),
            ('LT_SURGE', 1, 3, 168, 25, ['GROWL', 'QUICK_ATTACK', 'THUNDER_WAVE', 'THUNDERPUNCH']),
            ('ERIKA', 1, 1, 170, 29, ['ABSORB', 'BIND', 'LEECH_LIFE', 'SLEEP_POWDER']),
            ('ERIKA', 1, 3, 172, 33, ['VINE_WHIP', 'POISONPOWDER', 'GROWTH', 'PETAL_DANCE']),
            ('ERIKA', 1, 2, 160, 33, ['STUN_SPORE', 'LEECH_SEED', 'REFLECT', 'VINE_CRUSH']),
            ('GIOVANNI', 3, 4, 163, 47, ['STOMP', 'CRUNCH', 'EARTHQUAKE', 'POISON_FANG']),
            ('KOGA', 1, 2, 159, 39, ['SLUDGE', 'DISABLE', 'TOXIC', 'ACID_ARMOR']),
        ]
        for trainer, number, slot, dex, level, moves in cases:
            load(trainer, number)
            index = next(d['index'] for d in SPECIES if d['dex'] == dex)
            assert get(f'wEnemyMon{slot}')[0] == index, trainer
            assert get(f'wEnemyMon{slot}Level')[0] == level, trainer
            assert get(f'wEnemyMon{slot}Moves', 4) == bytes(MOVES[m] for m in moves), (trainer, get(f'wEnemyMon{slot}Moves', 4))
        # Inserting Crunch shifts natural slots before old trainer overrides.
        # Preserve Blaine's other three attacks/options without duplicate Agility.
        load('BLAINE', 1)
        assert get('wEnemyMon4Level')[0] == 47
        assert get('wEnemyMon4Moves', 4) == bytes(MOVES[m] for m in ['AGILITY', 'FIRE_BLAST', 'CRUNCH', 'DOUBLE_EDGE'])
        assert get('wEnemyMon4PP', 4)[2] == 15
        load('AGATHA', 1)
        assert get('wEnemyMon4Moves', 4) == bytes(MOVES[m] for m in ['POISON_FANG', 'CRUNCH', 'SCREECH', 'EARTHQUAKE'])
        load('LANCE', 1)
        assert get('wEnemyMon1Moves', 4) == bytes(MOVES[m] for m in ['HYDRO_PUMP', 'CRUNCH', 'FIRE_BLAST', 'HYPER_BEAM'])
        # Preserve unrelated custom moves on the same teams and another leader.
        load('GIOVANNI', 3)
        assert get('wEnemyMon2Moves')[0] == MOVES['FISSURE']
        assert get('wEnemyMon3Moves')[0] == MOVES['EARTHQUAKE']
        assert get('wEnemyMon3Moves', 3)[2] == MOVES['THUNDER']
        assert get('wEnemyMon5Moves', 4)[3] == MOVES['EARTHQUAKE']
        load('KOGA', 1)
        assert get('wEnemyMon1Moves')[0] == MOVES['EXPLOSION']
        assert get('wEnemyMon3Moves')[0] == MOVES['SUBSTITUTE']
        load('MISTY', 1)
        assert get('wEnemyMon2Moves', 4)[3] == MOVES['BUBBLEBEAM']
        for title in ('ReviewedNidoranMUnique', 'ReviewedOmanyteUnique', 'ReviewedOnixBrock', 'ReviewedRaichuUnique', 'ReviewedSquirtleUnique', 'ReviewedTangelaErika', 'ReviewedTentacoolBig', 'ReviewedVenusaurErika'):
            bank, target = syms[title+'EvosMoves']
            assert game.memory[bank, target] == 0
        print(f'{version}: final ReadTrainer sets for seven reviewed Gym variants, Crunch trainer sets, default levels, independent no-evolution records and unrelated overrides passed')
    finally:
        game.stop(save=False)


if __name__ == '__main__':
    for version in ('pokered', 'pokeblue'): validate(version)
