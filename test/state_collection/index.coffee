module = @
{
  State
  Unit
  status_effect_hash
  FSM_unit_state
  Damage_modifier
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
fsm_ranged= fsm_hash.fsm_craft {attack_type : 'ranged'}
fsm_caster= fsm_hash.fsm_craft {
  cast_type   : 'cast'
  cast_effect : ({unit, target, state})->
    state.pending_effect_list.push ()->
      target.hp100 -= 10000 # large hit
      unit.mp100 -= 10000 # exhaust all mana
      return [target]
    return
}
fsm_cast_super_stun_no_mana_use= fsm_hash.fsm_craft {
  cast_type   : 'cast'
  cast_effect : ({unit, target, state})->
    state.pending_effect_list.push ()->
      target.hp100 -= 10 # small hit
      
      duration = 10 # ticks
      until_ts = state.tick_idx + duration + 1
      target.status_effect_raw_add status_effect_hash.stun, until_ts
      # UNVERIFIED
      target.fsm_next_event_tick = until_ts # WARNING can be replaced with smaller value
      target.fsm_idx = FSM_unit_state.idling
      
      # no mana exhaust (for test purposes, for recast)
      # unit.mp100 -= 10000 # exhaust all mana
      return [target]
    return
}
fsm_cast_super_stun= fsm_hash.fsm_craft {
  cast_type   : 'cast'
  cast_effect : ({unit, target, state})->
    state.pending_effect_list.push ()->
      target.hp100 -= 10 # small hit
      
      duration = 10 # ticks
      until_ts = state.tick_idx + duration + 1
      target.status_effect_raw_add status_effect_hash.stun, until_ts
      # UNVERIFIED
      target.fsm_next_event_tick = until_ts # WARNING can be replaced with smaller value
      target.fsm_idx = FSM_unit_state.idling
      
      unit.mp100 -= 10000 # exhaust all mana
      return [target]
    return
}

# ###################################################################################################
#    basic test pack
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

@oneshot_kill_x2_target = ()->
  ret = module.oneshot_kill()
  {state} = ret
  state.unit_list.push unit = new Unit
  unit.fsm_ref = fsm_noop
  unit.side = 1
  ret

@oneshot_kill_x3_target_random_placement = ()->
  ret = module.oneshot_kill()
  {state} = ret
  state.unit_list.push unit = new Unit
  unit.fsm_ref = fsm_noop
  unit.side = 1
  state.unit_list.push unit = new Unit
  unit.fsm_ref = fsm_noop
  unit.side = 1
  [u0, u1, u2, u3] = state.unit_list
  u1.x = 1
  u2.x = 3
  u3.x = 2
  
  ret

# ###################################################################################################
#    ranged
# ###################################################################################################

@ranged_oneshot_kill = ()->
  ret = module.eliminate_s0_s1()
  ret.tick_limit = 100
  {state} = ret
  [u0, u1] = state.unit_list
  u0.ad100 = 1e9
  u0.a_pre = 10
  u0.a_post= 10
  u0.fsm_ref = fsm_ranged
  u1.x = 100
  ret

@ranged_multishot_kill = ()->
  ret = module.eliminate_s0_s1()
  ret.tick_limit = 150
  {state} = ret
  [u0, u1] = state.unit_list
  u0.ad100 = 20
  u0.a_pre = 10
  u0.a_post= 10
  u0.fsm_ref = fsm_ranged
  u1.x = 100
  ret
# ###################################################################################################
#    cast
# ###################################################################################################
@hit10_kill_but_cast = ()->
  ret = module.hit10_kill()
  {state} = ret
  [u0, u1] = state.unit_list
  u1.fsm_ref = fsm_caster
  ret

@oneshot_kill_but_cast_stun = ()->
  ret = module.eliminate_s0_s1()
  ret.tick_limit = 100
  {state} = ret
  [u0, u1] = state.unit_list
  # oneshot_kill, but slow
  u0.ad100 = 1e9
  u0.a_pre = 10
  u0.a_post= 10
  u0.fsm_ref = fsm_melee
  
  u1.fsm_ref = fsm_cast_super_stun_no_mana_use
  u1.mp100 = 10000
  ret

@fast_attack_vs_super_stun_no_mana_use = ()->
  ret = module.eliminate_s0_s1()
  ret.tick_limit = 1000
  {state} = ret
  [u0, u1] = state.unit_list
  # Царапается
  u0.ad100 = 1
  u0.a_pre = 1
  u0.a_post= 1
  u0.fsm_ref = fsm_melee
  
  # получает ману, но потом застанит так, что u0 не выйдет из стана
  u1.fsm_ref = fsm_cast_super_stun_no_mana_use
  ret

@fast_attack_vs_super_stun = ()->
  ret = module.eliminate_s0_s1()
  ret.tick_limit = 1000
  {state} = ret
  [u0, u1] = state.unit_list
  # Царапается
  u0.ad100 = 1
  u0.a_pre = 1
  u0.a_post= 1
  u0.fsm_ref = fsm_melee
  
  # получает ману
  u1.fsm_ref = fsm_cast_super_stun
  ret

# ###################################################################################################
#    attack modifier
# ###################################################################################################

@static_crit_demo = ()->
  ret = module.eliminate_s0_s1()
  {state} = ret
  [u0, u1] = state.unit_list
  # Царапается
  u0.ad100 = 1
  u0.a_pre = 1
  u0.a_post= 1
  u0.fsm_ref = fsm_melee
  u0.a_mod_fn_list.push dm = new Damage_modifier
  dm.fn = (di, src, dst, state)->
    di.damage100 *= 100 # crit 100_000%
    return
  
  ret

# TODO random crit

# ###################################################################################################
#    damage block modifier
# ###################################################################################################

@damage_block_demo = ()->
  ret = module.oneshot_kill()
  ret.tick_limit = 100
  {state} = ret
  [u0, u1] = state.unit_list
  
  u1.damage_block_fn_list.push dm = new Damage_modifier
  dm.order = 999
  dm.fn = (di, src, dst, state)->
    # reduce all to 10 damage
    di.damage100 = Math.min di.damage100, 10
    return
  
  ret
# TODO spectre damage to all near enemy
# TODO blade mail return damage instance (NOTE no infinite loop)

# ###################################################################################################
#    status effect
# ###################################################################################################

# TODO desolator = apply status effect on attack

