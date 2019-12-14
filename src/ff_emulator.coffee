{State} = require './state'

class @FF_emulator
  tick_limit      : 0
  state           : null
  end_condition   : (state, is_last_tick)->if is_last_tick then 'draw' else null # replaceable
  
  tick_signal_list: []
  
  constructor:()->
    @state = new State
    @tick_signal_list = []
  
  tick : ()->
    # TBD
  
  next_tick_get : ()->
    next_tick_idx = @tick_limit
    for tick_idx in [@state.tick_idx + 1 ... @tick_limit] by 1
      if @tick_signal_list[tick_idx]
        next_tick_idx = tick_idx
        break
    p "next_tick_idx", next_tick_idx
    next_tick_idx
  
  go : ()->
    loop
      @tick()
      
      break if @end_condition @state
      break if @state.tick_idx >= @tick_limit
      @state.tick_idx = @next_tick_get()
    @end_condition @state, true
  

