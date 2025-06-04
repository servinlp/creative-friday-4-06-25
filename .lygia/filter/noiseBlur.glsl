/*
contributors: Patricio Gonzalez Vivo
description: some useful math constants
license:
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Prosperity License - https://prosperitylicense.com/versions/3.0.0
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Patron License - https://lygia.xyz/license
*/
#ifndef EIGHTH_PI
#define EIGHTH_PI 0.39269908169
#endif
#ifndef QTR_PI
#define QTR_PI 0.78539816339
#endif
#ifndef HALF_PI
#define HALF_PI 1.5707963267948966192313216916398
#endif
#ifndef PI
#define PI 3.1415926535897932384626433832795
#endif
#ifndef TWO_PI
#define TWO_PI 6.2831853071795864769252867665590
#endif
#ifndef TAU
#define TAU 6.2831853071795864769252867665590
#endif
#ifndef INV_PI
#define INV_PI 0.31830988618379067153776752674503
#endif
#ifndef INV_SQRT_TAU
#define INV_SQRT_TAU 0.39894228040143267793994605993439  // 1.0/SQRT_TAU
#endif
#ifndef SQRT_HALF_PI
#define SQRT_HALF_PI 1.25331413732
#endif
#ifndef PHI
#define PHI 1.618033988749894848204586834
#endif
#ifndef EPSILON
#define EPSILON 0.0000001
#endif
#ifndef GOLDEN_RATIO
#define GOLDEN_RATIO 1.6180339887
#endif
#ifndef GOLDEN_RATIO_CONJUGATE 
#define GOLDEN_RATIO_CONJUGATE 0.61803398875
#endif
#ifndef GOLDEN_ANGLE // (3.-sqrt(5.0))*PI radians
#define GOLDEN_ANGLE 2.39996323
#endif
#ifndef DEG2RAD
#define DEG2RAD (PI / 180.0)
#endif
#ifndef RAD2DEG
#define RAD2DEG (180.0 / PI)
#endif

/*
contributors: Patricio Gonzalez Vivo
description: It defines the default sampler type and function for the shader based on the version of GLSL.
license:
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Prosperity License - https://prosperitylicense.com/versions/3.0.0
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Patron License - https://lygia.xyz/license
*/
#ifndef SAMPLER_FNC
#if __VERSION__ >= 300
#define SAMPLER_FNC(TEX, UV) texture(TEX, UV)
#else
#define SAMPLER_FNC(TEX, UV) texture2D(TEX, UV)
#endif
#endif
#ifndef SAMPLER_TYPE
#define SAMPLER_TYPE sampler2D
#endif
/*
contributors: Patricio Gonzalez Vivo
description: sampling function to make a texture behave like GL_NEAREST
use: nearest(vec2 st, <vec2> res)
license:
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Prosperity License - https://prosperitylicense.com/versions/3.0.0
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Patron License - https://lygia.xyz/license
*/
#ifndef NEAREST_FLOOR_FNC
#define NEAREST_FLOOR_FNC(UV) floor(UV)
#endif
#ifndef FNC_NEAREST
#define FNC_NEAREST
vec2 nearest(in vec2 v, in vec2 res) {
    vec2 offset = 0.5 / (res - 1.0);
    return NEAREST_FLOOR_FNC(v * res) / res + offset;
}
#endif

/*
contributors: Patricio Gonzalez Vivo
description: fakes a nearest sample
use: <vec4> sampleNearest(<SAMPLER_TYPE> tex, <vec2> st, <vec2> texResolution);
options:
    - SAMPLER_FNC(TEX, UV)
examples:
    - /shaders/sample_filter_nearest.frag
license:
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Prosperity License - https://prosperitylicense.com/versions/3.0.0
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Patron License - https://lygia.xyz/license
*/
#ifndef FNC_SAMPLENEAREST
#define FNC_SAMPLENEAREST
vec4 sampleNearest(SAMPLER_TYPE tex, vec2 st, vec2 texResolution) {
    return SAMPLER_FNC( tex, nearest(st, texResolution) );
}
#endif
/*
contributors: ["Patricio Gonzalez Vivo", "David Hoskins", "Inigo Quilez"]
description: Pass a value and get some random normalize value between 0 and 1
use: float random[2|3](<float|vec2|vec3> value)
options:
    - RANDOM_HIGHER_RANGE: for working with a range over 0 and 1
    - RANDOM_SINLESS: Use sin-less random, which tolerates bigger values before producing pattern. From https://www.shadertoy.com/view/4djSRW
    - RANDOM_SCALE: by default this scale if for number with a big range. For producing good random between 0 and 1 use bigger range
examples:
    - /shaders/generative_random.frag
license:
    - MIT License (MIT) Copyright 2014, David Hoskins
*/
#ifndef RANDOM_SCALE
#ifdef RANDOM_HIGHER_RANGE
#define RANDOM_SCALE vec4(.1031, .1030, .0973, .1099)
#else
#define RANDOM_SCALE vec4(443.897, 441.423, .0973, .1099)
#endif
#endif
#ifndef FNC_RANDOM
#define FNC_RANDOM
float random(in float x) {
#ifdef RANDOM_SINLESS
    x = fract(x * RANDOM_SCALE.x);
    x *= x + 33.33;
    x *= x + x;
    return fract(x);
#else
    return fract(sin(x) * 43758.5453);
#endif
}
float random(in vec2 st) {
#ifdef RANDOM_SINLESS
    vec3 p3  = fract(vec3(st.xyx) * RANDOM_SCALE.xyz);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
#else
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453);
#endif
}
float random(in vec3 pos) {
#ifdef RANDOM_SINLESS
    pos  = fract(pos * RANDOM_SCALE.xyz);
    pos += dot(pos, pos.zyx + 31.32);
    return fract((pos.x + pos.y) * pos.z);
#else
    return fract(sin(dot(pos.xyz, vec3(70.9898, 78.233, 32.4355))) * 43758.5453123);
#endif
}
float random(in vec4 pos) {
#ifdef RANDOM_SINLESS
    pos = fract(pos * RANDOM_SCALE);
    pos += dot(pos, pos.wzxy + 33.33);
    return fract((pos.x + pos.y) * (pos.z + pos.w));
#else
    float dot_product = dot(pos, vec4(12.9898,78.233,45.164,94.673));
    return fract(sin(dot_product) * 43758.5453);
#endif
}
vec2 random2(float p) {
    vec3 p3 = fract(vec3(p) * RANDOM_SCALE.xyz);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.xx + p3.yz) * p3.zy);
}
vec2 random2(vec2 p) {
    vec3 p3 = fract(p.xyx * RANDOM_SCALE.xyz);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.xx + p3.yz) * p3.zy);
}
vec2 random2(vec3 p3) {
    p3 = fract(p3 * RANDOM_SCALE.xyz);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.xx + p3.yz) * p3.zy);
}
vec3 random3(float p) {
    vec3 p3 = fract(vec3(p) * RANDOM_SCALE.xyz);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.xxy + p3.yzz) * p3.zyx); 
}
vec3 random3(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * RANDOM_SCALE.xyz);
    p3 += dot(p3, p3.yxz + 19.19);
    return fract((p3.xxy + p3.yzz) * p3.zyx);
}
vec3 random3(vec3 p) {
    p = fract(p * RANDOM_SCALE.xyz);
    p += dot(p, p.yxz + 19.19);
    return fract((p.xxy + p.yzz) * p.zyx);
}
vec4 random4(float p) {
    vec4 p4 = fract(p * RANDOM_SCALE);
    p4 += dot(p4, p4.wzxy + 19.19);
    return fract((p4.xxyz + p4.yzzw) * p4.zywx);   
}
vec4 random4(vec2 p) {
    vec4 p4 = fract(p.xyxy * RANDOM_SCALE);
    p4 += dot(p4, p4.wzxy + 19.19);
    return fract((p4.xxyz + p4.yzzw) * p4.zywx);
}
vec4 random4(vec3 p) {
    vec4 p4 = fract(p.xyzx * RANDOM_SCALE);
    p4 += dot(p4, p4.wzxy + 19.19);
    return fract((p4.xxyz + p4.yzzw) * p4.zywx);
}
vec4 random4(vec4 p4) {
    p4 = fract(p4  * RANDOM_SCALE);
    p4 += dot(p4, p4.wzxy + 19.19);
    return fract((p4.xxyz + p4.yzzw) * p4.zywx);
}
#endif
/*
contributors:
    - Alan Wolfe
    - Patricio Gonzalez Vivo
description: Generic blur using a noise function inspired on https://www.shadertoy.com/view/XsVBDR
use: noiseBlur(<SAMPLER_TYPE> texture, <vec2> st, <vec2> pixel, <float> radius)
options:
    - NOISEBLUR_TYPE: default to vec3
    - NOISEBLUR_GAUSSIAN_K: no gaussian by default
    - NOISEBLUR_RANDOM23_FNC(UV): defaults to random2(UV)
    - NOISEBLUR_SAMPLER_FNC(UV): defaults to texture2D(tex, UV).rgb
    - NOISEBLUR_SAMPLES: default to 4
    - SAMPLER_FNC(TEX, UV): optional depending the target version of GLSL (texture2D(...) or texture(...))
examples:
    - /shaders/filter_noiseBlur2D.frag
license:
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Prosperity License - https://prosperitylicense.com/versions/3.0.0
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Patron License - https://lygia.xyz/license
*/
#ifndef NOISEBLUR_SAMPLES
#define NOISEBLUR_SAMPLES 4.0
#endif
#ifndef NOISEBLUR_TYPE
#define NOISEBLUR_TYPE vec4
#endif
#ifndef NOISEBLUR_SAMPLER_FNC
#define NOISEBLUR_SAMPLER_FNC(TEX, UV) SAMPLER_FNC(TEX, UV)
#endif
#ifndef NOISEBLUR_RANDOM23_FNC
#define NOISEBLUR_RANDOM23_FNC(UV) random2(UV)
#endif
#ifndef FNC_NOISEBLUR
#define FNC_NOISEBLUR
NOISEBLUR_TYPE noiseBlur(in SAMPLER_TYPE tex, in vec2 st, in vec2 pixel, float radius) {
    float blurRadius = radius;
    vec2 noiseOffset = st;
    #ifdef NOISEBLUR_SECS
    noiseOffset += 1337.0*fract(NOISEBLUR_SECS * 0.1);
    #endif
    NOISEBLUR_TYPE result = NOISEBLUR_TYPE(0.0);
    for (float i = 0.0; i < NOISEBLUR_SAMPLES; ++i) {
        #if defined(BLUENOISE_TEXTURE) && defined(BLUENOISE_TEXTURE_RESOLUTION)
        vec2 noiseRand = sampleNearest(BLUENOISE_TEXTURE, noiseOffset.xy, BLUENOISE_TEXTURE_RESOLUTION).xy;
        #else 
        vec2 noiseRand = NOISEBLUR_RANDOM23_FNC(vec3(noiseOffset.xy, i));
        #endif
        noiseOffset = noiseRand;
        vec2 r = noiseRand;
        r.x *= TAU;
        #if defined(NOISEBLUR_GAUSSIAN_K)
        // box-muller transform to get gaussian distributed sample points in the circle
        vec2 cr = vec2(sin(r.x),cos(r.x))*sqrt(-NOISEBLUR_GAUSSIAN_K * log(r.y));
        #else
        // uniform sample the circle
        vec2 cr = vec2(sin(r.x),cos(r.x))*sqrt(r.y);
        #endif
        NOISEBLUR_TYPE color = NOISEBLUR_SAMPLER_FNC(tex, st + cr * blurRadius * pixel );
        // average the samples as we get em
        // https://blog.demofox.org/2016/08/23/incremental-averaging/
        result = mix(result, color, 1.0 / (i+1.0));
    }
    return result;
}
NOISEBLUR_TYPE noiseBlur(SAMPLER_TYPE tex, vec2 st, vec2 pixel) {
    NOISEBLUR_TYPE rta = NOISEBLUR_TYPE(0.0);
    float total = 0.0;
    float offset = random(vec3(12.9898 + st.x, 78.233 + st.y, 151.7182));
    for (float t = -NOISEBLUR_SAMPLES; t <= NOISEBLUR_SAMPLES; t++) {
        float percent = (t / NOISEBLUR_SAMPLES) + offset - 0.5;
        float weight = 1.0 - abs(percent);
        NOISEBLUR_TYPE color = NOISEBLUR_SAMPLER_FNC(tex, st + pixel * percent);
        rta += color * weight;
        total += weight;
    }
    return rta / total;
}
#endif