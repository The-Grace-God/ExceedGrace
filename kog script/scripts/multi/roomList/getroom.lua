local Dim = require("common.dimensions")
local difbar = require("components.diff_rectangle")

local desw, desh = Dim.design.width,Dim.design.height

local l_panel =       gfx.CreateSkinImage("multi/roomselect/room_panel.png",1); -- when separates are here
local n_panel =       gfx.CreateSkinImage("multi/roomselect/main_box.png",1); 

local n_cost =   gfx.CreateSkinImage("multi/roomselect/pw_or_price_panel.png",1);

local n_panel_ja =    gfx.CreateSkinImage("multi/roomselect/nautica/nautica_bg_jacket.png",1);
local n_nodif =       gfx.CreateSkinImage("multi/roomselect/nautica/no_dif.png",1);
local n_play_dot =    gfx.CreateSkinImage("multi/roomselect/nautica/nautica_pl_dot.png",1); -- when separates are here

local info_panel = gfx.CreateSkinImage("multi/roomselect/room_panel_name_or_song.png",1); -- when separates are here

local xnum = 190
local ynum = 24

local getroom = function(song,x,y,downloaded)
    --multiplayer room list
    if screenState == "roomList" then
        -- do the lobby oder here
        draw_rooms(desw/2, desh - 290);
    end

    --nautica song list 
    if screenState ~= "roomList" then
        local jw,jh = gfx.ImageSize(l_panel); -- if bpm is a think change l_panel to n_panel
        gfx.BeginPath();
        gfx.ImageRect(x,y, jw/1.17, jh/1.17, l_panel,1,0);

        that = 9.5
        why = 1

        local jw,jh = gfx.ImageSize(n_panel_ja);
        gfx.BeginPath();
        gfx.ImageRect(x+that,y+5+why, jw/1.17, jh/1.17, n_panel_ja,1,0);


    gfx.BeginPath()
    gfx.ImageRect(x+that+8.9,y+5+19, jw/1.4, jh/1.4, song.jacket, 1, 0)
    
    
        local jw,jh = gfx.ImageSize(n_nodif);
        for i=1,4 do 
            gfx.BeginPath();
            gfx.ImageRect(x+30+(i*115),y+106, jw/1.09, jh/1.09, n_nodif,1,0);
        end

        local jw,jh = gfx.ImageSize(info_panel);
      gfx.BeginPath();
        gfx.ImageRect(x+147,y+5, jw/1.17, jh/1.17, info_panel,1,0);

        gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP)
        gfx.FontSize(30)
        gfx.Text(song.title,x+xnum,y+ynum)
        gfx.Text(song.artist,x+xnum,y+ynum+40)

        local jw,jh = gfx.ImageSize(n_play_dot);
                gfx.BeginPath();
                gfx.SetImageTint(255,9,253)
                gfx.ImageRect(x,y, jw/1.17, jh/1.17, n_play_dot,1,0);
                gfx.SetImageTint(255,255,255)

            local jw,jh = gfx.ImageSize(n_nodif);
            for i, diff in ipairs(song.charts) do
                if diff.difficulty == 1 then --nov
                    difbar.render(deltaTime, x+260+(-1*115),y+106, jw/150, diff.difficulty, diff.level);
                elseif diff.difficulty == 2 then --adv
                    difbar.render(deltaTime, x+260+(0*115),y+106, jw/150, diff.difficulty, diff.level);
                elseif diff.difficulty == 3 then --exh
                    difbar.render(deltaTime, x+260+(1*115),y+106, jw/150, diff.difficulty, diff.level);
                elseif diff.difficulty == 4 then ---mxm and up
                    difbar.render(deltaTime, x+260+(2*115),y+106, jw/150, diff.difficulty, diff.level);
                end
            end

            local jw,jh = gfx.ImageSize(n_cost);
            gfx.BeginPath();
            gfx.ImageRect(x+650,y+69, jw/1.17, jh/1.17, n_cost,1,0);
            
            local buy = "AP 8000"
           
             local jw,jh = gfx.ImageSize(n_play_dot);
            
            gfx.FontSize(30)
            gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT + gfx.TEXT_ALIGN_MIDDLE)
            if not downloaded[song.id] then
                gfx.BeginPath()
                gfx.Text(string.upper(buy),x+868,y+90)
            elseif downloaded[song.id] == "Downloading" then
                gfx.BeginPath()
                gfx.Text(string.upper(buy), x+868,y+90)
            elseif downloaded[song.id] == "Downloaded" then
                gfx.BeginPath()
                gfx.Text(string.upper(buy), x+868,y+90)
            end
            if song.status == "Playing" then
                gfx.BeginPath()
                gfx.FontSize(24)
                gfx.Text(string.upper(song.status), x+878-10, y+25)
            end
            
            if downloaded[song.id] == "Downloaded" then
                gfx.BeginPath()
                gfx.SetImageTint(240,246,0)
                gfx.ImageRect(x,y, jw/1.17, jh/1.17, n_play_dot,1,0);
                gfx.SetImageTint(255,255,255)
            elseif downloaded[song.id] == "Downloading" then
                gfx.BeginPath()
                gfx.SetImageTint(240,20,0)
                gfx.ImageRect(x,y, jw/1.17, jh/1.17, n_play_dot,1,0);
                gfx.SetImageTint(255,255,255)
            end
            if song.status == "Playing" then
                gfx.BeginPath();
                gfx.SetImageTint(0,246,2)
                gfx.ImageRect(x,y, jw/1.17, jh/1.17, n_play_dot,1,0);
                gfx.SetImageTint(255,255,255)
            end
        
    end
end

return getroom