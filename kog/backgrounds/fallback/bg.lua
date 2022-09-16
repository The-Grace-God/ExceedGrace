local delayedOperations = {
  u={},
  speed=nil
}
local dark = game.GetSkinSetting("dark_mode") or game.GetSkinSetting("dark_bgs")

-- backgroundTextures
local bt = {
  _={"_.png"},
  cyberspace={"cyberspace.jpg", "cyberspace-c.jpg"},
  watervault={"watervault.jpg", "watervault-c.jpg"},
  underwater={"underwater.jpg", "underwater-c.jpg", bright=true},
  ocean={"ocean.jpg", "ocean-c.jpg",bright=true},
  grass={"grass.jpg", "grass-c.jpg"},
  deepsea={"deepsea.jpg", "deepsea-c.jpg"},
  cyber={"cyber.jpg", "cyber-c.jpg"},
  desert={"desert.jpg", "desert-c.jpg"},
  desertYellowClear={"desert.jpg", "desert-c2.jpg",bright=true},
  sky={"sky.jpg", "sky-c.jpg",bright=true},
  skyIv={"sky-iv.jpg", "sky-iv-c.jpg",bright=true},
  skyIv2={"sky_iv_2.png", "sky_iv_2-c.png",bright=true},
  skyIvDark={"sky-iv-dark.jpg"},
  sunset={"sunset.jpg", "sunset-c.jpg",bright=true},
  redgradient={"redgradient.jpg", "redblur.jpg"},
  mars={"mars.jpg", "mars-c.jpg"},
  cloudy={"cloudy.jpg", "cloudy-c.jpg"},
  redblur={"redblur.jpg", "redblur-c.jpg"},
  galaxy={"galaxy.jpg", "galaxy-c.jpg"},
  fantasy={"fantasy.jpg", "fantasy-c.jpg",bright=true},
  bedroom={"bedroom.jpg", "bedroom-c.jpg",bright=true},
  flame={"flame.jpg", "flame-c.jpg"},
  game={"game.png",bright=true},
  beach={"beach.png"},
  night={"night.jpg", "night-c.jpg"},
  prettygalaxy={"prettygalaxy.jpg", "prettygalaxy-c.jpg"},
  sakura={"sakura.jpg", "sakura-c.jpg"},
  cyberspaceNight={"cyberspace_night.png", "cyberspace_night_starburst.png", bright=true},
  moonBlue={"moon_blue.jpg", "moon_blue-c.jpg"},
  moonPurple={"moon_purple.jpg", "moon_purple-c.jpg",bright=true},
  redDusk={"red_dusk.jpg", "red_dusk-c.jpg"},
  star={"star.png", "star-c.png",bright=true},
  twilight={"twilight.png", "twilight-c.png"},
  undersea={"undersea.png", "undersea-c.png"},
}

-- backgroundComposition
local function bc(bt, opts)
	local out = {}
	for k,v in pairs(bt) do out[k] = v end
	for k,v in pairs(opts) do out[k] = v end
	return out
end

local btCollections = {
  blue={bt.watervault,bc(bt.underwater,{u={TunnelDodgeBlend=true}}),bt.cyberspace,bt.ocean,bt.grass,bt.deepsea,bt.cyber,bt.desert,bt.sky,bt.skyIv,bt.skyIv2,bt.moonBlue,{"city.png"},bt.cyberspaceNight,bt.undersea,bc(bt._,{weight=6})},
  red={bc(bt.flame,{u={TunnelDodgeBlend=true}}),bt.sunset,bt.redgradient,bt.mars,bt.cloudy,bt.redDusk,bt.moonPurple,bc(bt._,{weight=4})},
}

local pt = {
  lights={"lights_default.png", "lights_default-c.png"},
  lightsMoonblue={"lights_moonblue.png", "lights_moonblue-c.png"},
  lightsPurplish={"lights_purplish.png"},
  lightsOrangePink={"lights_orangepink.png"},
  lightsPink={"lights_pink.png", "lights_pink-c.png"},
  lightsSea={"lights_sea.png", "lights_sea-c.png"},
  lightsYellow={"lights_yellow.png"},
  lightsYellowPurple={"lights_yellow.png", "lights_purplish.png"},
  lightsYellowGreen={"lights_yellowgreen.png"},
  twilight={"twilight.png", "twilight-c.png"},
  streetLanterns={"street_lanterns.png", "street_lanterns-c.png"},
  starParticles={"star_particles.png", "star_particles-c.png"},
  squares={"squares.png", "squares-c.png"},
}



local bgs = {
  arrows={
    Tunnel={
      Tex={{"arrows-large.png", "arrows-large-c.png"},{"arrows-small.png", "arrows-small-c.png",speed=0.7}},
      u={ Sides=4, Stretch=0.2, ScaleX=0.8, ScaleY=0.8, Fog=15.0 },
    },
    Bg={ Base={Tex={bt.redgradient,bt._}} },
    Particle={
      Tex={"icons.png", "icons-c.png"},
      u={ Scale=0.2, OffsetY=-0.2 }
    },
    speed=0.8,weight=2
  },
  technoEye={
    Bg={ Base={Tex=bt.cyberspace} },
    Center={
      Tex="techno-eye.png",
      u={Pulse=true, Float=true, Scale=2.8},
      LayerEffect={Tex="glowshine.png", Fade=true}
    },
    Tunnel={
      Tex={"electro-blue.png", "electro-c.png"},
      u={Sides=8, Stretch=0.3, ScaleY=0.9, Fog=10.0, ExtraRotation=-0.125}
    },
  },
  waveBlue={
    Bg={ Base={Tex={bc(bt.watervault,{u={Center=false}}),bc(bt.underwater,{u={TunnelDodgeBlend=true,Center=false}}),bc(bt.cyberspace,{u={Center=false}}),bc(bt.ocean,{u={Center=false}}),bt.grass,bt.deepsea,bt.cyber,bc(bt.desert,{u={Center=false}}),bt.sky,bt.moonBlue,{"city.png"},bc(bt.cyberspaceNight,{u={Center=false}}),bc(bt.undersea,{u={Center=false,TunnelDodgeBlend=true}}),bc(bt._,{weight=5})},  ScaleSoft=true}}, -- Customised version of bt.blue
    Tunnel={
      Tex={{"wave-blue.png", "wave-blue-c.png"},{"wave-green.png", "wave-green-c.png"}},
      u={Sides=4, Stretch=0.15, ScaleX=0.8, ScaleY=0.8, FlashEffect=true, Fog=20.0}
    },
    Center={ Tex={{"moon2.png","moon2-c.png"},{0}}, u={Scale=9.0, OffsetY=-0.05}, LayerEffect={Tex="moon2_shine.png", Glow=true, Scale=0.8, DodgeBlend=true} },
    Particle={ Tex=pt.lightsMoonblue, u={OffsetY=-0.02, Amount=4, Speed=2.0} },
    weight=2
  },
  waveRed={
    Bg={ Base={Tex=btCollections.red, ScaleSoft=true} },
    Tunnel={
      Tex={"wave-red.png","wave-red-c.png"},
      u={Sides=4, Stretch=0.15, ScaleX=0.8, ScaleY=0.8, FlashEffect=true, Fog=20.0}
    },
    Center={ Tex={{"moon_pink.png","moon_pink-c.png"},{0}}, u={Scale=8.0, OffsetY=-0.05}, LayerEffect={Tex="moon_pink_shine.png", Glow=true, DodgeBlend=true, Scale=0.8} },
    Particle={ Tex=pt.lightsPink, u={OffsetY=-0.02, Amount=4, Speed=2.0} },
  },
  waveOrange={
    Bg={ Base={Tex={bc(bt.twilight,{u={Center=false}}),bc(bt.grass,{u={Center=false}}),bt.redblur,bt.redgradient,bt.redDusk,bc(bt.star,{u={Center=false}}),bt.cyberspace,bt.sunset,bc(bt.cyber,{u={Center=false}}),bc(bt.galaxy,{u={Center=false}}),bc(bt.desertYellowClear,{u={Center=false}}),bc(bt.fantasy,{u={Center=false}}),bt.moonPurple,bc(bt.undersea,{u={Center=false}}),{"city.png"},bc(bt._,{weight=6})}, ScaleSoft=true} },
    Tunnel={
      Tex={"wave-orange.png","wave-orange-c.png"},
      u={Sides=4, Stretch=0.15, ScaleX=0.8, ScaleY=0.8, FlashEffect=true, Fog=20.0}
    },
    Center={ Tex={{"moon_orange.png","moon_orange-c.png"},{0}}, u={Scale=8.0, OffsetY=-0.05}, LayerEffect={Tex="moon_orange_shine.png", Glow=true, DodgeBlend=true, Scale=0.8} },
    Particle={ Tex=pt.lightsOrangePink, u={OffsetY=-0.02, Amount=4, Speed=2.0} },
  },
  waveRedNoise={
    Bg={
      Layer={Tex={{"wave4.jpg", "wave4-c.jpg"}}},
      Pivot={0.35}
    }
  },
  waveGalaxy={Bg={
    Layer={Tex={{"wave6.jpg", "wave6-c.jpg"}}},
    Pivot={0.35}
  }},
  game={
    Bg={Base={Tex="game.png", Tilt=false}, Overlay={Tex="game-f.png", Float=true, FlashEffect=true, FloatFactor=2.0}},
    Center={Tex={"logo.png", "logo-c.png"}, u={Scale=3.8, Tilt=true}},
    Tunnel={Tex="game.png", u={Sides=4, Stretch=0.15, ScaleX=0.8, ScaleY=0.8, FlashEffect=true, Fog=15.0, ExtraRotation=0.375}},
    Particle={Tex={bc(pt.squares,{u={ParticleSpeed=1}}),{"triangles.png",weight=2}},
      u={OffsetY=-0.1, Amount=5, Speed=2.0, Scale=0.8}
    }
  },
  seaNight={ -- todo: add bg landscapeoffset
    Bg={Base={Tex="sea-night.png", OffsetY=-0.19, ScaleSoft=true}, Overlay={Tex="sea-night-f.png", Float=true, OffsetY=-0.17}},
    Center={ Tex="ship-night.png", u={Scale=2.5, Float=true, FloatFactor=0.5, SnapToTrack=false}, LayerEffect={Tex="kac-hikari-2.png"}},
    Particle={ Tex="shines2.png", u={Speed=1.8, Amount=9} },
    -- Tunnel={},
    luaParticleEffect = { particles = { {"star-particle.png", 32} } }
  },
  seaStorm={
    Bg={Base={Tex="sea-storm.png", OffsetY=-0.13, ScaleSoft=true}, Overlay={Tex="sea-storm-f.png", Float=true, OffsetY=-0.17}},
    Center={ Tex="ship-storm.png", u={Scale=2.5, Float=true, FloatFactor=0.5, SnapToTrack=false}, LayerEffect={Tex="kac-hikari.png"}},
    Particle={ Tex="shines2.png", u={Speed=1.8, Amount=9} },
    -- Tunnel={},
  },
  seaIce={
    Bg={Base={Tex="sea-ice.png", OffsetY=-0.1, ScaleSoft=true}, Overlay={Tex="sea-ice-f.png", Float=true, OffsetY=-0.15}},
    Center={ Tex="ship-ice.png", u={Scale=2.5, Float=true, FloatFactor=0.5, SnapToTrack=false}, LayerEffect={Tex="kac-hikari-2.png"}},
    Particle={ Tex="shines1.png", u={Scale=0.3, OffsetY=-0.3, Speed=1.8, Amount=9} },
    -- Tunnel={},
    luaParticleEffect = { particles = { {"star-particle.png", 32} } }
  },
  seaThunder={
    Bg={Base={Tex="sea-thunder.png", OffsetY=-0.15, ScaleSoft=true}, Overlay={Tex="sea-thunder-f.png", Float=true, OffsetY=-0.16}},
    Center={ Tex="ship-storm.png", u={Scale=2.5, Float=true, FloatFactor=0.5, SnapToTrack=false}, LayerEffect={Tex="kac-hikari.png"}},
    Particle={ Tex="shines2.png", u={Speed=1.8, Amount=9} },
  },
  seaDay={ -- todo: fixlandscape, fix rotation
    Bg={Base={Tex="sea-day.png", ScaleSoft=true}, Overlay={Tex="sea-day-f.png", Float=true, OffsetY=-0.1}},
    Center={Tex="ship-day.png", u={Scale=2, Float=true, FloatFactor=0.5, OffsetY=0.02, SnapToTrack=false}, LayerEffect={Tex="kac-hikari.png"}},
    Particle={ Tex="shines2.png", u={Speed=1.8, Amount=9} },
    bright=true,
    -- Tunnel={},
  },
  sakuraRainbow={
    Bg={Base={Tex=bt.sakura, ScaleSoft=true}},
    Center={
      Tex="rainbow.png", u={Scale=1.5, FadeEffect=true},
      LayerEffect={Tex="kac_hikari_sakura.png"}
    },
    -- Tunnel: rainbow rings?! probably not xd
    Particle={Tex="shines1.png", u={Speed=1.6, OffsetY=-0.3, Amount=6, Scale=0.35}},
    luaParticleEffect={particles={{"petal1.png", 140},{"petal2.png", 40},{"petal3.png", 140}}},
    bright=true
  },
  -- colorBokeh={Bg={Layer={Tex={"colorbokeh.jpg", "colorbokeh-c.jpg"} }, u={Pivot=0.35}}}, -- todo: find working bgs (?)
  smoke1={Bg={
    Base={Tex={bt.fantasy,bt.cyberspaceNight,bt.undersea,bt.watervault,bt.underwater,bt.cyberspace,bt.ocean,bt.grass,bt.deepsea,bt.cyber,bt.desertYellowClear,bt.sky,bc(bt._,{weight=5})},ScaleSoft=true},
    Layer={Tex={"smoke.jpg", "smoke-c.jpg"}},
    u={Pivot=0.35}
  }},
  -- sparkles1={Bg={Layer={Tex={"sparkles1.jpg", "sparkles1-c.jpg"}, ScaleHard=true }}},
  -- domeLayer={Bg={
  --   Base={Tex={bt.redblur,bt._}},
  --   Layer={Tex={{"spider1.jpg", "spider1-c.jpg"},{"spider2.jpg", "spider2-c.jpg"},{"spider3.jpg", "spider3-c.jpg", speed=0.75, u={BgPivot=0.27}}}},
  --   u={Pivot=0.36}
  -- },weight=2},
  -- electro1={Bg={
  --   Base={Tex={bt.redblur,bt.cyber,bt._}},
  --   Layer={Tex={"electro1.jpg", "electro1-c.jpg"}, brightenLayer=0.6}, u={Pivot=0.35}}
  -- },
  -- electro2={Bg={Layer={Tex={"electro2.jpg", "electro2-c.jpg"} }, u={Pivot=0.3}}},
  -- plasmaTunnel={Bg={Layer={Tex={"plasmatunnel.jpg", "plasmatunnel-c.jpg"}, }, u={Pivot=0.37}}, speed=0.75, bright=true}, -- my eyes are burning
  -- xcalibur={Bg={Base={Tex={"anim/xcalibur.jpg", "anim/xcalibur-c.jpg"}}, u={Pivot=0.36}}, speed=0.3},
  goldleaves={
    Bg={Base={Tex={"anim/goldleaves.jpg", "anim/goldleaves-c.jpg"}}},
    Particle={ Tex=pt.lightsYellow, u={Speed=1.8, OffsetY=-0.1, Amount=9} },
    speed=0.6
  },
  technocircle={
    Bg={Base={Tex={"anim/technocircle.jpg", "anim/technocircle-c.jpg"}, ScaleSoft=true}, u={Pivot=0.37}},
    Particle={ Tex="shines2.png", u={Speed=1.8, OffsetY=-0.15, Amount=7} },
    speed=0.6, bright=true
  },
  snow={
    Bg={Base={Tex={"anim/snow.jpg", "anim/snow-c.jpg"}}, u={Pivot=0.3}},
    Particle={Tex="shines1.png", u={Speed=1.9, OffsetY=-0.3, Amount=8, Scale=0.4}},
  },
  sky={
    Bg={Base={Tex={bt.skyIv,bt.skyIv2}}},
    Tunnel={Tex="clouds.png", u={Sides=16, Fog=15, Stretch=0.07, VortexEffect=true}},
    Center={
      Tex={{speed=0.9, u={TunnelFog=100, TunnelVortexFactor=5}},{"sdvx_iv.png",u={CenterScale=10,CenterOffsetY=0}}},
      u={Float=true, Scale=5, FloatXFactor=2, OffsetY=-0.02}
    },
    Particle={Tex="shines1.png", u={Amount=8, OffsetY=-0.3, Speed=1.9, Scale=0.5}},
    speed=0.5, bright=true
  },
  -- skyDark={
  --   Bg={Base={Tex={"sky-iv-dark.jpg"}}},
  --   Tunnel={Tex={"clouds-dark.png","clouds-dark-c.png"}, u={Sides=16, Fog=100, Stretch=0.07, VortexEffect=true, VortexFactor=5}},
  --   speed=0.9,
  -- },
  hexagons={
    Tunnel={Tex={{"hexagons.png", "hexagons-c.png"},{"hexagons-gray.png","hexagons.png"}}, u={ExtraRotation=-0.125, Fog=30}},
    Particle={Tex="hexes.png", u={Amount=3, OffsetY=-0.2, Speed=1.9, Scale=0.7}},
    speed=1.2,weight=2
  },
  dome={ -- todo: fix rotation
    Bg={Base={Tex={bt.redblur,bt.redgradient,bt._}}},
    Tunnel={Tex={"dome.png","dome-c.png"}, u={ExtraRotation=-0.125/2, Fog=30, Stretch=0.09}},
    Center={
      Tex={{"glowshine_green.png",weight=2},{0}}, u={Scale=13, Pulse=true, Glow=true},
      LayerEffect={Tex="glowshine_sun.png", Glow=true, Scale=0.8}
    },
    Particle={Tex=pt.lightsYellowGreen, u={Amount=4, OffsetY=0, Speed=1.9}},
    speed=0.6,
  },
  domeRed={
    Bg={Base={Tex={bc(bt.redblur,{u={CenterScale=9}}),bt.redgradient,bt._}}},
    Tunnel={Tex={"dome-red.png","dome-red-c.png"}, u={ExtraRotation=-0.125/2, Fog=30, Stretch=0.09}},
    Center={
      Tex={{"glowshine_pink.png",weight=2},{0}}, u={Scale=13, Pulse=true, Glow=true},
      LayerEffect={Tex="glowshine_orange.png", Glow=true, Scale=0.8}
    },
    Particle={Tex=pt.lightsOrangePink, u={Amount=4, OffsetY=0, Speed=1.9}},
    speed=0.6
  },
  iseki={
    Tunnel={
      Tex={{"iseki.png","iseki-c.png",u={TunnelExtraRotation=-0.125/2}}},
      u={Sides=16, Stretch=0.1, FlashEffect=true, Fog=25.0}
    },
    Center={Tex={{"kac_maxima_gold.png"},{0,weight=4}}, u={Float=true, Scale=5, OffsetY=0.04}, LayerEffect={Tex="kac_hikari_iseki.png", Scale=0.7}},
    Particle={Tex=pt.lightsYellow, u={Amount=6, OffsetY=0, Speed=1.9}},
    speed=0.5,
  },
  idofront={
    Tunnel={
      Tex={{"idofront.png","idofront-c.png",u={TunnelExtraRotation=-0.125/2}}},
      u={Sides=16, Stretch=0.1, Fog=25.0}
    },
    Particle={Tex=pt.lightsPurplish, u={Amount=5, Scale=1.3, Speed=1.9}},
  },
  genom={
    Tunnel={
      Tex={{"genom.png","genom-c.png",u={TunnelExtraRotation=-0.125/2*0}}},
      u={Sides=16, Stretch=0.1, Fog=25.0}
    },
    Particle={Tex=pt.lightsOrangePink, u={Amount=5, Scale=1.3, Speed=1.9}},
    speed=0.7
  },
  twilight={
    Bg={ Base={Tex=bt.twilight,  ScaleSoft=true}},
    Tunnel={Tex={"wave-orange.png","wave-orange-c.png"}, u={Sides=4, Stretch=0.15, ScaleX=0.8, ScaleY=0.8, FlashEffect=true, Fog=14.0}},
    Center={ Tex="moon_twilight.png", u={Scale=8.0, OffsetY=-0.05}, LayerEffect={Tex="moon_twilight_shine.png", Glow=true} },
    Particle={ Tex=pt.twilight, u={OffsetY=-0.3, Amount=5, Speed=1.5, Scale=0.5} },
  },
  shinwa={ -- todo: put clouds in extra layer of center, remove weird 'bg is static but overlay can tilt' logic
    Bg={ Base={Tex="cyberspace_sunrise.png", OffsetY=-0.23, Tilt=false, ClampTiling=true}, Overlay={Tex="cyberspace_sunrise-f.png", Tilt=true, OffsetY=-0.1}},
    Center={ Tex={"shinwa.png"}, u={Scale=9.0, OffsetY=0, Float=true, Pulse=true}, LayerEffect={Tex="cyberspace_shine.png", Glow=true, Alpha=0.8, Scale=1, Rotate=true, RotateSpeed=-5} },
    Particle={ Tex=pt.lightsYellow, u={OffsetY=-0.3, Amount=9, Speed=2, Scale=0.5} },
  },
  beach={
    Bg={ Base={Tex="beach.png", ScaleSoft=true}},
    Center={ Tex={"glowshine_orange.png","glowshine_sun.png"}, u={Scale=8.0, OffsetY=-0.05, Float=true}, LayerEffect={Tex="glowshine_sun.png", Glow=true, Scale=0.9} },
    Particle={ Tex=pt.lightsYellow, u={OffsetY=-0.3, Amount=9, Speed=2, Scale=0.5} },
    bright=true
  },
  sonar={
    Bg={ Base={Tex={bt.undersea,bt.watervault,bt.underwater}}},
    Center={ Tex={"magic_circle.png","magic_circle-c.png"}, u={Scale=2.6, Rotate=true}, LayerEffect={Tex="sonar.png", Rotate=true, RotateSpeed=-10, Scale=3} },
    Particle={ Tex=pt.lightsSea, u={OffsetY=-0.1, Amount=9, Speed=1.7} },
  },
  star={
    Bg={ Base={Tex=bt.star, ScaleSoft=true, Tilt=false}},
    Center={ Tex="star_core.png", u={Scale=2.15, Tilt=false, SnapToTrack=false, OffsetY=-0.04}, LayerEffect={Tex="star_core.png", Glow=true, DodgeBlend=true } },
    Particle={ Tex=pt.starParticles, u={OffsetY=-0.1, Amount=9, Speed=1.7} },
    Tunnel={ Tex={"electro.png", "electro-c.png"}, u={Sides=12, Stretch=0.12, ScaleY=0.9, Fog=18.0, ExtraRotation=-0.125}},
  },
  -- beams={
  --   Tunnel={
  --     Tex={{"beams.png","beams-c.png",u={TunnelExtraRotation=-0.125/2}}},
  --     u={Sides=16, Stretch=0.1, Fog=25.0}
  --   },
  -- },
}

-- local bgTrumpcard=bgs.shinwa
-- local bgNestedIndices = {
--   -- BgBase=1,
--   -- Tunnel=1,
--   Center=1
-- }

local function stringToNumber(str)
  local number = 0
  for i = 1, string.len(str) do
    number = number + string.byte(str, i)
  end
  return number
end

local function sign(x)
  return x>0 and 1 or x<0 and -1 or 0
end

local function setUniform(key, value)
  local valueType = type(value)
  if valueType == "number" then
    background.SetParamf(key, value)
  elseif valueType == "boolean" then
    background.SetParami(key, value and 1 or 0)
  else
    game.Log("Weird param type was passed to setUniform", 1)
  end
end

-----------------
-- PARTICLE STUFF
-----------------

local resx, resy = game.GetResolution()
local portrait = resy > resx
local desw = portrait and 720 or 1280
local desh = desw * (resy / resx)
local scale = resx / desw

local shouldRenderParticles = false
local particleTextures = {}
local particles = {}
local psizes = {}

local particleCount = 30
local particleSizeSpread = 0.5

local function initializeParticle(initial)
	local particle = {}
	particle.x = math.random()
	particle.y = math.random() * 1.2 - 0.1
	if not initial then particle.y = -0.1 end
	particle.r = math.random()
	particle.s = (math.random() - 0.5) * particleSizeSpread + 1.0
	particle.xv = 0
	particle.yv = 0.1
	particle.rv = math.random() * 2.0 - 1.0
  particle.p = math.random() * math.pi * 2
  particle.t = math.random(1, #psizes)
	return particle
end

local function renderParticles(deltaTime)
  local alpha = 0.3 + 0.5 * background.GetClearTransition()
  for i,p in ipairs(particles) do
		p.x = p.x + p.xv * deltaTime
		p.y = p.y + p.yv * deltaTime
		p.r = p.r + p.rv * deltaTime
		p.p = (p.p + deltaTime) % (math.pi * 2)
		
		p.xv = 0.5 - ((p.x * 2) % 1) + (0.5 * sign(p.x - 0.5))
		p.xv = math.max(math.abs(p.xv * 2) - 1, 0) * sign(p.xv)
		p.xv = p.xv * p.y
		p.xv = p.xv + math.sin(p.p) * 0.01
		
		gfx.Save()
		gfx.ResetTransform()
		gfx.Translate(p.x * resx, p.y * resy)
		gfx.Rotate(p.r)
		gfx.Scale(p.s * scale, p.s * scale)
		gfx.BeginPath()
		gfx.GlobalCompositeOperation(gfx.BLEND_OP_LIGHTER)
		gfx.ImageRect(-psizes[p.t]/2, -psizes[p.t]/2, psizes[p.t], psizes[p.t], particleTextures[p.t], alpha, 0)
		gfx.Restore()
		if p.y > 1.1 then 
			particles[i] = initializeParticle(false)
		end
	end
	gfx.ForceRender()
end

local function getRandomItemFromArray(array, seed)
  if #array == 1 then return array[1] end

  local weightedArray = {}
  for i, value in ipairs(array) do
    local weight = value.weight or 1
    for j = 1, weight do
      weightedArray[#weightedArray+1] = value
    end
  end

  math.randomseed(stringToNumber(seed))
  return weightedArray[math.random(#weightedArray)]
end

local function getImageDimensions(imagePath)
  return gfx.ImageSize( gfx.CreateImage(background.GetPath().."textures/"..imagePath, 0) )
end

local function filterArray(array, propertyToRemove)
  local newArray = {}
  for i, v in ipairs(array) do
    if not v[propertyToRemove] then newArray[#newArray+1] = v end
  end
  return newArray
end

local function filterTable(table, propertyToRemove)
  local newTable = {}
  for k, v in pairs(table) do
    if not v[propertyToRemove] then newTable[k] = v end
  end
  return newTable
end

local function loadTextures(prefix, tex, subFolder, checkAnim, noAnimCallback, setNormalVersion)
  local texture
  if type(tex) == "string" then
    texture = {tex}
  elseif type(tex[1]) == "string" then
    texture = tex
  else
    if dark then tex = filterArray(tex, "bright") end
    if bgNestedIndices and bgNestedIndices[prefix] then
      texture = tex[bgNestedIndices[prefix]]
    else
      texture = getRandomItemFromArray(tex, prefix..gameplay.title..gameplay.artist) -- todo: improve seeding
    end
  end

  if texture[1] == 0 then
    return false
  end

  if texture[1] then
    if setNormalVersion then
      setUniform(prefix.."NormalVersion", true)
    end
    background.LoadTexture(prefix.."Tex", "textures/"..subFolder.."/"..texture[1])
  end
  if texture[2] then
    setUniform(prefix.."ClearVersion", true)
    background.LoadTexture(prefix.."ClearTex", "textures/"..subFolder.."/"..texture[2])
  end
  if checkAnim and texture[1] then
    local w, h = getImageDimensions(subFolder.."/"..texture[1])
    if w / h > 2 then
      setUniform(prefix.."Anim", true)
      setUniform(prefix.."AnimFramesCount", math.floor(w / 600))
    elseif noAnimCallback then
      noAnimCallback(w, h)
    end
  end

  if texture.u then
    for k,v in pairs(texture.u) do
      delayedOperations.u[k] = v
    end
  end
  if texture.speed then delayedOperations.speed = texture.speed end
  return true
end

local function setUniformsRaw(uniforms)
  for k,v in pairs(uniforms) do setUniform(k, v) end
end

local function setUniforms(prefix, uniforms, subFolder, checkAnim, noAnimCallback)
  for k, v in pairs(uniforms) do
    if k == "Tex" then
      loadTextures(prefix, v, subFolder, checkAnim, noAnimCallback)
    else
      setUniform(prefix..k, v)
    end
  end
end

local function loadPart(prefix, part, subFolder, checkAnim, setNormalVersion)
  local loaded
  if part.Tex then
    loaded = loadTextures(prefix, part.Tex, subFolder, checkAnim, nil, setNormalVersion)
  else
    loaded = true
  end
  if loaded then
    setUniform(prefix, true)
  end
  if part.u then
    setUniforms(prefix, part.u, subFolder)
  end
end

local function randomItemFromTable(table)
  local keys = {}
  for key, value in pairs(table) do
    local weight = value.weight or 1
    for i = 1, weight do
      keys[#keys+1] = key
    end
  end
  local index = keys[math.random(#keys)]
  return table[index], index
end

local function processDelayedOperations()
  setUniformsRaw(delayedOperations.u)
  if delayedOperations.speed then background.SetSpeedMult(delayedOperations.speed) end
end

local function loadBackground(bg)
  if bg.Bg then
    local part = bg.Bg
    local prefix = "Bg"
    loadPart(prefix, part, "background")
    if part.Base then
      setUniform(prefix.."Base", true)
      setUniforms(prefix.."Base", part.Base, "background", true, function(w,h) setUniform(prefix.."Base".."AR", w / h) end)
    end
    if part.Overlay then
      setUniform(prefix.."Overlay", true)
      setUniforms(prefix.."Overlay", part.Overlay, "background")
    end
    if part.Layer then
      setUniform(prefix.."Layer", true)
      setUniforms(prefix.."Layer", part.Layer, "layer", true)
    end
  end
  if bg.Center then
    local part = bg.Center
    local prefix = "Center"
    loadPart(prefix, part, "center", true, true)
    if part.LayerEffect then
      setUniform(prefix.."LayerEffect", true)
      setUniforms(prefix.."LayerEffect", part.LayerEffect, "center")
    end
  end
  if bg.Tunnel then
    local part = bg.Tunnel
    local prefix = "Tunnel"
    loadPart(prefix, part, "tunnel")
  end
  if bg.Particle then
    local part = bg.Particle
    local prefix = "Particle"
    loadPart(prefix, part, "particle")
  end

  background.SetSpeedMult(bg.speed or 1.0)

  processDelayedOperations()

  if bg.luaParticleEffect then
    shouldRenderParticles = true
    for i, p in ipairs(bg.luaParticleEffect.particles) do
      particleTextures[i] = gfx.CreateImage(background.GetPath().."textures/luaparticle/" .. p[1], 0)
      psizes[i] = p[2]
    end
    for i=1,particleCount do
      particles[i] = initializeParticle(true)
    end
  end
end

if dark then
  bgs = filterTable(bgs, "bright")
end

math.randomseed(stringToNumber(gameplay.title))
local bg, k = randomItemFromTable(bgs)
game.Log("bg:", 0)
game.Log(tostring(k), 0)
if bgTrumpcard then bg = bgTrumpcard end
loadBackground(bg)

function render_bg(deltaTime)
  background.DrawShader()
  if shouldRenderParticles then renderParticles(deltaTime) end
end
