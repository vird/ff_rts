{Unit} = require './unit'
class @State
  tick_idx        : 0
  event_counter   : 0 # for consistency check only
  unit_list       : []
  projectile_list : []
  aoe_list        : []
  
  pending_effect_list : []
  # TODO dual array??
  
  # cache
  cache_unit_hash : {}
  cache_side_unit_list : []
  
  constructor:()->
    Unit.uid = 0 # HACK
    @unit_list      = []
    @projectile_list= []
    @aoe_list       = []
    @pending_effect_list = []
    
    @cache_unit_hash= {}
    @cache_side_unit_list = []
  
  assert_cmp : (t)->
    if @event_counter != t.event_counter
      throw new Error "@event_counter != t.event_counter #{@event_counter} != #{t.event_counter}"
    if @tick_idx != t.tick_idx
      throw new Error "@tick_idx != t.tick_idx #{@tick_idx} != #{t.tick_idx}"
    if @unit_list.length != t.unit_list.length
      throw new Error "@unit_list.length != t.unit_list.length #{@unit_list.length} != #{t.unit_list.length}"
    t_unit_list = t.unit_list
    for a, idx in @unit_list
      b = t_unit_list[idx]
      a.assert_cmp b
    
    # extra check cache for 100% consistency
    for k,v of @cache_unit_hash
      if !t.cache_unit_hash[k]
        throw new Error "Cache mismatch. key '#{k}' mismatch in @cache_unit_hash"
    for k,v of t.cache_unit_hash
      if !@cache_unit_hash[k]
        throw new Error "Cache mismatch. key '#{k}' mismatch in @cache_unit_hash"
    
    for side_list, side in @cache_side_unit_list
      t_side_list = t.cache_side_unit_list[side]
      for unit, unit_idx in side_list
        if unit.uid != t_side_list[unit_idx].uid
          throw new Error "Cache mismatch. side=#{side} unit_idx=#{unit_idx} unit.uid=#{unit.uid} mismatch"
    
    # TBD
    
    return
  
  cache_actualize : ()->
    cache_unit_hash = {}
    cache_side_unit_list = [[], []]
    for unit in @unit_list
      cache_side_unit_list[unit.side].push unit
      cache_unit_hash[unit.uid] = unit
    @cache_unit_hash = cache_unit_hash
    @cache_side_unit_list = cache_side_unit_list
    return

