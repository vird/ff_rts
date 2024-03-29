assert = require 'assert'

{
  Emulator
  State
} = require '../src/index.coffee'
state_collection = require './state_collection/index.coffee'

describe 'Emulator section', ()->
  it "sample 'empty'", ()->
    emu = new Emulator
    obj_set emu, state_collection.empty()
    result = emu.go()
    assert.equal result, 'draw'
    assert.equal emu.state.tick_idx, emu.tick_limit
  
  # ###################################################################################################
  #    win condition = eliminate
  # ###################################################################################################
  
  it "sample 'empty_eliminate'", ()->
    emu = new Emulator
    obj_set emu, state_collection.empty_eliminate()
    result = emu.go()
    assert.equal result, 'draw'
    assert.equal emu.state.tick_idx, 0
  
  it "sample 'eliminate_s0'", ()->
    emu = new Emulator
    obj_set emu, state_collection.eliminate_s0()
    result = emu.go()
    assert.equal result, 's0'
    assert.equal emu.state.tick_idx, 0
  
  it "sample 'eliminate_s1'", ()->
    emu = new Emulator
    obj_set emu, state_collection.eliminate_s1()
    result = emu.go()
    assert.equal result, 's1'
    assert.equal emu.state.tick_idx, 0
  
  it "sample 'eliminate_s0_s1'", ()->
    emu = new Emulator
    obj_set emu, state_collection.eliminate_s0_s1()
    result = emu.go()
    assert.equal result, 'draw'
    assert.equal emu.state.tick_idx, emu.tick_limit
  
  # ###################################################################################################
  #    mechanics
  # ###################################################################################################
  
  it "death_test", ()->
    emu = new Emulator
    obj_set emu, state_collection.death_test()
    result = emu.go()
    assert.equal result, 's1'
    assert.equal emu.state.tick_idx, 0
    return
  
  it "regen_test", ()->
    emu = new Emulator
    obj_set emu, state_collection.regen_test()
    result = emu.go()
    for unit in emu.state.unit_list
      assert.equal unit.hp100, unit.hp_max100
    assert.equal emu.state.tick_idx, emu.tick_limit
    return
  
  # ###################################################################################################
  #    targeting
  # ###################################################################################################
  
  it "targeting", ()->
    emu = new Emulator
    obj_set emu, state_collection.eliminate_s0_s1()
    result = emu.go()
    [u0, u1] = emu.state.unit_list
    assert.equal u0.target_unit_uid, u1.uid
    assert.equal u1.target_unit_uid, u0.uid
    assert.equal emu.state.tick_idx, emu.tick_limit
    return
  
  it "retargeting 2", ()->
    emu = new Emulator
    obj_set emu, state_collection.oneshot_kill_x2_target()
    result = emu.go()
    [u0, u1] = emu.state.unit_list
    assert.equal result, 's0'
    assert.equal emu.state.tick_idx, 3*2-1
    return
  
  it "retargeting 3", ()->
    emu = new Emulator
    obj_set emu, state_collection.oneshot_kill_x3_target_random_placement()
    result = emu.go()
    [u0, u1] = emu.state.unit_list
    assert.equal result, 's0'
    assert.equal emu.state.tick_idx, 3*3-1
    return
  
  # ###################################################################################################
  #    attack + damage deal
  # ###################################################################################################
  
  it "oneshot_kill", ()->
    emu = new Emulator
    obj_set emu, state_collection.oneshot_kill()
    result = emu.go()
    assert.equal result, 's0'
    assert.equal emu.state.tick_idx, 2
    return
  
  it "hit2_kill", ()->
    emu = new Emulator
    obj_set emu, state_collection.hit2_kill()
    result = emu.go()
    assert.equal result, 's0'
    # 0 idle -> attack_pre
    # 1 attack_pre -> attacking
    # 2 attacking -> idle
    # 3 idle -> attack_pre
    # 4 attack_pre -> attacking
    # 5 attacking -> lethan damage deal
    assert.equal emu.state.tick_idx, 5
    return
  
  # ###################################################################################################
  #    ranged
  # ###################################################################################################
  
  it "ranged_oneshot_kill", ()->
    emu = new Emulator
    obj_set emu, state_collection.ranged_oneshot_kill()
    result = emu.go()
    assert.equal result, 's0'
    speed     = 1000 # units/sec
    tick_rate = 100
    distance  = 100
    t = distance/(speed/tick_rate)
    # animation 10+1+1 projectile spawn
    assert.equal emu.state.tick_idx, 2+10+t
    return
  
  it "ranged_multishot_kill", ()->
    emu = new Emulator
    obj_set emu, state_collection.ranged_multishot_kill()
    result = emu.go()
    assert.equal result, 's0'
    speed     = 1000 # units/sec
    tick_rate = 100
    distance  = 100
    t = distance/(speed/tick_rate)
    # 4 attacks 10 pre + 10 post + 1 attack
    # 5th attack only 10 pre
    assert.equal emu.state.tick_idx, 2+4*21+10+t
    return
  # ###################################################################################################
  #    cast
  # ###################################################################################################
  
  it "mp should refill on src and dst", ()->
    emu = new Emulator
    obj_set emu, state_collection.hit2_kill()
    emu.tick_limit = 3
    result = emu.go()
    [u0, u1] = emu.state.unit_list
    assert.equal u0.mp100, 2500
    assert.equal u1.mp100, 2500
    return
  
  it "hit10_kill should kill after 10 hit", ()->
    emu = new Emulator
    obj_set emu, state_collection.hit10_kill()
    result = emu.go()
    assert.equal result, 's0'
    assert.equal emu.state.tick_idx, 3*10-1
    return
  
  it "hit10_kill_but_cast should kill after 4 hit + cast", ()->
    emu = new Emulator
    obj_set emu, state_collection.hit10_kill_but_cast()
    result = emu.go()
    assert.equal result, 's1'
    assert.equal emu.state.tick_idx, 3*5-1
    return
  
  # ###################################################################################################
  #    status effect : stun
  # ###################################################################################################
  
  it "oneshot_kill_but_cast_stun should kill after 10 hit cast", ()->
    emu = new Emulator
    obj_set emu, state_collection.oneshot_kill_but_cast_stun()
    result = emu.go()
    assert.equal result, 's1'
    # +1 for cast start
    # -1 because no post cast idle
    assert.equal emu.state.tick_idx, 1+3*10-1
    return
  
  it "fast_attack_vs_super_stun_no_mana_use should kill after 10 hit cast and receive only limited amount of hits", ()->
    emu = new Emulator
    obj_set emu, state_collection.fast_attack_vs_super_stun_no_mana_use()
    result = emu.go()
    [u1] = emu.state.unit_list
    # успевает царапнуть 5-й раз
    assert.equal u1.hp100, 100-5
    assert.equal result, 's1'
    # +3*4-1 for mana gain
    # +1 for cast start
    # -1 because no post cast idle
    assert.equal emu.state.tick_idx, (3*4-1)+1+3*10-1
    return
  
  it "fast_attack_vs_super_stun should kill after 10 hit cast and receive only 40 hits", ()->
    emu = new Emulator
    obj_set emu, state_collection.fast_attack_vs_super_stun()
    result = emu.go()
    assert.equal result, 's1'
    # 1st 4+1 hit
    # 8 hits normal (3+1 hits + 10 stun)
    # last only receive mana, no extra stun time
    assert.equal emu.state.tick_idx, 3*4+3+10 + (3*3+3+10)*8 + 3*3 + 3-1
    return
  
  # ###################################################################################################
  #    attack modifier
  # ###################################################################################################
  
  it "static_crit_demo should be oneshot", ()->
    emu = new Emulator
    obj_set emu, state_collection.static_crit_demo()
    result = emu.go()
    assert.equal result, 's0'
    assert.equal emu.state.tick_idx, 2
    return
  
  # ###################################################################################################
  #    damage block modifier
  # ###################################################################################################
  
  it "damage_block_demo should be not oneshot", ()->
    emu = new Emulator
    obj_set emu, state_collection.damage_block_demo()
    result = emu.go()
    assert.equal result, 's0'
    assert.equal emu.state.tick_idx, 3*10-1
    return
  
