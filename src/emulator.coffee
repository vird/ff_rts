{State} = require './state'
{FSM_event} = require './fsm'
{
  dead_remove
  retargeting
} = require './heuristics'

class @Emulator
  tick_per_sec  : 100
  tick_limit    : 0
  state         : null
  end_condition : (state, is_last_tick)->if is_last_tick then 'draw' else null # replaceable
  
  constructor:()->
    @state = new State
  
  tick : ()->
    {state} = @
    {
      unit_list
      pending_effect_list
    } = state
    # fsm move
    for unit in unit_list
      fn = unit.fsm_ref.transition_hash[unit.fsm_idx][FSM_event.tick]
      fn?(unit, state)
    
    for effect in pending_effect_list
      effect()
    pending_effect_list.clear()
    
    # regen
    for unit in unit_list
      regen_per_tick = unit.hp_reg100//@tick_per_sec
      unit.hp100 = Math.min unit.hp_max100, unit.hp100 + regen_per_tick
      
      if unit.hp100 <= 0
        state.event_counter++
        unit._remove = true
    
    dead_remove state
    retargeting state
    
    # TBD
    return
  
  
  
  go : ()->
    @state.cache_actualize()
    loop
      @tick()
      
      break if @end_condition @state
      break if @state.tick_idx >= @tick_limit
      @state.tick_idx++
    @end_condition @state, true
  
