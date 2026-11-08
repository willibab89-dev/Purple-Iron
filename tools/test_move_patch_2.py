#!/usr/bin/env python3
"""Validate patch 2's bounded move delta and real banked effect handlers."""
import json
import re
from collections import Counter
from pyboy import PyBoy
from test_unique_species import ROOT, symbols
from test_move_patch_1 import EFFECTS, TYPES

PLAN = json.loads((ROOT / 'data/move_patch_2.json').read_text())
CHANGES = {x['symbol']: x for x in PLAN['changes']}
DROPS = {'SLAM': (1, -1), 'BIND': (2, -1), 'CONSTRICT': (2, -1),
         'BUBBLEBEAM': (2, -1), 'STRING_SHOT': (2, -1), 'SAND_ATTACK': (4, -1),
         'FLASH': (4, -1), 'PETAL_DANCE': (5, -1), 'FISSURE': (0, -2),
         'HORN_DRILL': (1, -2), 'GUILLOTINE': (3, -2), 'BUBBLE': (2, -1)}
MULTI = {'GROWTH': (3, 1), 'KINESIS': (4, 0), 'MEDITATE': (0, 2),
         'WITHDRAW': (1, 4), 'SPLASH': (0, 4), 'SHARPEN': (0, 4)}


def validate(version):
    syms = symbols(ROOT / (version + '.sym'))
    game = PyBoy(str(ROOT / (version + '.gbc')), window='null', sound_emulated=False)
    game.set_emulation_speed(0)
    game.tick(90, False)
    visits = Counter()
    originals = {}
    def addr(n): return syms[n][1]
    def put(n, v): game.memory[addr(n)] = v
    def get(n): return game.memory[addr(n)]
    def word(n, v): game.memory[addr(n):addr(n)+2] = [v >> 8, v & 255]
    def readword(n): return (get(n) << 8) | game.memory[addr(n)+1]
    def patch(n, code):
        bank, target = syms[n]
        originals.setdefault(n, list(game.memory[bank, target:target+len(code)]))
        game.memory[bank, target:target+len(code)] = code
    def call(n, **registers):
        bank, target = syms[n]
        game.memory[0x2000] = game.memory[0xffb8] = bank or 1
        game.memory[0, 0x100:0x108] = [0xf3, 0xcd, target & 255, target >> 8, 0xc3, 4, 1, 0]
        game.memory[0xffff] = game.memory[0xff0f] = 0
        game.register_file.SP = 0xdffe
        game.register_file.PC = 0x100
        for k, v in registers.items(): setattr(game.register_file, k, v)
        for _ in range(120):
            game.tick(1, False)
            if game.register_file.PC in (0x104, 0x105, 0x106): return
        raise AssertionError((version, n, hex(game.register_file.PC), game.memory[0xffb8], get('wPlayerMoveNum'), get('wEnemyMoveNum')))
    def rng(value): patch('BattleRandom', [0x3e, value, 0xc9])
    def mods(side): return list(game.memory[addr(f'w{side}MonStatMods'):addr(f'w{side}MonStatMods')+6])
    def init(move, turn=0):
        game.memory[0xfff3] = turn
        put('wFlags_D733', 0)
        put('wObtainedBadges', 0)
        put('wOptions', 0)
        put('wLinkState', 0)
        put('wIsInBattle', 2)
        put('wMoveMissed', 0)
        put('wCustomTargetHadSub', 0)
        put('wCustomChanged', 0)
        put('wCriticalHitOrOHKO', 0)
        for side in ('Player', 'Enemy'):
            for suffix in ('BattleStatus1', 'BattleStatus2', 'BattleStatus3', 'ConfusedCounter'):
                put(f'w{side}{suffix}', 0)
            game.memory[addr(f'w{side}MonStatMods'):addr(f'w{side}MonStatMods')+6] = [7]*6
            for i in range(4):
                word_addr = addr(f'w{side}MonUnmodifiedAttack') + i*2
                game.memory[word_addr:word_addr+2] = [0, 100]
        for prefix in ('wBattleMon', 'wEnemyMon'):
            word(prefix+'HP', 200)
            word(prefix+'MaxHP', 200)
            put(prefix+'Status', 0)
            put(prefix+'Level', 50)
            for stat in ('Attack', 'Defense', 'Speed', 'Special'): word(prefix+stat, 100)
        actor = 'Enemy' if turn else 'Player'
        put(f'w{actor}SelectedMove', CHANGES[move]['id'])
        call('GetCurrentMove')
        rng(0)
        return actor, 'Player' if turn else 'Enemy'
    def effect(): call('JumpMoveEffect')
    try:
        for name in ('PrintText', 'PlayCurrentMoveAnimation', 'PlayCurrentMoveAnimation2',
                     'DelayFrames', 'PrintButItFailedText_'):
            patch(name, [0xc9])
            bank, target = syms[name]
            game.hook_register(bank, target, lambda n: visits.update([n]), name)
        # Every record is exactly baseline + the 22 approved replacements.
        changes_by_id = {x['id']: x['after'] for x in PLAN['changes']}
        assert len(changes_by_id) == 22
        patch4 = json.loads((ROOT / 'data/move_patch_4.json').read_text())
        changes_by_id.update({entry['id']: entry['after'] for entry in patch4['existing_changes']})
        bank, base = syms['Moves']
        patch5 = json.loads((ROOT / 'data/move_patch_5.json').read_text())
        changes_by_id.update({entry['id']: entry['after'] for entry in patch5['existing_changes']})
        patch6 = json.loads((ROOT / 'data/move_patch_6.json').read_text())
        changes_by_id.update({entry['id']: entry['after'] for entry in patch6['existing_changes']})
        patch7=json.loads((ROOT/'data/move_patch_7.json').read_text())
        changes_by_id.update({x['id']:x['after'] for x in patch7['existing_changes']})
        patch8=json.loads((ROOT/'data/move_patch_8.json').read_text())
        changes_by_id.update({x['id']:x['after'] for x in patch8['existing_changes']})
        for old in PLAN['baseline']:
            d = changes_by_id.get(old['id'], old)
            expected = [old['id'], EFFECTS[d['effect']], d['power'], TYPES[d['type']], d['accuracy']*255//100, d['pp']]
            offset = base + (old['id']-1)*6
            assert list(game.memory[bank, offset:offset+6]) == expected, old['symbol']
        # Load every affected move from both sides, including renamed animations.
        for turn in (0, 1):
            for name, entry in CHANGES.items():
                actor, _ = init(name, turn)
                d = entry['after']
                assert get(f'w{actor}MoveEffect') == EFFECTS[d['effect']]
                assert get(f'w{actor}MovePower') == d['power']
            for name, (stat, delta) in DROPS.items():
                actor, target = init(name, turn)
                effect()
                expected = [7]*6; expected[stat] += delta
                assert mods(target) == expected, (version, turn, name, mods(target))
                assert mods(actor) == [7]*6
                # Miss, pre-hit Substitute, Mist, and target KO suppress drops.
                for condition in ('miss', 'sub', 'mist', 'ko'):
                    init(name, turn)
                    if condition == 'miss': put('wMoveMissed', 1)
                    if condition == 'sub': put('wCustomTargetHadSub', 1)
                    if condition == 'mist': put(f'w{target}BattleStatus2', 2) # PROTECTED_BY_MIST bit 1
                    if condition == 'ko': word('wBattleMonHP' if target == 'Player' else 'wEnemyMonHP', 0)
                    effect()
                    assert mods(target) == [7]*6, (turn, name, condition, mods(target))
                init(name, turn)
                put(f'w{target}MonStatMods', 7)
                game.memory[addr(f'w{target}MonStatMods')+stat] = 1
                effect()
                assert mods(target)[stat] == 1
            # Full chance boundaries, with deterministic BattleRandom in the real bank.
            for name, threshold, stat in (('FLASH', 128, 4), ('BUBBLE', 77, 2)):
                for roll in (0, threshold-1, threshold, 255):
                    actor, target = init(name, turn); rng(roll); effect()
                    assert mods(target)[stat] == (6 if roll < threshold else 7), (name, roll)
            for name, threshold in (('DIZZY_PUNCH', 77), ('COMET_PUNCH', 256)):
                for roll in (0, 76, 77, 255):
                    actor, target = init(name, turn); rng(roll); effect()
                    assert bool(get(f'w{target}BattleStatus1') & 0x80) == (roll < threshold)
                    if roll < threshold: assert 2 <= get(f'w{target}ConfusedCounter') <= 5
                actor, target = init(name, turn); put('wCustomTargetHadSub', 1); effect()
                assert get(f'w{target}BattleStatus1') == 0
            for name, stats in MULTI.items():
                actor, target = init(name, turn)
                lowered = name in ('KINESIS', 'SPLASH')
                affected = target if lowered else actor
                effect()
                expected = [7]*6
                for stat in stats: expected[stat] += -1 if lowered else 1
                assert mods(affected) == expected, (name, turn, mods(affected))
                # First stat capped must not block the second.
                init(name, turn)
                game.memory[addr(f'w{affected}MonStatMods')+stats[0]] = 1 if lowered else 13
                effect()
                assert mods(affected)[stats[1]] == (6 if lowered else 8)
                if lowered:
                    for condition in ('sub', 'mist', 'miss'):
                        init(name, turn)
                        if condition == 'sub': put(f'w{target}BattleStatus2', 0x10)
                        if condition == 'mist': put(f'w{target}BattleStatus2', 2)
                        if condition == 'miss':
                            put(f'w{actor}MoveAccuracy', 100)
                            rng(255)
                        effect()
                        assert mods(target) == [7]*6, (name, condition, mods(target))
            # Actor drop occurs even if opponent fainted or had a Substitute.
            for condition in ('normal', 'ko', 'sub', 'miss'):
                actor, target = init('FURY_ATTACK', turn)
                if condition == 'ko': word('wBattleMonHP' if target == 'Player' else 'wEnemyMonHP', 0)
                if condition == 'sub': put('wCustomTargetHadSub', 1)
                if condition == 'miss': put('wMoveMissed', 1)
                effect()
                assert mods(actor)[0] == (7 if condition == 'miss' else 6)
            actor, target = init('AMNESIA', turn)
            game.memory[addr(f'w{actor}MonStatMods'):addr(f'w{actor}MonStatMods')+6] = [1, 9, 4, 2, 5, 13]
            effect()
            assert mods(actor) == [7, 9, 7, 8, 7, 13]
            actor, target = init('AMNESIA', turn)
            game.memory[addr(f'w{actor}MonStatMods'):addr(f'w{actor}MonStatMods')+6] = [1, 7, 7, 13, 7, 7]
            effect()
            assert mods(actor) == [7, 7, 7, 13, 7, 7]
            assert readword('wBattleMonAttack' if actor == 'Player' else 'wEnemyMonAttack') == 100
            # A burnt/paralysed actor retains exactly one penalty through two raises.
            actor, target = init('MEDITATE', turn)
            prefix = 'wBattleMon' if actor == 'Player' else 'wEnemyMon'
            put(prefix+'Status', 0x50) # BRN and PAR; synthetic to exercise both penalties
            for expected in ((75, 37), (100, 50)):
                effect()
                assert (readword(prefix+'Attack'), readword(prefix+'Speed')) == expected
            # Badge boosts are rebuilt once, without compounding across uses.
            actor, target = init('MEDITATE', turn)
            if not turn:
                put('wObtainedBadges', 0x55)
                put('wBattleMonStatus', 0x50)
                for expected in ((78, 39), (105, 52)):
                    effect()
                    assert (readword('wBattleMonAttack'), readword('wBattleMonSpeed')) == expected
                    assert readword('wBattleMonDefense') == 105
                    assert readword('wBattleMonSpecial') == 105
            # The pre-damage snapshot survives the Substitute disappearing.
            actor, target = init('SLAM', turn)
            put(f'w{target}BattleStatus2', 0x10)
            call('CaptureCustomTargetSubstitute')
            put(f'w{target}BattleStatus2', 0)
            effect()
            assert mods(target)[1] == 7
            assert game.memory[0xfff3] == turn
        # Run real move execution, damage application and post-hit routing.
        # Presentation, PP setup and crit/random variation are stubbed; crit arithmetic has its own exhaustive suite.
        for name in ('PrintMonName1Text', 'DecrementPP', 'PlayMoveAnimation',
                     'DrawPlayerHUDAndHPBar', 'DrawEnemyHUDAndHPBar', 'DrawHUDsAndHPBars',
                     'UpdateHPBar2', 'PrintCriticalOHKOText', 'DisplayEffectiveness',
                     'RandomizeDamage', 'CriticalHitTest', 'HideSubstituteShowMonAnim'):
            patch(name, [0xc9])
        for turn in (0, 1):
            for move in CHANGES:
                actor, target = init(move, turn)
                for prefix in ('wBattleMon', 'wEnemyMon'):
                    put(prefix+'Species', 153) # Bulbasaur's internal species ID
                    game.memory[addr(prefix+'Type'):addr(prefix+'Type')+2] = [0, 0]
                other = 'Player' if turn else 'Enemy'
                put(f'w{other}MoveNum', 1)
                put(f'w{other}MoveEffect', 0)
                put(f'w{other}MovePower', 40)
                put('wUnusedC000', 0)
                call('EnemyCanExecuteMove' if turn else 'PlayerCanExecuteMove')
                hp = readword('wBattleMonHP' if target == 'Player' else 'wEnemyMonHP')
                if CHANGES[move]['after']['power']:
                    assert hp < 200, ('pipeline damage', turn, move, hp)
                else:
                    assert hp == 200
                if move in DROPS:
                    stat, delta = DROPS[move]
                    assert mods(target)[stat] == 7+delta, ('pipeline drop', turn, move, mods(target))
                if move == 'FURY_ATTACK': assert mods(actor)[0] == 6
                assert get(f'w{actor}BattleStatus1') & 0x32 == 0, (move, get(f'w{actor}BattleStatus1'))
            # Substitute-breaking Fury Attack must retain its self-drop effect.
            actor, target = init('FURY_ATTACK', turn)
            put(f'w{target}BattleStatus2', 0x10)
            put(f'w{target}SubstituteHP', 1)
            word('wDamage', 100)
            call('CaptureCustomTargetSubstitute')
            call('ApplyAttackToPlayerPokemon' if turn else 'ApplyAttackToEnemyPokemon')
            assert get(f'w{actor}MoveEffect') == EFFECTS['ATTACK_AND_SELF_DROP_EFFECT']
            effect()
            assert mods(actor)[0] == 6

        # AI sees partial usefulness and rejects only wholly ineffective status moves.
        for move in MULTI:
            init(move, 1)
            call('CustomAIStatusScore'); assert get('wCustomRandomValue') == 0
            lowered = move in ('KINESIS', 'SPLASH')
            side = 'Player' if lowered else 'Enemy'
            for i in MULTI[move]: game.memory[addr(f'w{side}MonStatMods')+i] = 1 if lowered else 13
            call('CustomAIStatusScore'); assert get('wCustomRandomValue') == 1, move
        # Legacy effect dispatch still reaches its original bank and returns safely.
        init('SLAM')
        put('wPlayerMoveEffect', EFFECTS['FOCUS_ENERGY_EFFECT'])
        call('JumpMoveEffect')
        assert get('wPlayerBattleStatus3') & 0x30 == 0x10
        print(f'{version}: 22 move replacements, both actor paths, stage caps, Substitute/Mist/KO/miss gates, chance boundaries, confusion, Amnesia, single status penalties, AI and legacy bank dispatch passed')
    finally:
        game.stop(save=False)


if __name__ == '__main__':
    for version in ('pokered', 'pokeblue'): validate(version)
