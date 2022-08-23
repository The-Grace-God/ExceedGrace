local window = {
  isPortrait = false,
  resX = 0,
  resY = 0,
  scale = 1,
  w = 0,
  h = 0,

  set = function(this, doScale)
    local resX, resY = game.GetResolution();

    if ((this.resX ~= resX) or (this.resY ~= this.resY)) then
      this.isPortrait = resY > resX;
      this.w = (this.isPortrait and 1080) or 1920;
      this.h = this.w * (resY / resX);
      this.scale = resX / this.w;

      this.resX = resX;
      this.resY = resY;
    end

    if (doScale) then gfx.Scale(this.scale, this.scale); end
  end,
};

local wheel = {
  cache = { w = 0, h = 0 },
  visibleSongs = 11,
  margin = 13,
  x = 0,
  y = 0,
  w = 0,
  h = {
    song = 0,
    total = 0,
  },

  setSizes = function(this)
    if ((this.cache.w ~= window.w) or (this.cache.h ~= window.h)) then
      local marginTotal = this.margin * (this.visibleSongs - 1);

      this.x = window.w / 2;
      this.y = 0;
      this.w = window.w / 2;
      this.h.total = window.h - marginTotal;
      this.h.song = this.h.total / this.visibleSongs;

      this.cache.w = window.w;
      this.cache.h = window.h;
    end
  end,
};

local displaying = {};
local jacketCache = {};

local currDiff = 1;
local currSong = 1;

local jacketFallback = gfx.CreateSkinImage('song_select/loading.png', 0);

local getJacket = function(diff)
  if ((not jacketCache[diff.jacketPath])
    or (jacketCache[diff.jacketPath] == jacketFallback)) then
    jacketCache[diff.jacketPath] = gfx.LoadImageJob(
      diff.jacketPath,
      jacketFallback,
      500,
      500
    );
  end

  return jacketCache[diff.jacketPath];
end

local setDisplaying = function()
  local songs = songwheel.songs;
  local enoughSongs = #songs >= wheel.visibleSongs;

  displaying[5] = songs[currSong] or {};

  for i = 1, 4 do
    if (enoughSongs) then
      displaying[5 - i] = songs[currSong - i] or songs[currSong + #songs - i];
    else
      displaying[5 - i] = songs[currSong - i] or {};
    end
  end

  for i = 1, 3 do
    if (enoughSongs) then
      displaying[5 + i] = songs[currSong + i] or songs[currSong - #songs + i];
    else
      displaying[5 + i] = songs[currSong + i] or {};
    end
  end
end

local renderWheel = function()
  local margin = wheel.margin;
  local x = wheel.x;
  local y = wheel.y;
  local w = wheel.w;
  local h = wheel.h.song;

  for i, song in ipairs(displaying) do
    local isSelected = i == 5;

    gfx.BeginPath();
    gfx.FillColor(0, 0, 0, (isSelected and 200) or 100);
    gfx.Rect(x, y, w, h);
    gfx.Fill();

    if (song and song.difficulties) then
      local jacket = getJacket(song.difficulties[currDiff] or song.difficulties[1]);

      if (jacket) then
        gfx.BeginPath();
        gfx.ImageRect(x, y, h, h, jacket, (isSelected and 1) or 0.5, 0);
      end
    end

    y = y + h + margin;
  end
end

render = function(dt)
  window:set(true);

  wheel:setSizes();

  setDisplaying();

  renderWheel();

  gfx.ForceRender();
end

set_index = function(newSong)
  currSong = newSong;
end

set_diff = function(newDiff)
  currDiff = newDiff;
end

songs_changed = function(withAll)
  if (not withAll) then return; end
end
