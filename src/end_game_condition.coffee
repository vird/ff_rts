@eliminate = (state, is_last_tick)->
  side_counter_list = [0, 0]
  for unit in state.unit_list
    side_counter_list[unit.side]++
  
  [s0, s1] = side_counter_list
  if s0 >  0 and s1 >  0
    return 'draw' if is_last_tick
    return null
  return 's1' if s0 == 0 and s1 >  0
  return 's0' if s0 >  0 and s1 == 0
  return 'draw'
