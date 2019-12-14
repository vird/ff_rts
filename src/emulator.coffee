{State} = require './state'

class @Emulator
  tick_per_sec  : 100
  tick_limit    : 0
  state         : null
  end_condition : (state, is_last_tick)->if is_last_tick then 'draw' else null # replaceable
  
  constructor:()->
    @state = new State
  
  tick : ()->
    {unit_list} = @state
    # regen
    for unit in unit_list
      regen_per_tick = unit.hp_reg100//@tick_per_sec
      unit.hp100 = Math.min unit.hp_max100, unit.hp100 + regen_per_tick
      
      unit._remove = true if unit.hp100 <= 0
    
    # простой и медленный способ
    idx = 0
    loop
      break if idx >= unit_list.length
      unit = unit_list[idx]
      if unit._remove
        unit_list.remove_idx idx
        continue
      idx++
    
    # TBD
    return
  
  go : ()->
    loop
      @tick()
      
      break if @end_condition @state
      break if @state.tick_idx >= @tick_limit
      @state.tick_idx++
    @end_condition @state, true
  
