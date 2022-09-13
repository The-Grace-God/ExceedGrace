-- result and challengeresult `result` table

---@class HitStat
---@field timeFrac number -- Fraction of when in the chart the note was hit, `0.0` to `1.0`
---@field lane integer -- `0` = A, `1` = B, `2` = C, `3` = D, `4` = L, `5` = R, `6` = Left Laser, `7` = Right Laser
---@field time integer -- When in the chart the note was hit, in milliseconds
---@field delta integer -- Delta value of the hit from 0
---@field hold integer -- `0` for chip/laser, otherwise `# Ticks` of hold
---@field rating integer -- `0 = Miss`, `1 = Near`, `2 = Crit`
HitStat = {};

---@class HitWindow
---@field good integer # Near window, default `92`
---@field hold integer -- Hold window, default `138`
---@field miss integer -- Miss window, default `250`
---@field perfect integer -- Critical window, default `46`
---@field slam integer -- Slam window, default `84`
---@field type integer -- `1 = Normal` default, `2 = Hard` default values halved
HitWindow = {};

---@class Score
---@field auto_flags integer # Autoplay flag
---@field badge integer # `0` = Manual Exit, `1` = Played, `2` = Cleared, `3` = Hard Cleared, `4` = Full Chain, `5` = Perfect Chain
---@field gauge number # Ending gauge percentage, `0.0` to `1.0`
---@field gauge_option integer # Gauge option e.g. ARS
---@field gauge_type integer # `0` = Normal, `1` = Hard, `2` = Permissive, `3` = Blastive
---@field goods integer # Total near hits
---@field hitWindow HitWindow|nil # Hit windows of the score, only for singleplayer results screen
---@field mirror integer # Mirror mode flag
---@field misses integer # Total errors
---@field name nil|string # Only for multiplayer results, name of the player
---@field perfects integer # Total critical hits
---@field random integer # Random mode flag
---@field score integer # Result score
---@field timestamp integer # Unix timestamp of the score
---@field uid nil|string # Only for multiplayer results, UID of the player
Score = {};

---@class ChartResult : result
---@field passed boolean # Whether or not challenge requirements were met for this chart
---@field failReason string # Fail reason if a challenge requirement was not met
ChartResult = {};

---@class ServerScoreOptions
---@field gaugeType integer # An enum value representing the gauge type used. 0 = normal, 1 = hard. Further values are not currently specified.
---@field gaugeOpt integer # Reserved
---@field mirror boolean # Mirror mode enabled
---@field random boolean # Note shuffle enabled
---@field autoFlags integer # A bitfield of elements of the game that are automated. Any non-zero value means that the score was at least partially auto.
ServerScoreOptions = {}

---@class ServerScore
---@field score integer # Submitted score
---@field gauge number # Submitted Gauge result
---@field timestamp integer # Unix timestamp of the score
---@field crit integer # Hits inside the critical window
---@field near integer # Hits inside the near window
---@field early integer # Hits inside the near window which were early
---@field late integer # Hits inside the near window which were late
---@field combo integer # Best combo reached
---@field error integer # Missed notes
---@field options ServerScoreOptions # The options in use. Includes gauge type, etc.
---@field windows table # {perfect, good, hold, miss, slam} hit windows in milliseconds
---@field yours boolean # This score belongs to the current player
---@field justSet boolean # This score belongs to the current player, and is the score that was just achieved
ServerScore = {}

---@class result
---@field artist string # Chart artist
---@field auto_flags integer # Autoplay flag
---@field autoplay boolean # Autoplay bool
---@field avgCrits integer # Only for challenge results, average number of critical hits across the charts
---@field avgErrors integer # Only for challenge results, average number of error hits across the charts
---@field avgGauge number # Only for challenge results, average gauge percentage across the charts
---@field avgNears integer # Only for challenge results, average number of near hits of the charts
---@field avgPercentage integer # Only for challenge results, average completion percentage across the charts
---@field avgScore integer # Only for challenge results, average score across the charts
---@field badge integer # `0` = Manual Exit, `1` = Played, `2` = Cleared, `3` = Hard Cleared, `4` = Full Chain, `5` = Perfect Chain
---@field bpm number # Chart BPM
---@field charts ChartResult[] # Only for challenge results, array of chart results
---@field chartHash string # Chart hash
---@field difficulty integer # Difficulty index
---@field displayIndex nil|integer # Only for multiplayer results, the index of the score being viewed
---@field duration integer # Chart duration, in milliseconds
---@field earlies integer # Total early hits
---@field effector string # Chart effector
---@field failReason string # Reason for failing the challenge
---@field flags integer # Gameplay option flags e.g. gauge type, mirror/random mode
---@field gauge number # Ending gauge percentage, `0.0` to `1.0`
---@field gauge_option integer # Gauge option e.g. ARS
---@field gauge_type integer # `0` = Normal, `1` = Hard, `2` = Permissive, `3` = Blastive
---@field gaugeSamples number[] # Gauge values sampled (256 total) throughout the play
---@field goods integer # Total near hits
---@field grade string # Result grade
---@field highScores Score[] # All scores
---@field hitWindow HitWindow # Result hit windows
---@field holdHitStats HitStat[]|nil # Hit stats for every hold object, only available for singleplayer if `isSelf = true`
---@field illustrator string # Chart jacket illustrator
---@field irState integer # Current state of the IR score submission request (a USC-IR code, including extensions 0/10/60)
---@field irDescription string # The description in the IR response (nil if irState is 0 or 10)
---@field irScores ServerScore[]|nil # Score submission result, nil if irState != 20
---@field isSelf boolean # Only for multiplayer, `false` if score is of another player
---@field jacketPath string # Full filepath to the jacket image on the disk
---@field laserHitStats HitStat[]|nil # Hit stats for every laser object, only available for singleplayer if `isSelf = true`
---@field lates integer # Total late hits
---@field level integer # Chart or challenge level
---@field maxCombo integer # Result max chain
---@field meanHitDelta number # Mean hit delta
---@field meanHitDeltaAbs number # Absolute value of mean hit delta
---@field medianHitDelta integer # Median hit delta
---@field medianHitDeltaAbs integer # Absolute value of median hit delta
---@field mirror boolean # Mirror mode bool
---@field misses integer # Total errors
---@field mission string # Only for practice mode
---@field noteHitStats HitStat[]|nil # Hit stats for every chip hit, only available for singleplayer if `isSelf = true`
---@field overallCrits integer # Only for challenge results, total number of critical hits across the charts
---@field overallErrors integer # Only for challenge results, total number of error hits across the charts
---@field overallNears integer # Only for challenge results, total number of near hits across the charts
---@field passed boolean # Only for challenge results, whether or not the challenge was passed
---@field perfects integer # Total critical hits
---@field playbackSpeed number # Only for practice mode, percentage from 0.25 to 1.0
---@field playerName nil|string # Only for multiplayer
---@field random boolean # Random mode bool,
---@field realTitle string # Chart title, always without player name
---@field requirement_text string # Only for challenge results, the challenge requirements separated by newline character `"\n"`
---@field retryCount integer # Only for practice mode
---@field score integer # Result score
---@field speedModType integer # Only for singleplayer, `0` = XMOD, `1` = MMOD, `2` = CMOD
---@field speedModValue number # Only for singleplayer, `HiSpeed` for `XMOD`, `ModSpeed` otherwise
---@field title string # Chart (with player name in multiplayer) or challenge title
---@field uid nil|string # Only for multiplayer, UID of the player
result = {};
