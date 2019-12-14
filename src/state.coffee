{Unit} = require './unit'
class @State
  tick_idx        : 0
  unit_list       : []
  projectile_list : []
  aoe_list        : []
  # TODO dual array
  
  constructor:()->
    Unit.uid = 0 # HACK
    @unit_list      = []
    @projectile_list= []
    @aoe_list       = []
  
  assert_cmp : (t)->
    if @unit_list.length != t.unit_list.length
      throw new Error "@unit_list.length != t.unit_list.length #{@unit_list.length} != #{t.unit_list.length}"
    t_unit_list = t.unit_list
    for a, idx in @unit_list
      b = t_unit_list[idx]
      a.assert_cmp b
    
    # TBD
    
    return

