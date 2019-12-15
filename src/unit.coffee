module = @
class @Unit
  _remove          : false
  _last_update_tick: 0
  @uid        : 0
  
  uid         : 0
  side        : 0
  # ###################################################################################################
  #    position + move
  # ###################################################################################################
  x           : 0
  y           : 0
  
  # TODO ms here
  
  # ###################################################################################################
  #    HP/MP
  # ###################################################################################################
  hp100       : 100
  hp_max100   : 100
  hp_reg100   : 0
  
  mp100       : 0
  mp_max100   : 10000
  mp_reg100   : 0
  
  # ###################################################################################################
  #    attack
  # ###################################################################################################
  as          : 100 # LATER
  bat         : 1.7 # LATER
  base_a_pre  : 10  # LATER
  base_a_post : 10  # LATER
  ad100       : 0
  # calc
  a_pre       : 10
  a_post      : 10
  
  next_tick_attack_available : 0
  
  # ###################################################################################################
  #    cast
  # ###################################################################################################
  
  cast_pre    : 1
  # cast_post   : 1 # unused
  
  # ###################################################################################################
  
  # targeting_system
  target_unit_uid     : -1
  
  fsm_idx             : 0
  fsm_next_event_tick : 0
  fsm_ref             : null
  
  constructor : ()->
    @uid = module.Unit.uid++
  
  target_policy : (target_unit_list)-> # can be replaceable
    {x,y} = @
    best_unit = target_unit_list[0]
    unit = best_unit
    # COPYPASTE OPT
    dx = unit.x - x
    dy = unit.y - y
    d2 = dx*dx + dy*dy
    # END
    best_unit_d2 = d2
    len = target_unit_list.length
    for idx in [1 ... len] by 1
      unit = target_unit_list[idx]
      dx = unit.x - x
      dy = unit.y - y
      d2 = dx*dx + dy*dy
      if best_unit_d2 > d2
        best_unit   = unit
        best_unit_d2= d2
    
    best_unit
  
  assert_cmp : (t)->
    error_list = []
    error_list.push "@uid         != t.uid          #{@uid        } != #{t.uid        }" if @uid          != t.uid         
    error_list.push "@x           != t.x            #{@x          } != #{t.x          }" if @x            != t.x           
    error_list.push "@y           != t.y            #{@y          } != #{t.y          }" if @y            != t.y           
    error_list.push "@side        != t.side         #{@side       } != #{t.side       }" if @side         != t.side        
    error_list.push "@hp100       != t.hp100        #{@hp100      } != #{t.hp100      }" if @hp100        != t.hp100       
    error_list.push "@hp_max100   != t.hp_max100    #{@hp_max100  } != #{t.hp_max100  }" if @hp_max100    != t.hp_max100   
    error_list.push "@hp_reg100   != t.hp_reg100    #{@hp_reg100  } != #{t.hp_reg100  }" if @hp_reg100    != t.hp_reg100   
    error_list.push "@mp100       != t.mp100        #{@mp100      } != #{t.mp100      }" if @mp100        != t.mp100       
    error_list.push "@mp_max100   != t.mp_max100    #{@mp_max100  } != #{t.mp_max100  }" if @mp_max100    != t.mp_max100   
    error_list.push "@mp_reg100   != t.mp_reg100    #{@mp_reg100  } != #{t.mp_reg100  }" if @mp_reg100    != t.mp_reg100   
    error_list.push "@as          != t.as           #{@as         } != #{t.as         }" if @as           != t.as          
    error_list.push "@bat         != t.bat          #{@bat        } != #{t.bat        }" if @bat          != t.bat         
    error_list.push "@base_a_pre  != t.base_a_pre   #{@base_a_pre } != #{t.base_a_pre }" if @base_a_pre   != t.base_a_pre  
    error_list.push "@base_a_post != t.base_a_post  #{@base_a_post} != #{t.base_a_post}" if @base_a_post  != t.base_a_post 
    error_list.push "@ad100       != t.ad100        #{@ad100      } != #{t.ad100      }" if @ad100        != t.ad100       
    error_list.push "@a_pre       != t.a_pre        #{@a_pre      } != #{t.a_pre      }" if @a_pre        != t.a_pre       
    error_list.push "@a_post      != t.a_post       #{@a_post     } != #{t.a_post     }" if @a_post       != t.a_post      
    
    error_list.push "@target_unit_uid     != t.target_unit_uid      #{@target_unit_uid}     != #{t.target_unit_uid    }" if @target_unit_uid      != t.target_unit_uid    
    error_list.push "@fsm_idx             != t.fsm_idx              #{@fsm_idx}             != #{t.fsm_idx            }" if @fsm_idx              != t.fsm_idx            
    error_list.push "@fsm_next_event_tick != t.fsm_next_event_tick  #{@fsm_next_event_tick} != #{t.fsm_next_event_tick}" if @fsm_next_event_tick  != t.fsm_next_event_tick
    if error_list.length
      throw new Error error_list.join ';\n'
    
    return
  