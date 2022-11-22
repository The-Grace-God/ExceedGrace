local l_panel =       gfx.CreateSkinImage("multi/roomselect/room_panel.png",1);

local l_pw =   gfx.CreateSkinImage("multi/roomselect/pw_or_price_panel.png",1);

local n_panel_ja =    gfx.CreateSkinImage("multi/roomselect/nautica/nautica_bg_jacket.png",1);

local n_play_dot =    gfx.CreateSkinImage("multi/roomselect/nautica/nautica_pl_dot.png",1);

local info_panel = gfx.CreateSkinImage("multi/roomselect/room_panel_name_or_song.png",1);

local placeholderJacket = gfx.CreateSkinImage("song_select/loading.png", 0)

local xnum = 230
local ynum = 40

local draw_room = function(name, x, y,status, selected, hoverindex)
    
    jacket = placeholderJacket

    local jw,jh = gfx.ImageSize(l_panel);
    gfx.BeginPath();
    gfx.ImageRect(x/4.5,y, jw/1.17, jh/1.17, l_panel,1,0);
    
    local jw,jh = gfx.ImageSize(n_panel_ja);
    gfx.BeginPath();
    gfx.ImageRect(x/4.5+3,y+5, jw/1.25, jh/1.17, n_panel_ja,1,0);

    gfx.BeginPath();
    gfx.ImageRect(x/4.5+10,y+22, jw/1.45,jh/1.45, jacket,1,0);

    local jw,jh = gfx.ImageSize(info_panel);
    gfx.BeginPath();
    gfx.ImageRect(x/2-5,y+5, jw/1.17, jh/1.17, info_panel,1,0);

    local jw,jh = gfx.ImageSize(n_play_dot);
    gfx.BeginPath();
    gfx.ImageRect(x/4.5,y, jw/1.17, jh/1.17, n_play_dot,1,0);

    gfx.BeginPath();
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE);
    gfx.FontSize(35);
    gfx.Text(name, x-xnum,y+ynum);
    gfx.Text(stats[1], x-xnum,y+ynum+40);

    gfx.FontSize(24);
    local jw,jh = gfx.ImageSize(l_pw);
    gfx.BeginPath();
    gfx.ImageRect(x+xnum-5,y+ynum+29, jw/1.17, jh/1.17, l_pw,1,0);
    gfx.Text(stats[2].." / "..stats[4], x+xnum+2.5,y+ynum+52.5);

end;

return draw_room