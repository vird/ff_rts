class @Unit
  _remove          : false
  _last_update_tick: 0
  side      : 0
  
  hp100     : 100
  hp_max100 : 100
  hp_reg100 : 0
  
  mp100     : 100
  mp_max100 : 100
  mp_reg100 : 0
  
  
  assert_cmp : (t)->
    error_list = []
    error_list.push "@side      != t.side      #{@side     } != #{t.side     }" if @side      != t.side      
    error_list.push "@hp100     != t.hp100     #{@hp100    } != #{t.hp100    }" if @hp100     != t.hp100     
    error_list.push "@hp_max100 != t.hp_max100 #{@hp_max100} != #{t.hp_max100}" if @hp_max100 != t.hp_max100 
    error_list.push "@hp_reg100 != t.hp_reg100 #{@hp_reg100} != #{t.hp_reg100}" if @hp_reg100 != t.hp_reg100 
    error_list.push "@mp100     != t.mp100     #{@mp100    } != #{t.mp100    }" if @mp100     != t.mp100     
    error_list.push "@mp_max100 != t.mp_max100 #{@mp_max100} != #{t.mp_max100}" if @mp_max100 != t.mp_max100 
    error_list.push "@mp_reg100 != t.mp_reg100 #{@mp_reg100} != #{t.mp_reg100}" if @mp_reg100 != t.mp_reg100 
    if error_list.length
      throw new Error error_list.join ';\n'
    
    return
  