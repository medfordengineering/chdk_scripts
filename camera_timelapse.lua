--[[
@title Time Lapse
@param	i Interval
	@default i 3 
--]]

interval = i*1000

next_time = get_tick_count()
repeat
  if ( next_time <= get_tick_count()) then
    press("shoot_full")
    sleep(1000)
    release("shoot_full")
    shot_count = shot_count + 1
	print("Shot: "..shot_count)
    next_time = next_time + interval
  end
until (shot_count > 5)
