#version 330
#extension GL_ARB_separate_shader_objects : enable

layout(location=1) in vec2 texVp;
layout(location=0) out vec4 target;

uniform ivec2 screenCenter;
// x = bar time
// y = off-sync but smooth bpm based timing
// z = real time since song start
uniform vec3 timing;
uniform ivec2 viewport;
uniform float objectGlow;
// bg_texture.png
uniform vec2 tilt;
uniform float clearTransition;

#define HALF_PI 1.570796326794
#define PI 3.14159265359
#define TWO_PI 6.28318530718

// Background
uniform int Bg = 0;

uniform float BgPivot = .27;

uniform int BgBase = 0;
uniform sampler2D BgBaseTex;
uniform int BgBaseClearVersion = 0;
uniform sampler2D BgBaseClearTex;
uniform float BgBaseOffsetY = 0.;
uniform int BgBaseTilt = 1;
uniform float BgBaseAR = 1.125;
uniform int BgBaseAnim = 0;
uniform float BgBaseAnimFramesCount; // should be int
uniform int BgBaseScaleSoft = 0;
uniform int BgBaseClampTiling = 0;

uniform int BgOverlay = 0;
uniform sampler2D BgOverlayTex;
uniform int BgOverlayClearVersion = 0;
uniform sampler2D BgOverlayClearTex;
uniform int BgOverlayFloat = 0;
uniform float BgOverlayFloatFactor = 1.;
uniform float BgOverlayOffsetY = 0.;
uniform int BgOverlayFlashEffect = 0;
uniform int BgOverlayTilt = 1;

uniform int BgLayer = 0;
uniform sampler2D BgLayerTex;
uniform int BgLayerClearVersion = 0;
uniform sampler2D BgLayerClearTex;
uniform float BgLayerAnimFramesCount; // should be int
uniform float BgLayerBrighten = 0.;
uniform int BgLayerScaleHard = 0;

// Center
uniform int Center = 0;
uniform int CenterNormalVersion = 0;
uniform sampler2D CenterTex;
uniform int CenterClearVersion = 0;
uniform sampler2D CenterClearTex;
uniform float CenterScale = 3.; // todo: change to smaller
uniform float CenterFloatFactor = 1.;
uniform float CenterFloatXFactor = 0.;
uniform float CenterFloatRotationFactor = 0.;
uniform int CenterPulse = 0;
uniform int CenterFloat = 0;
uniform int CenterFadeEffect = 0;
uniform int CenterTilt = 1;
uniform float CenterOffsetY = 0.;
uniform int CenterGlow = 0;
uniform int CenterSnapToTrack = 1;
uniform int CenterRotate = 0;

uniform int CenterLayerEffect = 0;
uniform sampler2D CenterLayerEffectTex;
uniform int CenterLayerEffectFade = 0;
uniform int CenterLayerEffectRotate = 0;
uniform float CenterLayerEffectRotateSpeed = 1.;
uniform int CenterLayerEffectGlow = 0;
uniform float CenterLayerEffectScale = 1.;
uniform int CenterLayerEffectDodgeBlend = 0;
uniform float CenterLayerEffectAlpha = 1.;

uniform int CenterAnim = 0;
uniform float CenterAnimFramesCount; // should be int

// Tunnel
uniform int Tunnel = 0;
uniform sampler2D TunnelTex;
uniform int TunnelClearVersion = 0;
uniform sampler2D TunnelClearTex;
uniform float TunnelSides = float(8); // should be int
uniform float TunnelStretch = .15; // lower = "Stretchier"
uniform float TunnelScaleX = 1.; // for scale: lower is longer i believe
uniform float TunnelScaleY = 1.;
uniform float TunnelFog = 10.;
uniform int TunnelFlashEffect = 0;
uniform float TunnelExtraRotation = 0.; // 1. == 2*PI radians
uniform int TunnelVortexEffect = 0;
uniform float TunnelVortexFactor = 1.;
uniform int TunnelDodgeBlend = 0;

// Particle
uniform int Particle = 0;
uniform sampler2D ParticleTex;
uniform int ParticleClearVersion = 0;
uniform sampler2D ParticleClearTex;
uniform float ParticleSpeed = 1.;
uniform float ParticleScale = 1.;
uniform float ParticleOffsetY = 0.;
uniform float ParticleAmount = float(2); // should be int



// MISC CONSTANTS
float TunnelSpeed = 1.;
float TunnelBaseRotation = 0.0; // Default rotation in radians
float TunnelBaseTexRotation = 0.5 * HALF_PI; // Rotation of texture for alignment, in radians
vec2 TunnelScale = vec2(TunnelScaleX, TunnelScaleY);
float bgLayerAR = 1.25;
vec2 bgPivot = vec2(.5, BgPivot);
vec2 hardScale = vec2(.7, .4); // Base scale (lower is more scaled: 1/x) <> how much is subtracted on rotation
vec2 softScale = vec2(.9, .1);
float rotateScaleSmoothnessFactor = 1.3; // Higher is smoother

float portrait(float a, float b) {
	if (viewport.y > viewport.x) {
		return a;
	} else {
	  return b;
	}
}

vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

float blendOverlay(float base, float blend) {
	return base<0.5?(2.0*base*blend):(1.0-2.0*(1.0-base)*(1.0-blend));
}
vec3 blendOverlay(vec3 base, vec3 blend) {
	return vec3(blendOverlay(base.r,blend.r),blendOverlay(base.g,blend.g),blendOverlay(base.b,blend.b));
}
vec3 blendOverlay(vec3 base, vec3 blend, float opacity) {
	return (blendOverlay(base, blend) * opacity + base * (1.0 - opacity));
}

float blendScreen(float base, float blend) {
	return 1.0-((1.0-base)*(1.0-blend));
}
vec3 blendScreen(vec3 base, vec3 blend) {
	return vec3(blendScreen(base.r,blend.r),blendScreen(base.g,blend.g),blendScreen(base.b,blend.b));
}
vec3 blendScreen(vec3 base, vec3 blend, float opacity) {
	return (blendScreen(base, blend) * opacity + base * (1.0 - opacity));
}

float blendLinearDodge(float base, float blend) {
	// Note : Same implementation as BlendAddf
	return min(base+blend,1.0);
}
vec3 blendLinearDodge(vec3 base, vec3 blend) {
	// Note : Same implementation as BlendAdd
	return min(base+blend,vec3(1.0));
}
vec3 blendLinearDodge(vec3 base, vec3 blend, float opacity) {
	return (blendLinearDodge(base, blend) * opacity + base * (1.0 - opacity));
}


vec2 ScaleUV(vec2 uv,float scale,vec2 pivot) {
	return (uv - pivot) * scale + pivot;
}
vec2 ScaleUV(vec2 uv,vec2 scale,vec2 pivot) {
	return (uv - pivot) * scale + pivot;
}

vec2 rotatePoint(vec2 cen,float angle,vec2 p) {
  float s = sin(angle);
  float c = cos(angle);

  // translate point back to origin:
  p.x -= cen.x;
  p.y -= cen.y;

  // rotate point
  float xnew = p.x * c - p.y * s;
  float ynew = p.x * s + p.y * c;

  // translate point back:
  p.x = xnew + cen.x;
  p.y = ynew + cen.y;
  return p;
}

float mirrorTile(float val, float lower, float upper) {
	if (val < lower) return lower * 2 - val;
	if (val > upper) return upper * 2. - val;
	return val;
}
vec2 mirrorTile(vec2 val, float lower, float upper) {
	val.x = mirrorTile(val.x, lower, upper);
	val.y = mirrorTile(val.y, lower, upper);
	return val;
}

float getRotateScaleModifier(float rotation) {
	return smoothstep(0., HALF_PI*.5*rotateScaleSmoothnessFactor, 2 * abs(asin(sin(0.5*rotation*TWO_PI))*1.));
	// return min(2. * abs( asin(sin(0.5*layerRotation*TWO_PI))*2. ), .5*HALF_PI ) / (.5*HALF_PI);
}

///////////////////
// END RENDER GIF BG
///////////////////

vec3 hsv2rgb(vec3 c) {
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

// Reference to
// https://github.com/Ikeiwa/USC-SDVX-IV-Skin  (Ikeiwa)
// http://thndl.com/square-shaped-shaders.html
// https://thebookofshaders.com/07/

float GetDistanceShape(vec2 st, /*int*/float N){
    vec3 color = vec3(0.0);
    float d = 0.0;

    // Angle and radius from the current pixel
    float a = atan(st.x,st.y)+PI;
    float r = TWO_PI/N;

    // Shaping function that modulate the distance
    d = cos(floor(.5+a/r)*r-a)*length(st);

    return d;

}

float mirrored(float v) {
    float m = mod(v, 2.0);
    return mix(m, 2.0 - m, step(1.0, m));
}

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec2 rotate2d(vec2 uv,float _angle, vec2 pivot){
    return (uv - pivot) * mat2(cos(_angle),-sin(_angle),
                sin(_angle),cos(_angle)) + pivot;
}

void main() {
	target.rgba = vec4(vec3(0.),1.);
	
	// MAIN SETUP
	float beatTime = mod(timing.y,1.0);

  float ar = float(viewport.x) / float(viewport.y);
	float var = float(viewport.y) / float(viewport.x);

	vec2 screenUV = vec2(texVp.x / viewport.x, texVp.y / viewport.y);

	vec2 uv = screenUV;
	uv.x *= ar;

	vec2 center = vec2(screenCenter) / vec2(viewport);
	center.x *= ar;

	vec2 point = uv;
	float bgrot = dot(tilt, vec2(0.5, 1.0));
	point = rotatePoint(center, TunnelBaseRotation + (bgrot * TWO_PI), point);

	// BACKGROUND
	vec4 backgroundTexture = vec4(0.,0.,0.,1.);
	vec4 backgroundTexture2 = vec4(0.);
	vec4 layerTexture = vec4(0.);
	if (Bg == 1) {
		// Bg => BgOverlay => BgLayer
		for (int i=0;i<3;++i) {
			if ((i == 0 && BgBase == 0) || (i == 1 && BgOverlay == 0) || (i == 2 && BgLayer == 0))
				continue;

			bool isAnim = (i < 2 && BgBaseAnim == 1) || i == 2;
			float frameCount;
			if (isAnim) {
				frameCount = i < 2 ? BgBaseAnimFramesCount : BgLayerAnimFramesCount;
			}

			vec2 backgroundUV = screenUV;
			// backgroundUV.x -= 0.5;
			if (BgOverlay == 1 && i == 1) {
				backgroundUV.y -= portrait(BgOverlayOffsetY,-0.5); // todo: figure out landscape
				if (BgOverlayFloat == 1)
					backgroundUV.y += sin(timing.z) * 0.003 * BgOverlayFloatFactor;
			} else {
				backgroundUV.y -= portrait(BgBaseOffsetY,-0.5); // todo: figure out landscape
			}
			// backgroundUV.x *= ar;
			// backgroundUV /= 1.2;
			// backgroundUV /= ar;
			// backgroundUV.x += 0.5;
			backgroundUV.y -= portrait(0.15,0.05);
			backgroundUV.y /= ar;

			if ((i < 2 && BgBaseTilt == 1) || (i == 1 && BgOverlayTilt == 1) || i == 2) {
				float rotation = i < 2 && !(i == 1 && BgBaseTilt == 0) // todo: tilt to maximum point?
					? dot(tilt, vec2(0.5, 1.0))
					: dot(tilt, vec2(1.0));
				float scaleModifier = getRotateScaleModifier(rotation);
				vec2 scaleConst = ((i == 2 && BgLayerScaleHard == 0) || (i < 2 && BgBaseScaleSoft == 1)) ? softScale : hardScale;
				if (BgBaseTilt == 1)
					backgroundUV = ScaleUV( backgroundUV, scaleConst.x - (scaleModifier*scaleConst.y), bgPivot );
				backgroundUV = rotatePoint(bgPivot, rotation*TWO_PI, backgroundUV);
			}

			float bgAr = i < 2 && BgBaseAnim == 0 ? BgBaseAR : bgLayerAR;
			if (bgAr > 1)
				backgroundUV = ScaleUV(backgroundUV, vec2(1/bgAr, 1.), bgPivot);
			else
				backgroundUV = ScaleUV(backgroundUV, vec2(1., bgAr), bgPivot);

			vec2 animOffset;
			animOffset = vec2(0.);
			if (isAnim) {
				float frameFraction = 1. / frameCount;
				float currentFrame = floor(timing.y * frameCount);

				animOffset = vec2(currentFrame*frameFraction, 0.);
				backgroundUV *= vec2(frameFraction, 1.);
			}
			backgroundUV = BgBaseClampTiling == 0
				? mirrorTile(backgroundUV, .001, .999)
				: clamp(backgroundUV, .001, .999);

			
			if (isAnim)
				backgroundUV += animOffset;

			if (i == 0) {
				backgroundTexture = texture(BgBaseTex, backgroundUV);
				if (BgBaseClearVersion == 1) {
					vec4 backgroundClearTexture = texture(BgBaseClearTex, backgroundUV);
					backgroundTexture = mix(backgroundTexture,backgroundClearTexture,clearTransition);
				}
			} else if (i == 1) {
				backgroundTexture2 = texture(BgOverlayTex, backgroundUV);
				if (BgOverlayClearVersion == 1) {
					vec4 backgroundOverlayClearTexture = texture(BgOverlayClearTex, backgroundUV);
					backgroundTexture2 = mix(backgroundTexture2,backgroundOverlayClearTexture,clearTransition);
				}
				if (BgOverlayFlashEffect == 1) {
					backgroundTexture2.a *= .9 + timing.y * .1;
				}
			} else if (i == 2) {
				layerTexture = texture(BgLayerTex, backgroundUV);
				if (BgLayerClearVersion == 1) {
					vec4 layerClearTexture = texture(BgLayerClearTex, backgroundUV);
					layerTexture = mix(layerTexture, layerClearTexture, clearTransition);
				}
				layerTexture.rgb = blendOverlay(layerTexture.rgb, vec3(1.), BgLayerBrighten);
			}
		}
	}
	target.rgb = mix(target.rgb, backgroundTexture.rgb, backgroundTexture.a);
	if (BgLayer == 1)
		target.rgb = blendLinearDodge(target.rgb, layerTexture.rgb, layerTexture.a);
	// END BACKGROUND

	// TUNNEL -- gaat nog niet goed denkik
	if (Tunnel == 1) {
		vec2 pointFromCenter = center - point;
		pointFromCenter /= TunnelScale;
		float diff = GetDistanceShape(pointFromCenter,TunnelSides);
		float fog = -1. / (diff * TunnelFog * TunnelScale.x) + 1.;
		fog = clamp(fog, 0, 1);
		float tunnelTexY = TunnelStretch / diff;
		tunnelTexY += timing.y * TunnelSpeed;
		float rot = (atan(pointFromCenter.x,pointFromCenter.y) + TunnelBaseTexRotation + TunnelExtraRotation*TWO_PI) / TWO_PI;
		if (TunnelVortexEffect == 1)
			rot += fract(timing.z*0.1*TunnelVortexFactor);
		vec4 tunnelTexture = texture(TunnelTex, vec2(rot,mod(tunnelTexY,1)));
			if (TunnelClearVersion == 1) {
				vec4 clearTunnelTexture = texture(TunnelClearTex, vec2(rot,mod(tunnelTexY,1)));
				tunnelTexture = mix(tunnelTexture,clearTunnelTexture,clearTransition);
			}

		if (TunnelFlashEffect == 1) {
			float brightness = timing.y * 1.;
			tunnelTexture.rgb = blendOverlay(tunnelTexture.rgb, vec3(1.), brightness);
		}

		if (TunnelDodgeBlend == 1)
			target.rgb = blendLinearDodge(target.rgb, tunnelTexture.rgb*2, tunnelTexture.a*2*fog);
		else
			target.rgb = mix(target.rgb, tunnelTexture.rgb*2., tunnelTexture.a*fog);

		// target.rgb = backgroundTexture.rgb * (1-target.a) + target.rgb * target.a;
		// target.rgb = tunnelTexture.rgb * 2.0;
		// target.a = tunnelTexture.a * fog;
	}
	// END TUNNEL

	// CENTER TEXTURE
	if (Center == 1) {
		vec2 centerUV = screenUV;
		//centerUV = center - centerUV; // this would be 'centered uv calculation' (?)
		//centerUV *= -1.0;
		//centerUV += 0.5;
		centerUV.x -= 0.5;
		centerUV.y -= CenterOffsetY;
		if (CenterSnapToTrack == 1)
			centerUV.y += (0.5-center.y);
		else
			centerUV.y += portrait(0.19,0.25);

		if (CenterFloat == 1) {
			centerUV -= vec2(
				sin(timing.z * 0.6) * 0.003 * CenterFloatXFactor,
				cos(timing.z) * 0.007 * CenterFloatFactor
			);
		}
		centerUV.x *= ar;
		centerUV.x += 0.5;
		centerUV = clamp(centerUV,0.0,1.0);

		if (CenterTilt == 1)
			centerUV = rotatePoint(vec2(0.5, 0.5-CenterOffsetY), clamp(TunnelBaseRotation + (bgrot * TWO_PI),-360,360), centerUV);

		if (CenterFloat == 1 && CenterFloatRotationFactor > 0.) {
			centerUV = rotatePoint(vec2(0.5), (sin(timing.z*0.3))*0.05*TWO_PI * CenterFloatRotationFactor, centerUV);
		}

		centerUV = ScaleUV(centerUV,CenterScale,vec2(0.5));

		float GlowTimingProgress = sin(timing.z*6.5)*.5+.5;

		if (CenterGlow == 1)
			centerUV = ScaleUV(centerUV,GlowTimingProgress*.3+1.,vec2(0.5));

		if (CenterRotate == 1)
			centerUV = rotatePoint(vec2(0.5), fract(timing.z*0.02)*TWO_PI, centerUV);

		// TODO: center anim

		vec4 centerTexture = vec4(0.);
		if (CenterNormalVersion == 1) {
			centerTexture = texture(CenterTex, clamp(centerUV,0.,1.));
		}
		if (CenterClearVersion == 1) {
			vec4 centerTextureClear = texture(CenterClearTex, clamp(centerUV,0.,1.));
			centerTexture = mix(centerTexture,centerTextureClear,clearTransition);
		}

		float opacity = CenterFadeEffect == 1 ? (0.2+abs(cos(timing.z)*0.2)) : 1.;
		target.rgb = mix(target.rgb,centerTexture.rgb,centerTexture.a * opacity);

		if (BgOverlay == 1)
			target.rgb = mix(target.rgb,backgroundTexture2.rgb,backgroundTexture2.a);

		if (CenterLayerEffect == 1) {
			float a = CenterLayerEffectAlpha;
			float sc = CenterLayerEffectScale;
			if (CenterLayerEffectFade == 1)
				a *= (0.3+(cos(timing.z)*0.3));
			if (CenterLayerEffectGlow == 1) {
				a *= (GlowTimingProgress*.2+.4);
				sc *= (GlowTimingProgress*.05+.95);
			}

			vec2 centerLayerUV = ScaleUV(centerUV,sc,vec2(.5,.5));
			if (CenterLayerEffectRotate == 1)
				centerLayerUV = rotatePoint(vec2(0.5), fract(timing.z*0.01*CenterLayerEffectRotateSpeed)*TWO_PI, centerLayerUV);
			vec4 centerTexture2 = texture(CenterLayerEffectTex, clamp(centerLayerUV,0.,1.));

			if (CenterLayerEffectDodgeBlend == 1)
				target.rgb = blendLinearDodge(target.rgb, centerTexture2.rgb, centerTexture2.a*a);
			else
				target.rgb = mix(target.rgb,centerTexture2.rgb,centerTexture2.a * a);
		}
		// todo: have pulsing speed factor uniform
		if (CenterPulse == 1) { // also has to account for clear version
			vec4 centerTextureef = texture(CenterTex, clamp(ScaleUV(centerUV,1.-fract(timing.z*1.5)*0.15,vec2(0.5)),0.0,1.0));
			target.rgb = mix(target.rgb,centerTextureef.rgb + target.rgb,centerTextureef.a *(fract(-timing.z*1.5))*0.2);
		}
	}
	// END CENTER TEXTURE

	// If Center == 1 this will be drawn in the Center block
	if (Center == 0 && BgOverlay == 1)
		target.rgb = mix(target.rgb,backgroundTexture2.rgb,backgroundTexture2.a);

	//PARTICLES
	if (Particle == 1) {
		vec2 particlesUV = point;
		particlesUV.x = center.x - particlesUV.x;
		particlesUV.x = mirrored(clamp(particlesUV.x,-1.0,1.0));
		// particlesUV.y += 0.1;

		vec4 particles = vec4(vec3(1.),0.);
		float particlesTime = timing.z * ParticleSpeed;

		for (int i=0;i<ParticleAmount;++i) {
			float timeOffset = 1./i;
			float particleSpawnTime = floor(particlesTime - timeOffset);
			float particleTime = (particlesTime - timeOffset) - particleSpawnTime;

			float rnd = rand(vec2(i,particleSpawnTime));
			float rnd2 = rand(vec2(particleSpawnTime,i));

			float spriteIndex = floor(rnd*4.0);

			vec2 particleUV = ScaleUV(particlesUV,(1.0-particleTime)*8.0,vec2(0.0,center.y));
			particleUV += vec2(rnd2*-0.4,rnd*0.4 + 0.025 + portrait(ParticleOffsetY,0.2));
			particleUV /= ParticleScale;
			particleUV = clamp(particleUV,0.0,1.0);

			vec4 particle = texture(ParticleTex, particleUV * vec2(0.25,1.) + vec2(spriteIndex*0.25,0.0));
			particle.a *= min(particleTime*ParticleAmount,1.0);
			if (ParticleClearVersion == 1) {
				vec4 clearParticle = texture(ParticleClearTex, particleUV * vec2(0.25,1.) + vec2(spriteIndex,0.0));
				clearParticle.a *= min(particleTime*ParticleAmount,1.0);
				particle = mix(particle, clearParticle, clearTransition);
			}
			particles = mix(particles,particle,particle.a);
		}
		
		target.rgb = mix(target.rgb,particles.rgb,particles.a);
	}
	//END PARTICLES

	target.a = 1.0;
}

//Edited by Halo ID => edited by Shirijii