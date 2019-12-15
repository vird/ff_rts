{
  FSM
  FSM_unit_state
  FSM_event
} = require './fsm'
{
  damage_deal
} =  require './heuristics'

# NOTE this is default FSM (semi-optimized)
# WE should use optimized FSM for each unit type to achieve max perf
@fsm_craft = (opt = {})->
  ret = new FSM
  ret.state_list.push FSM_unit_state.idling
  
  if can_attack = opt.attack_type?
    switch opt.attack_type
      when 'melee', 'ranged'
        ret.state_list.push FSM_unit_state.attacking_pre
        ret.state_list.push FSM_unit_state.attacking
      else
        throw new Error "unknown attack_type '#{opt.attack_type}'"
  
  # if can_cast = opt.cast_type?
  #   switch opt.cast_type
  #     when 'instant'
  #       'none'
  #     when 'cast'
  #       ret.state_list.push FSM_unit_state.casting_pre
  #       ret.state_list.push FSM_unit_state.casting
  #     when 'channel'
  #       throw new Error "unimplemented channel cast_type"
  #     else
  #       throw new Error "unknown cast_type '#{opt.cast_type}'"
  
  for state in ret.state_list
    ret.transition_hash[state] = {}
  
  # cast_target_enemy = true
  # NON OPT
  # CLOSURE!!!!
  ret.transition_hash[FSM_unit_state.idling][FSM_event.tick] = (unit, state)->
    {tick_idx} = state
    scheduled = false
    # if can_cast
    #   loop
    #     # TODO check silence
    #     break if unit.mp100 < 10000
    #     break if cast_target_enemy and unit.target_unit_uid == -1
    #     return FSM_unit_state.casting_pre
    if can_attack
      if unit.next_tick_attack_available <= tick_idx
        unit.fsm_next_event_tick = state.tick_idx + unit.a_pre
        unit.fsm_idx = FSM_unit_state.attacking_pre
        return true
      else
        if scheduled
          unit.fsm_next_event_tick = Math.min unit.fsm_next_event_tick, unit.next_tick_attack_available
        else
          unit.fsm_next_event_tick = unit.next_tick_attack_available
          scheduled = true
    
    return false
  
  if can_attack
    ret.transition_hash[FSM_unit_state.attacking_pre][FSM_event.tick] = (unit, state)->
      return false if unit.fsm_next_event_tick > state.tick_idx
      throw new Error "OVERSHOOT #{state.tick_idx - unit.fsm_next_event_tick}" if unit.fsm_next_event_tick < state.tick_idx # DEV
      unit.fsm_idx = FSM_unit_state.attacking
      unit.fsm_next_event_tick = state.tick_idx+1
      return true
    
    switch opt.attack_type
      when 'melee'
        ret.transition_hash[FSM_unit_state.attacking][FSM_event.tick] = (unit, state)->
          if !target = state.cache_unit_hash[unit.target_unit_uid]
            unit.fsm_idx = FSM_unit_state.idling
            return true
          # TODO is target still in range
          damage_deal unit, target, state
          unit.fsm_idx = FSM_unit_state.idling
          unit.next_tick_attack_available = state.tick_idx + unit.a_post
          return true
      when 'ranged'
        ret.transition_hash[FSM_unit_state.attacking][FSM_event.tick] = (unit, state)->
          if !target = state.cache_unit_hash[unit.target_unit_uid]
            unit.fsm_idx = FSM_unit_state.idling
            return true
          # TODO create projectile
          unit.fsm_idx = FSM_unit_state.idling
          unit.next_tick_attack_available = state.tick_idx + unit.a_post
          return true
  
  # if can_cast
  #   ret.transition_hash[FSM_unit_state.casting_pre] = (unit)->
  #     return FSM_unit_state.casting
  #   ret.transition_hash[FSM_unit_state.casting] = (unit)->
  #     # TODO effect HERE
  #     return FSM_unit_state.idling
  
  ret