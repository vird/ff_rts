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
  
  it "sample 'empty_eliminate'", ()->
    emu = new Emulator
    obj_set emu, state_collection.empty_eliminate()
    result = emu.go()
    assert.equal emu.state.tick_idx, 0
    assert.equal result, 'draw'
  
  it "sample 'empty_eliminate_s0'", ()->
    emu = new Emulator
    obj_set emu, state_collection.empty_eliminate_s0()
    result = emu.go()
    assert.equal emu.state.tick_idx, 0
    assert.equal result, 's0'
  
  it "sample 'empty_eliminate_s1'", ()->
    emu = new Emulator
    obj_set emu, state_collection.empty_eliminate_s1()
    result = emu.go()
    assert.equal emu.state.tick_idx, 0
    assert.equal result, 's1'
  
  it "sample 'empty_eliminate_s0_s1'", ()->
    emu = new Emulator
    obj_set emu, state_collection.empty_eliminate_s0_s1()
    result = emu.go()
    assert.equal emu.state.tick_idx, emu.tick_limit
    assert.equal result, 'draw'
  