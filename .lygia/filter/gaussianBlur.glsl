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
contributors:
    - Matt DesLauriers
    - Patricio Gonzalez Vivo
description: Adapted versions from 5, 9 and 13 gaussian fast blur from https://github.com/Jam3/glsl-fast-gaussian-blur
use: gaussianBlur(<SAMPLER_TYPE> texture, <vec2> st, <vec2> pixel_direction [, const int kernelSize])
options:
    - GAUSSIANBLUR_AMOUNT: gaussianBlur5 gaussianBlur9 gaussianBlur13
    - GAUSSIANBLUR_2D: default to 1D
    - SAMPLER_FNC(TEX, UV): optional depending the target version of GLSL (texture2D(...) or texture(...))
examples:
    - /shaders/filter_gaussianBlur2D.frag
license:
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Prosperity License - https://prosperitylicense.com/versions/3.0.0
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Patron License - https://lygia.xyz/license
*/
#ifndef GAUSSIANBLUR_AMOUNT
#define GAUSSIANBLUR_AMOUNT gaussianBlur13
#endif
#ifndef GAUSSIANBLUR_TYPE
#define GAUSSIANBLUR_TYPE vec4
#endif
#ifndef GAUSSIANBLUR_SAMPLER_FNC
#define GAUSSIANBLUR_SAMPLER_FNC(TEX, UV) SAMPLER_FNC(TEX, UV)
#endif
/*
contributors: Patricio Gonzalez Vivo
description: gaussian coefficient
use: <vec4|vec3|vec2|float> gaussian(<float> sigma, <vec4|vec3|vec2|float> d)
examples:
    - https://raw.githubusercontent.com/patriciogonzalezvivo/lygia_examples/main/math_gaussian.frag
license:
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Prosperity License - https://prosperitylicense.com/versions/3.0.0
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Patron License - https://lygia.xyz/license
*/
#ifndef FNC_GAUSSIAN
#define FNC_GAUSSIAN
float gaussian(float d, float s) { return exp(-(d*d) / (2.0 * s*s)); }
float gaussian( vec2 d, float s) { return exp(-( d.x*d.x + d.y*d.y) / (2.0 * s*s)); }
float gaussian( vec3 d, float s) { return exp(-( d.x*d.x + d.y*d.y + d.z*d.z ) / (2.0 * s*s)); }
float gaussian( vec4 d, float s) { return exp(-( d.x*d.x + d.y*d.y + d.z*d.z + d.w*d.w ) / (2.0 * s*s)); }
#endif

/*
contributors: Patricio Gonzalez Vivo
description: fakes a clamp to edge texture
use: <vec4> sampleClamp2edge(<SAMPLER_TYPE> tex, <vec2> st [, <vec2> texResolution]);
options:
    - SAMPLER_FNC(TEX, UV)
license:
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Prosperity License - https://prosperitylicense.com/versions/3.0.0
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Patron License - https://lygia.xyz/license
*/
#ifndef FNC_SAMPLECLAMP2EDGE
#define FNC_SAMPLECLAMP2EDGE
vec4 sampleClamp2edge(SAMPLER_TYPE tex, vec2 st, vec2 texResolution) {
    vec2 pixel = 1.0/texResolution;
    return SAMPLER_FNC( tex, clamp(st, pixel, 1.0-pixel) );
}
vec4 sampleClamp2edge(SAMPLER_TYPE tex, vec2 st) { 
    return SAMPLER_FNC( tex, clamp(st, vec2(0.01), vec2(0.99) ) ); 
}
vec4 sampleClamp2edge(SAMPLER_TYPE tex, vec2 st, float edge) { 
    return SAMPLER_FNC( tex, clamp(st, vec2(edge), vec2(1.0 - edge) ) ); 
}
#endif
/*
contributors: Patricio Gonzalez Vivo
description: Two dimension Gaussian Blur to be applied in only one passes
use: gaussianBlur2D(<SAMPLER_TYPE> texture, <vec2> st, <vec2> pixel_direction, const int kernelSize)
options:
    - SAMPLER_FNC(TEX, UV): optional depending the target version of GLSL (texture2D(...) or texture(...))
    - GAUSSIANBLUR2D_TYPE: Default `vec4`
    - GAUSSIANBLUR2D_SAMPLER_FNC(TEX, UV): Default `texture2D(tex, TEX, UV)`
    - GAUSSIANBLUR2D_KERNELSIZE: Use only for WebGL 1.0 and OpenGL ES 2.0 . For example  RaspberryPis is not happy with dynamic loops. Default is 'kernelSize'
examples:
    - /shaders/filter_gaussianBlur2D.frag
license:
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Prosperity License - https://prosperitylicense.com/versions/3.0.0
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Patron License - https://lygia.xyz/license
*/
#ifndef GAUSSIANBLUR2D_TYPE
#ifdef GAUSSIANBLUR_TYPE
#define GAUSSIANBLUR2D_TYPE GAUSSIANBLUR_TYPE
#else
#define GAUSSIANBLUR2D_TYPE vec4
#endif
#endif
#ifndef GAUSSIANBLUR2D_SAMPLER_FNC
#ifdef GAUSSIANBLUR_SAMPLER_FNC
#define GAUSSIANBLUR2D_SAMPLER_FNC(TEX, UV) GAUSSIANBLUR_SAMPLER_FNC(TEX, UV)
#else
#define GAUSSIANBLUR2D_SAMPLER_FNC(TEX, UV) sampleClamp2edge(TEX, UV)
#endif
#endif
#ifndef FNC_GAUSSIANBLUR2D
#define FNC_GAUSSIANBLUR2D
GAUSSIANBLUR2D_TYPE gaussianBlur2D(in SAMPLER_TYPE tex, in vec2 st, in vec2 offset, const int kernelSize) {
    GAUSSIANBLUR2D_TYPE accumColor = GAUSSIANBLUR2D_TYPE(0.);
    #ifndef GAUSSIANBLUR2D_KERNELSIZE
        #if defined(PLATFORM_WEBGL)
            #define GAUSSIANBLUR2D_KERNELSIZE 20
            float kernelSizef = float(kernelSize);
        #else
            #define GAUSSIANBLUR2D_KERNELSIZE kernelSize
            float kernelSizef = float(GAUSSIANBLUR2D_KERNELSIZE);
        #endif
    #else
        float kernelSizef = float(GAUSSIANBLUR2D_KERNELSIZE);
    #endif
    float accumWeight = 0.;
    const float k = 0.15915494; // 1 / (2*PI)
    vec2 xy = vec2(0.0);
    for (int j = 0; j < GAUSSIANBLUR2D_KERNELSIZE; j++) {
        #if defined(PLATFORM_WEBGL)
        if (j >= kernelSize)
            break;
        #endif
        xy.y = -.5 * (kernelSizef - 1.) + float(j);
        for (int i = 0; i < GAUSSIANBLUR2D_KERNELSIZE; i++) {
            #if defined(PLATFORM_WEBGL)
            if (i >= kernelSize)
                break;
            #endif
            xy.x = -0.5 * (kernelSizef - 1.) + float(i);
            float weight = (k / kernelSizef) * gaussian(xy, kernelSizef);
            accumColor += weight * GAUSSIANBLUR2D_SAMPLER_FNC(tex, st + xy * offset);
            accumWeight += weight;
        }
    }
    return accumColor / accumWeight;
}
#endif



/*
contributors: Patricio Gonzalez Vivo
description: One dimension Gaussian Blur to be applied in two passes
use: gaussianBlur1D(<SAMPLER_TYPE> texture, <vec2> st, <vec2> pixel_direction , const int kernelSize)
options:
    - SAMPLER_FNC(TEX, UV): optional depending the target version of GLSL (texture2D(...) or texture(...))
    - GAUSSIANBLUR1D_TYPE: null
    - GAUSSIANBLUR1D_SAMPLER_FNC(TEX, UV): null
license:
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Prosperity License - https://prosperitylicense.com/versions/3.0.0
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Patron License - https://lygia.xyz/license
*/
#ifndef GAUSSIANBLUR1D_TYPE
#ifdef GAUSSIANBLUR_TYPE
#define GAUSSIANBLUR1D_TYPE GAUSSIANBLUR_TYPE
#else
#define GAUSSIANBLUR1D_TYPE vec4
#endif
#endif
#ifndef GAUSSIANBLUR1D_SAMPLER_FNC
#ifdef GAUSSIANBLUR_SAMPLER_FNC
#define GAUSSIANBLUR1D_SAMPLER_FNC(TEX, UV) GAUSSIANBLUR_SAMPLER_FNC(TEX, UV)
#else
#define GAUSSIANBLUR1D_SAMPLER_FNC(TEX, UV) sampleClamp2edge(TEX, UV)
#endif
#endif
#ifndef FNC_GAUSSIANBLUR1D
#define FNC_GAUSSIANBLUR1D
#ifdef PLATFORM_WEBGL
GAUSSIANBLUR1D_TYPE gaussianBlur1D(in SAMPLER_TYPE tex,in vec2 st,in vec2 offset,const int kernelSize){
    GAUSSIANBLUR1D_TYPE accumColor = GAUSSIANBLUR1D_TYPE(0.0);
    float kernelSizef = float(kernelSize);
    float accumWeight = 0.0;
    const float k = 0.39894228;// 1 / sqrt(2*PI)
    for (int i = 0; i < 16; i++) {
        if( i >= kernelSize)
            break;
        float x = -0.5 * (float(kernelSize) - 1.0)+float(i);
        float weight = (k/float(kernelSize)) * gaussian(x, kernelSizef);
        GAUSSIANBLUR1D_TYPE tex = GAUSSIANBLUR1D_SAMPLER_FNC(tex, st + x * offset);
        accumColor += weight * tex;
        accumWeight += weight;
    }
    return accumColor/accumWeight;
}
#else
GAUSSIANBLUR1D_TYPE gaussianBlur1D(in SAMPLER_TYPE tex,in vec2 st,in vec2 offset,const int kernelSize){
    GAUSSIANBLUR1D_TYPE accumColor=GAUSSIANBLUR1D_TYPE(0.);
    float kernelSizef = float(kernelSize);
    float accumWeight = 0.0;
    const float k = 0.39894228;// 1 / sqrt(2*PI)
    for (int i = 0; i < kernelSize; i++) {
        float x = -0.5 * ( kernelSizef -1.0) + float(i);
        float weight = (k / kernelSizef) * gaussian(x, kernelSizef);
        GAUSSIANBLUR1D_TYPE tex = GAUSSIANBLUR1D_SAMPLER_FNC(tex, st + x * offset);
        accumColor += weight * tex;
        accumWeight += weight;
    }
    return accumColor/accumWeight;
}
#endif
#endif


/*
function: gaussianBlur1D_fast13
contributors: Matt DesLauriers
description: Adapted versions of gaussian fast blur 13 from https://github.com/Jam3/glsl-fast-gaussian-blur
use: gaussianBlur1D_fast13(<SAMPLER_TYPE> texture, <vec2> st, <vec2> pixel_direction)
options:
    - SAMPLER_FNC(TEX, UV): optional depending the target version of GLSL (texture2D(...) or texture(...))
    - GAUSSIANBLUR1D_FAST13_TYPE
    - GAUSSIANBLUR1D_FAST13_SAMPLER_FNC(TEX, UV)
*/
#ifndef GAUSSIANBLUR1D_FAST13_TYPE
#ifdef GAUSSIANBLUR_TYPE
#define GAUSSIANBLUR1D_FAST13_TYPE GAUSSIANBLUR_TYPE
#else
#define GAUSSIANBLUR1D_FAST13_TYPE vec4
#endif
#endif
#ifndef GAUSSIANBLUR1D_FAST13_SAMPLER_FNC
#ifdef GAUSSIANBLUR_SAMPLER_FNC
#define GAUSSIANBLUR1D_FAST13_SAMPLER_FNC(TEX, UV) GAUSSIANBLUR_SAMPLER_FNC(TEX, UV)
#else
#define GAUSSIANBLUR1D_FAST13_SAMPLER_FNC(TEX, UV) sampleClamp2edge(TEX, UV)
#endif
#endif
#ifndef FNC_GAUSSIANBLUR1D_FAST13
#define FNC_GAUSSIANBLUR1D_FAST13
GAUSSIANBLUR1D_FAST13_TYPE gaussianBlur1D_fast13(in SAMPLER_TYPE tex, in vec2 st, in vec2 offset) {
    GAUSSIANBLUR1D_FAST13_TYPE color = GAUSSIANBLUR1D_FAST13_TYPE(0.);
    vec2 off1 = vec2(1.411764705882353) * offset;
    vec2 off2 = vec2(3.2941176470588234) * offset;
    vec2 off3 = vec2(5.176470588235294) * offset;
    color += GAUSSIANBLUR1D_FAST13_SAMPLER_FNC(tex, st) * .1964825501511404;
    color += GAUSSIANBLUR1D_FAST13_SAMPLER_FNC(tex, st + (off1)) * .2969069646728344;
    color += GAUSSIANBLUR1D_FAST13_SAMPLER_FNC(tex, st - (off1)) * .2969069646728344;
    color += GAUSSIANBLUR1D_FAST13_SAMPLER_FNC(tex, st + (off2)) * .09447039785044732;
    color += GAUSSIANBLUR1D_FAST13_SAMPLER_FNC(tex, st - (off2)) * .09447039785044732;
    color += GAUSSIANBLUR1D_FAST13_SAMPLER_FNC(tex, st + (off3)) * .010381362401148057;
    color += GAUSSIANBLUR1D_FAST13_SAMPLER_FNC(tex, st - (off3)) * .010381362401148057;
    return color;
}
#endif


/*
contributors: Matt DesLauriers
description: Adapted versions of gaussian fast blur 13 from https://github.com/Jam3/glsl-fast-gaussian-blur
use: gaussianBlur1D_fast9(<SAMPLER_TYPE> texture, <vec2> st, <vec2> pixel_direction)
options:
    - SAMPLER_FNC(TEX, UV): optional depending the target version of GLSL (texture2D(...) or texture(...))
    - GAUSSIANBLUR1D_FAST9_TYPE
    - GAUSSIANBLUR1D_FAST9_SAMPLER_FNC(TEX, UV)
*/
#ifndef GAUSSIANBLUR1D_FAST9_TYPE
#ifdef GAUSSIANBLUR_TYPE
#define GAUSSIANBLUR1D_FAST9_TYPE GAUSSIANBLUR_TYPE
#else
#define GAUSSIANBLUR1D_FAST9_TYPE vec4
#endif
#endif
#ifndef GAUSSIANBLUR1D_FAST9_SAMPLER_FNC
#ifdef GAUSSIANBLUR_SAMPLER_FNC
#define GAUSSIANBLUR1D_FAST9_SAMPLER_FNC(TEX, UV) GAUSSIANBLUR_SAMPLER_FNC(TEX, UV)
#else
#define GAUSSIANBLUR1D_FAST9_SAMPLER_FNC(TEX, UV) sampleClamp2edge(TEX, UV)
#endif
#endif
#ifndef FNC_GAUSSIANBLUR1D_FAST9
#define FNC_GAUSSIANBLUR1D_FAST9
GAUSSIANBLUR1D_FAST9_TYPE gaussianBlur1D_fast9(in SAMPLER_TYPE tex, in vec2 st, in vec2 offset) {
    GAUSSIANBLUR1D_FAST9_TYPE color = GAUSSIANBLUR1D_FAST9_TYPE(0.);
    vec2 off1 = vec2(1.3846153846) * offset;
    vec2 off2 = vec2(3.2307692308) * offset;
    color += GAUSSIANBLUR1D_FAST9_SAMPLER_FNC(tex, st) * .2270270270;
    color += GAUSSIANBLUR1D_FAST9_SAMPLER_FNC(tex, st + (off1)) * .3162162162;
    color += GAUSSIANBLUR1D_FAST9_SAMPLER_FNC(tex, st - (off1)) * .3162162162;
    color += GAUSSIANBLUR1D_FAST9_SAMPLER_FNC(tex, st + (off2)) * .0702702703;
    color += GAUSSIANBLUR1D_FAST9_SAMPLER_FNC(tex, st - (off2)) * .0702702703;
    return color;
}
#endif


/*
contributors: Matt DesLauriers
description: Adapted versions of gaussian fast blur 13 from https://github.com/Jam3/glsl-fast-gaussian-blur
use: gaussianBlur1D_fast5(<SAMPLER_TYPE> texture, <vec2> st, <vec2> pixel_direction)
options:
    - SAMPLER_FNC(TEX, UV): optional depending the target version of GLSL (texture2D(...) or texture(...))
    - GAUSSIANBLUR1D_FAST5_TYPE
    - GAUSSIANBLUR1D_FAST5_SAMPLER_FNC(TEX, UV)
*/
#ifndef GAUSSIANBLUR1D_FAST5_TYPE
#ifdef GAUSSIANBLUR_TYPE
#define GAUSSIANBLUR1D_FAST5_TYPE GAUSSIANBLUR_TYPE
#else
#define GAUSSIANBLUR1D_FAST5_TYPE vec4
#endif
#endif
#ifndef GAUSSIANBLUR1D_FAST5_SAMPLER_FNC
#ifdef GAUSSIANBLUR_SAMPLER_FNC
#define GAUSSIANBLUR1D_FAST5_SAMPLER_FNC(TEX, UV) GAUSSIANBLUR_SAMPLER_FNC(TEX, UV)
#else
#define GAUSSIANBLUR1D_FAST5_SAMPLER_FNC(TEX, UV) sampleClamp2edge(TEX, UV)
#endif
#endif
#ifndef FNC_GAUSSIANBLUR1D_FAST5
#define FNC_GAUSSIANBLUR1D_FAST5
GAUSSIANBLUR1D_FAST5_TYPE gaussianBlur1D_fast5(in SAMPLER_TYPE tex, in vec2 st, in vec2 offset) {
    GAUSSIANBLUR1D_FAST5_TYPE color = GAUSSIANBLUR1D_FAST5_TYPE(0.);
    vec2 off1 = vec2(1.3333333333333333) * offset;
    color += GAUSSIANBLUR1D_FAST5_SAMPLER_FNC(tex, st) * .29411764705882354;
    color += GAUSSIANBLUR1D_FAST5_SAMPLER_FNC(tex, st + (off1)) * .35294117647058826;
    color += GAUSSIANBLUR1D_FAST5_SAMPLER_FNC(tex, st - (off1)) * .35294117647058826;
    return color;
}
#endif

#ifndef FNC_GAUSSIANBLUR
#define FNC_GAUSSIANBLUR
GAUSSIANBLUR_TYPE gaussianBlur13(in SAMPLER_TYPE tex, in vec2 st, in vec2 offset) {
#ifdef GAUSSIANBLUR_2D
    return gaussianBlur2D(tex, st, offset, 7);
#else
    return gaussianBlur1D_fast13(tex, st, offset);
#endif
}
GAUSSIANBLUR_TYPE gaussianBlur9(in SAMPLER_TYPE tex, in vec2 st, in vec2 offset) {
#ifdef GAUSSIANBLUR_2D
    return gaussianBlur2D(tex, st, offset, 5);
#else
    return gaussianBlur1D_fast9(tex, st, offset);
#endif
}
GAUSSIANBLUR_TYPE gaussianBlur5(in SAMPLER_TYPE tex, in vec2 st, in vec2 offset) {
#ifdef GAUSSIANBLUR_2D
    return gaussianBlur2D(tex, st, offset, 3);
#else
    return gaussianBlur1D_fast5(tex, st, offset);
#endif
}
GAUSSIANBLUR_TYPE gaussianBlur(in SAMPLER_TYPE tex, in vec2 st, in vec2 offset, const int kernelSize) {
#ifdef GAUSSIANBLUR_2D
    return gaussianBlur2D(tex, st, offset, kernelSize);
#else
    return gaussianBlur1D(tex, st, offset, kernelSize);
#endif
}
GAUSSIANBLUR_TYPE gaussianBlur(in SAMPLER_TYPE tex, in vec2 st, in vec2 offset) {
    return GAUSSIANBLUR_AMOUNT(tex, st, offset);
}
#endif
