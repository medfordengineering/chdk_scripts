--[[
@title Time Lapse One

@param     i Interval (sec)
  @default i 15
  @range   i 2 3600
@param     d Display Off Time
  @default d 0
  @values  d Never 1_shot 5_shots
@param     f Focus
  @default f 0
  @values  f Auto Locked Infinity
@param     e Exposure
  @default e 0
  @values  e Auto Locked
--]]

    interval      = i*1000
    display_mode  = d
    focus_mode    = f
    exposure_mode = e

--  ========================== Useful Functions ================================= 

    function lock_focus()
        if ( set_mf(1) == 0 ) then       -- set MF mode
            set_aflock(1)                -- fall back to AFL if set_mf fails
        end
    end

    function unlock_focus()
        set_mf(0)
        set_aflock(0)
    end

    function restore()
        if (exposure_mode == 1) then set_aelock(0) end
        if (focus_mode > 0    ) then unlock_focus() end
        if (display_mode > 0  ) then set_lcd_display(1) end
    end

--  ========================== Main Program ================================= 

bi=get_buildinfo()
version= tonumber(string.sub(bi.build_number,1,1))*100 + tonumber(string.sub(bi.build_number,3,3))*10 + tonumber(string.sub(bi.build_number,5,5))

if ( version < 130) then 
    print("CHDK 1.3.0 or higher required")
else
    -- disable shutter button to allow orderly shutdown on any key press
    set_exit_key("no_key")
    set_draw_title_line(0)    
    set_console_layout(1 ,5, 45, 12 )
    
    -- switch to shooting mode if necessary
    if ( get_mode() == false ) then
        sleep(1000)
        set_record(1)                 
        while ( get_mode() == false) do sleep(100) end
        sleep(500)   
    end

    -- enable ae lock or af lock if requested
    if (exposure_mode == 1) or (focus_mode > 0) then    
        press("shoot_half")     
        count = 0
        repeat  
            sleep(50)
            count = count + 1     
        until (get_shooting() == true ) or (count > 40 )
        if (exposure_mode == 1) then set_aelock(1) end
        if (focus_mode > 0)  then lock_focus() end
        release("shoot_half") 
        if (focus_mode == 2) then 
            sleep(500)
            set_focus(50000)  
            sleep(1000)
        end
    end
    
    -- shoot and loop forever until any key pressed
    shot_count = 1
    next_time = get_tick_count()
    repeat
        if ( next_time <= get_tick_count() ) then
            print("Shot : "..shot_count)   
            press("shoot_half")         
            if ( exposure_mode == 1) then 
                if ( focus_mode > 0 ) then 
                   sleep(500)                                         -- ae and af locked
                else
                    count = 0
                    repeat  
                        sleep(50)
                        count = count + 1 
                    until (get_focus_ok() == true ) or (count > 40 )  -- only ae locked
                end
            else
                count = 0
                repeat  
                    sleep(50)
                    count = count + 1      
                until (get_shooting() == true ) or (count > 40 )      -- only af locked or nothing locked
            end
            press("shoot_full")
            sleep(1000)
            release("shoot_full")
            shot_count = shot_count + 1 
            if ((display_mode == 1) and (shot_count == 2)) then set_lcd_display(0) end
            if ((display_mode == 2) and (shot_count == 6)) then set_lcd_display(0) end        
            next_time = next_time + interval
        end
        wait_click(100)
    until not(is_key("no_key"))
    restore()
end