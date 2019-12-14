{State} = require './state'
{tick_targeting} = require './heuristics'

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
    {unit_list, tick_idx} = @state
    need_next_tick = false
    
    # regen
    for unit in unit_list
      dt = tick_idx - unit._last_update_tick
      regen_per_tick = unit.hp_reg100//@tick_per_sec
      unit.hp100 = Math.min unit.hp_max100, unit.hp100 + dt*regen_per_tick
      if unit.hp100 <= 0
        unit._remove  = true
        # need_next_tick= true
      
      unit._last_update_tick = tick_idx
    
    # простой и медленный способ
    idx = 0
    loop
      break if idx >= unit_list.length
      unit = unit_list[idx]
      if unit._remove
        unit_list.remove_idx idx
        continue
      idx++
    
    # re-targeting
    unit_hash = {}
    side_unit_list = [[], []]
    for unit in unit_list
      side_unit_list[unit.side].push unit
      unit_hash[unit.uid] = true
    [
      u0_list
      u1_list
    ] = side_unit_list
    
    tick_targeting u0_list, u1_list, unit_hash
    tick_targeting u1_list, u0_list, unit_hash
    
    if need_next_tick
      @need_tick tick_idx+1
    
    # TBD
    return
  
  need_tick : (tick_idx)->
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
    loop
      @tick()
      
      break if @end_condition @state
      break if @state.tick_idx >= @tick_limit
      @state.tick_idx = @next_tick_get()
    @end_condition @state, true
  

