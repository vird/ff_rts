assert = require 'assert'

{
  Emulator
  FF_emulator
  State
} = require '../src/index.coffee'
state_collection = require './state_collection/index.coffee'

real_tick_total = 0
ff_tick_total = 0

describe 'FF_emulator section', ()->
  for k,v of state_collection
    continue unless v instanceof Function
    do (k,v)->
      it "sample '#{k}'", ()->
        emu = new Emulator
        obj_set emu, v()
        emu.go()
        real_tick_total += emu.state.tick_idx + 1
        
        ff_emu = new FF_emulator
        obj_set ff_emu, v()
        ff_emu.go()
        ff_tick_total += ff_emu.ff_tick
        
        emu.state.assert_cmp ff_emu.state
        # p [ 
          # "emu = #{emu.state.tick_idx + 1}"
          # "ff = #{ff_emu.ff_tick}"
          # "compress = #{(emu.state.tick_idx + 1)/ff_emu.ff_tick}"
        # ].join ' '
  
  # it 'stat', ()->
    # p "real_tick_total = #{real_tick_total}"
    # p "  ff_tick_total = #{  ff_tick_total}"
    # p "       compress = #{real_tick_total/ff_tick_total}"