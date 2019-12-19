{State} = require './state'
{FSM_event} = require './fsm'
{
  dead_remove
  retargeting
  status_effect_remove
} = require './heuristics'
{
  status_effect_to_idx_mask
  status_effect_hash
} = require './status_effect'

{big_idx:fast_stun_idx, mask:fast_stun_mask} = status_effect_to_idx_mask status_effect_hash.stun

class @FF_emulator
  tick_per_sec    : 100
  tick_limit      : 0
  state           : null
  end_condition   : (state, is_last_tick)->if is_last_tick then 'draw' else null # replaceable
  ff_tick         : 0
  
  tick_signal_list: []
  
  constructor:()->
    @state = new State
    @tick_signal_list = []
  
  tick : ()->
    @ff_tick++
    {
      state
      tick_per_sec
    } = @
    {
      tick_idx
      unit_list
      projectile_list
      pending_effect_list
    } = state
    
    need_next_tick = false
    
    status_effect_remove state
    
    # projectile move
    for projectile in projectile_list
      {
        target
        ms
      } = projectile
      dt = tick_idx - projectile._last_update_tick
      ms_per_tick = ms//tick_per_sec
      ms_total = ms_per_tick*dt
      dx = target.x - projectile.x
      dy = target.y - projectile.y
      d2 = dx*dx + dy*dy
      if d2 < ms_total
        # hit
        projectile._remove = true
        projectile.effect({state})
      else
        d = Math.sqrt(d2)
        dx /= d
        dy /= d
        vx = dx*ms_total
        vy = dy*ms_total
        projectile.x += vx
        projectile.y += vy
        t_left = Math.ceil(d/ms_per_tick) - dt
        
        half_t_left = Math.max 1, t_left # FULL travel mode
        # half_t_left = Math.max 1, t_left//2 # HALF travel mode
        projectile.hd_next_tick = tick_idx + half_t_left
    
    # fsm move
    for unit in unit_list
      if unit.status_effect_bitmap[fast_stun_idx] & fast_stun_mask
        # p "ff stun skip #{tick_idx}"
        continue
      fn = unit.fsm_ref.transition_hash[unit.fsm_idx][FSM_event.tick]
      if fn?(unit, state)
        @need_tick unit.fsm_next_event_tick
        @need_tick unit.next_tick_attack_available
    
    for projectile in projectile_list
      projectile._last_update_tick = tick_idx
      if !projectile._remove
        @need_tick projectile.hd_next_tick
    
    for effect in pending_effect_list
      update_list = effect()
      for unit in update_list
        @need_tick unit.fsm_next_event_tick
    pending_effect_list.clear()
    
    # regen
    for unit in unit_list
      # hp
      dt = tick_idx - unit._last_update_tick
      regen_per_tick = unit.hp_reg100//tick_per_sec
      unit.hp100 = Math.min unit.hp_max100, unit.hp100 + dt*regen_per_tick
      if unit.hp100 <= 0
        state.event_counter++
        unit._remove = true
        # need_next_tick= true
      
      # mp
      regen_per_tick = unit.mp_reg100//tick_per_sec
      unit.mp100 = Math.max 0, Math.min unit.mp_max100, unit.mp100 + regen_per_tick
      
      unit._last_update_tick = tick_idx
    
    dead_remove state
    if retargeting state
      need_next_tick = true
    
    if need_next_tick
      @need_tick tick_idx+1
    
    # TBD
    return
  
  need_tick : (tick_idx)->
    # p "need_tick #{tick_idx}"
    if @tick_signal_list.length <= tick_idx
      @tick_signal_list.length = tick_idx + 1
    
    @tick_signal_list[tick_idx] = true
    return
  
  next_tick_get : ()->
    next_tick_idx = @tick_limit
    for tick_idx in [@state.tick_idx + 1 ... @tick_limit] by 1
      if @tick_signal_list[tick_idx]
        next_tick_idx = tick_idx
        break
    next_tick_idx
  
  go : ()->
    @state.cache_actualize()
    loop
      @tick()
      
      break if @end_condition @state
      break if @state.tick_idx >= @tick_limit
      @state.tick_idx = @next_tick_get()
    # p "ff_tick=#{@ff_tick} #{@state.tick_idx}"
    @end_condition @state, true
  

