local stopMusic = function ()
    local musicPlaying = game.GetSkinSetting('_musicPlaying');
    if musicPlaying and musicPlaying ~= '' then
        game.StopSample(musicPlaying);
        game.SetSkinSetting("_musicPlaying", "")
    end
end

return {
    stopMusic = stopMusic
}