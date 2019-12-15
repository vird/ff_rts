module = @
{
  State
  Unit
  end_game_condition_hash
  fsm_hash
} = require '../../src/index'

{
  eliminate
} = end_game_condition_hash

tick_per_sec = 100
# ###################################################################################################
#    fsm
# ###################################################################################################
fsm_noop  = fsm_hash.fsm_craft {}
fsm_melee = fsm_hash.fsm_craft {attack_type : 'melee'}
fsm_caster= fsm_hash.fsm_craft {
  cast_type   : 'cast'
  cast_effect : ({unit, target, state})->
    state.pending_effect_list.push ()->
      target.hp100 -= 10000 # large hit
      unit.mp100 = Math.max 0, unit.mp100 - 10000 # exhaust all mana
      return
    return
}

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
  unit.fsm_ref = fsm_noop
  {
    tick_limit    : 10
    state
    end_condition : eliminate
  }

@eliminate_s1 = ()->
  state = new State
  state.unit_list.push unit = new Unit
  unit.fsm_ref = fsm_noop
  unit.side = 1
  {
    tick_limit    : 10
    state
    end_condition : eliminate
  }

@eliminate_s0_s1 = ()->
  state = new State
  state.unit_list.push unit = new Unit
  unit.fsm_ref = fsm_noop
  state.unit_list.push unit = new Unit
  unit.fsm_ref = fsm_noop
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

@oneshot_kill = ()->
  ret = module.eliminate_s0_s1()
  {state} = ret
  [u0, u1] = state.unit_list
  u0.ad100 = 1e9
  u0.a_pre = 1
  u0.a_post= 1
  u0.fsm_ref = fsm_melee
  ret

@hit2_kill = ()->
  ret = module.eliminate_s0_s1()
  {state} = ret
  [u0, u1] = state.unit_list
  u0.ad100 = 50
  u0.a_pre = 1
  u0.a_post= 1
  u0.fsm_ref = fsm_melee
  ret

@hit10_kill = ()->
  ret = module.eliminate_s0_s1()
  ret.tick_limit = 100
  {state} = ret
  [u0, u1] = state.unit_list
  u0.ad100 = 10
  u0.a_pre = 1
  u0.a_post= 1
  u0.fsm_ref = fsm_melee
  ret

@hit10_kill_but_cast = ()->
  ret = module.hit10_kill()
  {state} = ret
  [u0, u1] = state.unit_list
  u1.fsm_ref = fsm_caster
  ret

# ###################################################################################################

