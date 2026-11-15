#version 440
// Tube cathodique : courbure, lignes de balayage, aberration, vignette, teinte
// chaude (même esprit que le shader CRT de kitty), neige pendant les transitions.
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float curvature;
    float scan;
    float lines;
    float vignette;
    float aberration;
    float noise;
    float time;
    vec4 tint;
};
layout(binding = 1) uniform sampler2D source;

float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }

void main() {
    vec2 c = qt_TexCoord0 * 2.0 - 1.0;
    c *= 1.0 + curvature * dot(c, c);
    c /= 1.0 + curvature;
    vec2 uv = c * 0.5 + 0.5;
    vec2 off = vec2(aberration * c.x, 0.0);
    vec3 col = vec3(texture(source, uv + off).r, texture(source, uv).g, texture(source, uv - off).b);
    float s = 0.5 + 0.5 * cos(uv.y * lines * 6.2831853);
    col *= 1.0 - scan * (1.0 - s);
    col = mix(col, col * tint.rgb, tint.a);
    col *= 1.0 - vignette * smoothstep(0.55, 1.45, length(c * vec2(0.9, 1.0)));
    col += noise * (hash(floor(uv * vec2(480.0, 270.0)) + time) - 0.5);
    vec2 e = step(vec2(0.0), uv) * step(uv, vec2(1.0));
    fragColor = vec4(col * e.x * e.y, 1.0) * qt_Opacity;
}
