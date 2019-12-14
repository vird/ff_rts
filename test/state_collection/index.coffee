{
  State
  Unit
  end_game_condition_hash
} = require '../../src/index'

{
  eliminate
} = end_game_condition_hash

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

@empty_eliminate_s0 = ()->
  state = new State
  state.unit_list.push unit = new Unit
  {
    tick_limit    : 10
    state
    end_condition : eliminate
  }

@empty_eliminate_s1 = ()->
  state = new State
  state.unit_list.push unit = new Unit
  unit.side = 1
  {
    tick_limit    : 10
    state
    end_condition : eliminate
  }

@empty_eliminate_s0_s1 = ()->
  state = new State
  state.unit_list.push unit = new Unit
  state.unit_list.push unit = new Unit
  unit.side = 1
  {
    tick_limit    : 10
    state
    end_condition : eliminate
  }

# ###################################################################################################

