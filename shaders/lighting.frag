#pragma language glsl3

uniform vec3 sunDirection = normalize(vec3(0.5, 1, 0.7));
uniform mat4 shadowView;
uniform mat4 shadowProjection;
uniform Image shadowMap;

float shadowDelta = 0.001;

uniform float ambientLight = 0.2;

in vec4 worldPosition;
in vec3 normal;

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    float shading = smoothstep(
	    0.4, 1.0,
	    (dot(normal, -sunDirection) + 1.0) / 2.0
	);
    vec4 shadowPosition = shadowProjection * shadowView * worldPosition;
    shadowPosition = (shadowPosition + 1) / 2;
    //TODO replace this with something non-branching
    if(Texel(shadowMap, shadowPosition.xy).r + shadowDelta < shadowPosition.z)
    {
        shading *= 0.5;
    }
    shading = max(ambientLight, shading);
    return Texel(tex, texture_coords) * vec4(shading, shading, shading, 1) * color;
}
