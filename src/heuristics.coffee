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
