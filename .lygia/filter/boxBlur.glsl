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
description: |
    Given a texture it performs a moving average or box blur. 
    Which simply averages the pixel values in a KxK window. 
    This is a very common image processing technique that can be used to smooth out noise.
use: boxBlur(<SAMPLER_TYPE> texture, <vec2> st, <vec2> pixel_offset)
options:
    - BOXBLUR_2D: default to 1D
    - BOXBLUR_ITERATIONS: default 3
    - SAMPLER_FNC(TEX, UV): optional depending the target version of GLSL (texture2D(...) or texture(...))
examples:
    - /shaders/filter_boxBlur2D.frag
license:
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Prosperity License - https://prosperitylicense.com/versions/3.0.0
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Patron License - https://lygia.xyz/license
*/
#ifndef BOXBLUR_ITERATIONS
#define BOXBLUR_ITERATIONS 3
#endif
#ifndef BOXBLUR_TYPE
#define BOXBLUR_TYPE vec4
#endif
#ifndef BOXBLUR_SAMPLER_FNC
#define BOXBLUR_SAMPLER_FNC(TEX, UV) SAMPLER_FNC(TEX, UV)
#endif

/*
contributors: Patricio Gonzalez Vivo
description: Simple one dimensional box blur, to be applied in two passes
use: boxBlur1D(<SAMPLER_TYPE> texture, <vec2> st, <vec2> pixel_offset, <int> kernelSize)
options:
    - SAMPLER_FNC(TEX, UV): optional depending the target version of GLSL (texture2D(...) or texture(...))
    - BOXBLUR1D_TYPE: default is vec4
    - BOXBLUR1D_SAMPLER_FNC(TEX, UV): default texture2D(tex, TEX, UV)
    - BOXBLUR1D_KERNELSIZE: Use only for WebGL 1.0 and OpenGL ES 2.0 . For example RaspberryPis is not happy with dynamic loops. Default is 'kernelSize'
license:
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Prosperity License - https://prosperitylicense.com/versions/3.0.0
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Patron License - https://lygia.xyz/license
*/
#ifndef BOXBLUR1D_TYPE
#ifdef BOXBLUR_TYPE
#define BOXBLUR1D_TYPE BOXBLUR_TYPE
#else
#define BOXBLUR1D_TYPE vec4
#endif
#endif
#ifndef BOXBLUR1D_SAMPLER_FNC
#ifdef BOXBLUR_SAMPLER_FNC
#define BOXBLUR1D_SAMPLER_FNC(TEX, UV) BOXBLUR_SAMPLER_FNC(TEX, UV)
#else
#define BOXBLUR1D_SAMPLER_FNC(TEX, UV) SAMPLER_FNC(TEX, UV)
#endif
#endif
#ifndef FNC_BOXBLUR1D
#define FNC_BOXBLUR1D
BOXBLUR1D_TYPE boxBlur1D(in SAMPLER_TYPE tex, in vec2 st, in vec2 offset, const int kernelSize) {
    BOXBLUR1D_TYPE color = BOXBLUR1D_TYPE(0.);
    #ifndef BOXBLUR1D_KERNELSIZE
    #if defined(PLATFORM_WEBGL)
    #define BOXBLUR1D_KERNELSIZE 20
    float kernelSizef = float(kernelSize);
    #else
    #define BOXBLUR1D_KERNELSIZE kernelSize
    float kernelSizef = float(BOXBLUR1D_KERNELSIZE);
    #endif
    #else
    float kernelSizef = float(BOXBLUR1D_KERNELSIZE);
    #endif
    float weight = 1. / kernelSizef;
    for (int i = 0; i < BOXBLUR1D_KERNELSIZE; i++) {
        #if defined(PLATFORM_WEBGL)
        if (i >= kernelSize)
            break;
        #endif
        float x = -.5 * (kernelSizef - 1.) + float(i);
        color += BOXBLUR1D_SAMPLER_FNC(tex, st + offset * x ) * weight;
    }
    return color;
}
#endif


/*
contributors: Patricio Gonzalez Vivo
description: Simple two dimensional box blur, so can be apply in a single pass
use: boxBlur2D(<SAMPLER_TYPE> texture, <vec2> st, <vec2> pixel_offset, <int> kernelSize)
options:
    - SAMPLER_FNC(TEX, UV): optional depending the target version of GLSL (texture2D(...) or texture(...))
    - BOXBLUR2D_TYPE: Default `vec4`
    - BOXBLUR2D_SAMPLER_FNC(TEX, UV): default is `texture2D(tex, TEX, UV)`
    - BOXBLUR2D_KERNELSIZE: Use only for WebGL 1.0 and OpenGL ES 2.0 . For example RaspberryPis is not happy with dynamic loops. Default is 'kernelSize'
examples:
    - /shaders/filter_boxBlur2D.frag
license:
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Prosperity License - https://prosperitylicense.com/versions/3.0.0
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Patron License - https://lygia.xyz/license
*/
#ifndef BOXBLUR2D_TYPE
#ifdef BOXBLUR_TYPE
#define BOXBLUR2D_TYPE BOXBLUR_TYPE
#else
#define BOXBLUR2D_TYPE vec4
#endif
#endif
#ifndef BOXBLUR2D_SAMPLER_FNC
#ifdef BOXBLUR_SAMPLER_FNC
#define BOXBLUR2D_SAMPLER_FNC(TEX, UV) BOXBLUR_SAMPLER_FNC(TEX, UV)
#else
#define BOXBLUR2D_SAMPLER_FNC(TEX, UV) SAMPLER_FNC(TEX, UV)
#endif
#endif
#ifndef FNC_BOXBLUR2D
#define FNC_BOXBLUR2D
BOXBLUR2D_TYPE boxBlur2D(in SAMPLER_TYPE tex, in vec2 st, in vec2 pixel, const int kernelSize) {
    BOXBLUR2D_TYPE color = BOXBLUR2D_TYPE(0.);
    #ifndef BOXBLUR2D_KERNELSIZE
    #if defined(PLATFORM_WEBGL)
    #define BOXBLUR2D_KERNELSIZE 20
    float kernelSizef = float(kernelSize);
    #else
    #define BOXBLUR2D_KERNELSIZE kernelSize
    float kernelSizef = float(BOXBLUR2D_KERNELSIZE);
    #endif
    #else
    float kernelSizef = float(BOXBLUR2D_KERNELSIZE);
    #endif
    float accumWeight = 0.;
    float kernelSize2 = kernelSizef * kernelSizef;
    float weight = 1. / kernelSize2;
    for (int j = 0; j < BOXBLUR2D_KERNELSIZE; j++) {
        #if defined(PLATFORM_WEBGL)
        if (j >= kernelSize)
            break;
        #endif
        float y = -.5 * (kernelSizef - 1.) + float(j);
        for (int i = 0; i < BOXBLUR2D_KERNELSIZE; i++) {
            #if defined(PLATFORM_WEBGL)
            if (i >= kernelSize)
                break;
            #endif
            float x = -.5 * (kernelSizef - 1.) + float(i);
            color += BOXBLUR2D_SAMPLER_FNC(tex, st + vec2(x, y) * pixel) * weight;
        }
    }
    return color;
}
#endif


/*
contributors: Patricio Gonzalez Vivo
description: Simple two dimensional box blur, so can be apply in a single pass
use: boxBlur1D_fast9(<SAMPLER_TYPE> texture, <vec2> st, <vec2> pixel_direction)
options:
    - SAMPLER_FNC(TEX, UV): optional depending the target version of GLSL (texture2D(...) or texture(...))
    - BOXBLUR2D_FAST9_TYPE: Default is `vec4`
    - BOXBLUR2D_FAST9_SAMPLER_FNC(TEX, UV): Default is `texture2D(tex, TEX, UV)`
examples:
    - /shaders/filter_boxBlur2D.frag
license:
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Prosperity License - https://prosperitylicense.com/versions/3.0.0
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Patron License - https://lygia.xyz/license
*/
#ifndef BOXBLUR2D_FAST9_TYPE
#ifdef BOXBLUR_TYPE
#define BOXBLUR2D_FAST9_TYPE BOXBLUR_TYPE
#else
#define BOXBLUR2D_FAST9_TYPE vec4
#endif
#endif
#ifndef BOXBLUR2D_FAST9_SAMPLER_FNC
#ifdef BOXBLUR_SAMPLER_FNC
#define BOXBLUR2D_FAST9_SAMPLER_FNC(TEX, UV) BOXBLUR_SAMPLER_FNC(TEX, UV)
#else
#define BOXBLUR2D_FAST9_SAMPLER_FNC(TEX, UV) SAMPLER_FNC(TEX, UV)
#endif
#endif
#ifndef FNC_BOXBLUR2D_FAST9
#define FNC_BOXBLUR2D_FAST9
BOXBLUR2D_FAST9_TYPE boxBlur2D_fast9(in SAMPLER_TYPE tex, in vec2 st, in vec2 offset) {
    BOXBLUR2D_FAST9_TYPE color = BOXBLUR2D_FAST9_SAMPLER_FNC(tex, st);          // center
    color += BOXBLUR2D_FAST9_SAMPLER_FNC(tex, st + vec2(-offset.x, offset.y));  // tleft
    color += BOXBLUR2D_FAST9_SAMPLER_FNC(tex, st + vec2(-offset.x, 0.));        // left
    color += BOXBLUR2D_FAST9_SAMPLER_FNC(tex, st + vec2(-offset.x, -offset.y)); // bleft
    color += BOXBLUR2D_FAST9_SAMPLER_FNC(tex, st + vec2(0., offset.y));         // top
    color += BOXBLUR2D_FAST9_SAMPLER_FNC(tex, st + vec2(0., -offset.y));        // bottom
    color += BOXBLUR2D_FAST9_SAMPLER_FNC(tex, st + offset);                     // tright
    color += BOXBLUR2D_FAST9_SAMPLER_FNC(tex, st + vec2(offset.x, 0.));         // right
    color += BOXBLUR2D_FAST9_SAMPLER_FNC(tex, st + vec2(offset.x, -offset.y));  // bright
    return color * 0.1111111111; // 1./9.
}
#endif

#ifndef FNC_BOXBLUR
#define FNC_BOXBLUR
BOXBLUR_TYPE boxBlur13(in SAMPLER_TYPE tex, in vec2 st, in vec2 offset) {
#ifdef BOXBLUR_2D
  return boxBlur2D(tex, st, offset, 7);
#else
  return boxBlur1D(tex, st, offset, 7);
#endif
}
BOXBLUR_TYPE boxBlur9(in SAMPLER_TYPE tex, in vec2 st, in vec2 offset) {
#ifdef BOXBLUR_2D
  return boxBlur2D_fast9(tex, st, offset);
#else
  return boxBlur1D(tex, st, offset, 5);
#endif
}
BOXBLUR_TYPE boxBlur5(in SAMPLER_TYPE tex, in vec2 st, in vec2 offset) {
#ifdef BOXBLUR_2D
  return boxBlur2D(tex, st, offset, 3);
#else
  return boxBlur1D(tex, st, offset, 3);
#endif
}
BOXBLUR_TYPE boxBlur(in SAMPLER_TYPE tex, in vec2 st, vec2 offset, const int kernelSize) {
#ifdef BOXBLUR_2D
  return boxBlur2D(tex, st, offset, kernelSize);
#else
  return boxBlur1D(tex, st, offset, kernelSize);
#endif
}
BOXBLUR_TYPE boxBlur(in SAMPLER_TYPE tex, in vec2 st, vec2 offset) {
  #ifdef BOXBLUR_2D
    return boxBlur2D(tex, st, offset, BOXBLUR_ITERATIONS);
  #else
    return boxBlur1D(tex, st, offset, BOXBLUR_ITERATIONS);
  #endif
}
#endif
