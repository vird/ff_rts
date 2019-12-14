class @State
  tick_idx        : 0
  unit_list       : []
  projectile_list : []
  aoe_list        : []
  # TODO dual array
  
  constructor:()->
    @unit_list      = []
    @projectile_list= []
    @aoe_list       = []
  
  cmp : (t)->
    return false if @unit_list.length != t.unit_list.length
    
    # TBD
    
    true

