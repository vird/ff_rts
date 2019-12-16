module = @
@tick_targeting = (u0_list, u1_list, unit_hash)->
  for u0 in u0_list
    need_retarget = false
    need_retarget = true if u0.target_unit_uid == -1
    need_retarget = true if !unit_hash[u0.target_unit_uid]
    if need_retarget
      if u1_list.length == 0
        u0.target_unit_uid = -1
        continue
      
      target = u0.target_policy u1_list
      if !target
        u0.target_unit_uid = -1
      else
        u0.target_unit_uid = target.uid
  return

@dead_remove = (state)->
  # простой и медленный способ
  {
    unit_list
    projectile_list
    cache_unit_hash
    cache_side_unit_list
  } = state
  
  idx = 0
  loop
    break if idx >= unit_list.length
    unit = unit_list[idx]
    if unit._remove
      unit_list.remove_idx idx
      delete cache_unit_hash[unit.uid]
      # по-тупому
      cache_side_unit_list[unit.side].remove unit
      continue
    idx++
  
  idx = 0
  loop
    break if idx >= projectile_list.length
    projectile = projectile_list[idx]
    if projectile_list._remove
      projectile_list.remove_idx idx
      continue
    idx++
  
  
  return

@retargeting = (state)->
  {
    cache_unit_hash
    cache_side_unit_list
  } = state
  
  [
    u0_list
    u1_list
  ] = cache_side_unit_list
  
  module.tick_targeting u0_list, u1_list, cache_unit_hash
  module.tick_targeting u1_list, u0_list, cache_unit_hash
  return

@damage_deal = (src, dst, state)->
  state.pending_effect_list.push ()->
    # p "damage_deal #{src.ad100} #{state.tick_idx}"
    damage100 = src.ad100
    dst.hp100 -= damage100
    
    state.event_counter++
    
    # only if src is unit
    src.mp100 = Math.min src.mp_max100, src.mp100 + 2500
    dst.mp100 = Math.min dst.mp_max100, dst.mp100 + 2500
    
    # p "damage_deal #{src.ad100} #{dst.hp100} #{state.tick_idx}"
    return
  
  return

@projectile_process = (state)->
  {
    projectile_list
  } = state
  
  return
