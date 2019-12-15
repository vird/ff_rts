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
    assert.equal emu.state.tick_idx, emu.tick_limit
    assert.equal result, 'draw'
  
  # ###################################################################################################
  #    win condition = eliminate
  # ###################################################################################################
  
  it "sample 'empty_eliminate'", ()->
    emu = new Emulator
    obj_set emu, state_collection.empty_eliminate()
    result = emu.go()
    assert.equal emu.state.tick_idx, 0
    assert.equal result, 'draw'
  
  it "sample 'eliminate_s0'", ()->
    emu = new Emulator
    obj_set emu, state_collection.eliminate_s0()
    result = emu.go()
    assert.equal emu.state.tick_idx, 0
    assert.equal result, 's0'
  
  it "sample 'eliminate_s1'", ()->
    emu = new Emulator
    obj_set emu, state_collection.eliminate_s1()
    result = emu.go()
    assert.equal emu.state.tick_idx, 0
    assert.equal result, 's1'
  
  it "sample 'eliminate_s0_s1'", ()->
    emu = new Emulator
    obj_set emu, state_collection.eliminate_s0_s1()
    result = emu.go()
    assert.equal emu.state.tick_idx, emu.tick_limit
    assert.equal result, 'draw'
  
  # ###################################################################################################
  #    mechanics
  # ###################################################################################################
  
  it "death_test", ()->
    emu = new Emulator
    obj_set emu, state_collection.death_test()
    result = emu.go()
    assert.equal emu.state.tick_idx, 0
    assert.equal result, 's1'
    return
  
  it "regen_test", ()->
    emu = new Emulator
    obj_set emu, state_collection.regen_test()
    result = emu.go()
    assert.equal emu.state.tick_idx, emu.tick_limit
    for unit in emu.state.unit_list
      assert.equal unit.hp100, unit.hp_max100
    return
  
  # ###################################################################################################
  #    targeting
  # ###################################################################################################
  
  it "targeting", ()->
    emu = new Emulator
    obj_set emu, state_collection.eliminate_s0_s1()
    result = emu.go()
    assert.equal emu.state.tick_idx, emu.tick_limit
    [u0, u1] = emu.state.unit_list
    assert.equal u0.target_unit_uid, u1.uid
    assert.equal u1.target_unit_uid, u0.uid
  
  # ###################################################################################################
  #    attack + damage deal
  # ###################################################################################################
  
  it "oneshot_kill", ()->
    emu = new Emulator
    obj_set emu, state_collection.oneshot_kill()
    result = emu.go()
    assert.equal emu.state.tick_idx, 2
    assert.equal result, 's0'