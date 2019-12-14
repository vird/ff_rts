module = @
{
  State
  Unit
  end_game_condition_hash
} = require '../../src/index'

{
  eliminate
} = end_game_condition_hash

tick_per_sec = 100
# ###################################################################################################
#    emulator test pack
# ###################################################################################################
@empty = ()->
  {
    tick_limit    : 10
    state         : new State
  }

@empty_eliminate = ()->
  {
    tick_limit    : 10
    state         : new State
    end_condition : eliminate
  }

@eliminate_s0 = ()->
  state = new State
  state.unit_list.push unit = new Unit
  {
    tick_limit    : 10
    state
    end_condition : eliminate
  }

@eliminate_s1 = ()->
  state = new State
  state.unit_list.push unit = new Unit
  unit.side = 1
  {
    tick_limit    : 10
    state
    end_condition : eliminate
  }

@eliminate_s0_s1 = ()->
  state = new State
  state.unit_list.push unit = new Unit
  state.unit_list.push unit = new Unit
  unit.side = 1
  {
    tick_limit    : 10
    state
    end_condition : eliminate
  }

@death_test = ()->
  ret = module.eliminate_s0_s1()
  {state} = ret
  [u0, u1] = state.unit_list
  u0.hp100 = 0
  ret

@regen_test = ()->
  ret = module.eliminate_s0_s1()
  {state} = ret
  [u0, u1] = state.unit_list
  u0.hp_max100 = 1000
  u0.hp_reg100 = 100*tick_per_sec
  ret

# ###################################################################################################

