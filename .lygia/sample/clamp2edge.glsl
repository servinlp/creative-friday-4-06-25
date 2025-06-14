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