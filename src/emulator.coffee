{State} = require './state'

class @Emulator
  tick_limit    : 0
  state         : null
  end_condition : (state, is_last_tick)->if is_last_tick then 'draw' else null # replaceable
  
  constructor:()->
    @state = new State
  
  tick : ()->
    # TBD
  
  go : ()->
    loop
      @tick()
      
      break if @end_condition @state
      break if @state.tick_idx >= @tick_limit
      @state.tick_idx++
    @end_condition @state, true
  
