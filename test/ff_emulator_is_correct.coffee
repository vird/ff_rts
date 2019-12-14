assert = require 'assert'

{
  Emulator
  FF_emulator
  State
} = require '../src/index.coffee'
state_collection = require './state_collection/index.coffee'

describe 'FF_emulator section', ()->
  for k,v of state_collection
    continue unless v instanceof Function
    do (k,v)->
      it "sample '#{k}'", ()->
        emu = new Emulator
        obj_set emu, v()
        emu.go()
        
        ff_emu = new FF_emulator
        obj_set ff_emu, v()
        ff_emu.go()
        
        assert emu.state.cmp ff_emu.state
  