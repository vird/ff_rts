{State} = require './state'
{FSM_event} = require './fsm'
{
  dead_remove
  retargeting
} = require './heuristics'

class @FF_emulator
  tick_per_sec    : 100
  tick_limit      : 0
  state           : null
  end_condition   : (state, is_last_tick)->if is_last_tick then 'draw' else null # replaceable
  
  tick_signal_list: []
  
  constructor:()->
    @state = new State
    @tick_signal_list = []
  
  tick : ()->
    {state} = @
    {
      tick_idx
      unit_list
      pending_effect_list
    } = state
    need_next_tick = false
    # fsm move
    for unit in unit_list
      fn = unit.fsm_ref.transition_hash[unit.fsm_idx][FSM_event.tick]
      if fn?(unit, state)
        @need_tick unit.fsm_next_event_tick
        @need_tick unit.next_tick_attack_available
    
    for effect in pending_effect_list
      effect()
    pending_effect_list.clear()
    
    # regen
    for unit in unit_list
      dt = tick_idx - unit._last_update_tick
      regen_per_tick = unit.hp_reg100//@tick_per_sec
      unit.hp100 = Math.min unit.hp_max100, unit.hp100 + dt*regen_per_tick
      if unit.hp100 <= 0
        state.event_counter++
        unit._remove = true
        # need_next_tick= true
      
      unit._last_update_tick = tick_idx
    
    dead_remove state
    retargeting state
    
    if need_next_tick
      @need_tick tick_idx+1
    
    # TBD
    return
  
  need_tick : (tick_idx)->
    # p "need_tick #{tick_idx}"
    if @tick_signal_list.length <= tick_idx
      @tick_signal_list.length = tick_idx + 1
    
    @tick_signal_list[tick_idx] = true
    return
  
  next_tick_get : ()->
    next_tick_idx = @tick_limit
    for tick_idx in [@state.tick_idx + 1 ... @tick_limit] by 1
      if @tick_signal_list[tick_idx]
        next_tick_idx = tick_idx
        break
    next_tick_idx
  
  go : ()->
    @state.cache_actualize()
    loop
      @tick()
      
      break if @end_condition @state
      break if @state.tick_idx >= @tick_limit
      @state.tick_idx = @next_tick_get()
    @end_condition @state, true
  

