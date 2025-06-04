precision highp float;

uniform sampler2D uMap;
uniform sampler2D uAlphaMap;
uniform vec2 uSize;
uniform float uIntensity;

varying vec2 vUv;

vec3 draw(sampler2D image, vec2 uv) {
  return texture2D(image,vec2(uv.x, uv.y)).rgb;   
}
float rand(vec2 co){
  return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}
/*
  inspired by https://www.shadertoy.com/view/4tSyzy
  @anastadunbar
*/
vec3 blur(vec2 uv, sampler2D image, float blurAmount){
  vec3 blurredImage = vec3(0.);
  float d = smoothstep(0.8, 0.0, (gl_FragCoord.y / uSize.y) / uSize.y);
  #define repeats 40.
  for (float i = 0.; i < repeats; i++) { 
    vec2 q = vec2(cos(degrees((i / repeats) * 360.)), sin(degrees((i / repeats) * 360.))) * (rand(vec2(i, uv.x + uv.y)) + blurAmount); 
    vec2 uv2 = uv + (q * blurAmount * d);
    blurredImage += draw(image, uv2) / 2.;
    q = vec2(cos(degrees((i / repeats) * 360.)), sin(degrees((i / repeats) * 360.))) * (rand(vec2(i + 2., uv.x + uv.y + 24.)) + blurAmount); 
    uv2 = uv + (q * blurAmount * d);
    blurredImage += draw(image, uv2) / 2.;
  }
  return blurredImage / repeats;
}


void main() {
    vec3 newBlur = blur(vUv, uMap,  uIntensity * 0.08);
    vec3 alphaBlur = blur(vUv, uAlphaMap,  uIntensity * 0.08);

    gl_FragColor = vec4(newBlur, alphaBlur.r);

}