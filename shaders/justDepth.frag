#pragma language glsl3

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    //it doesn't really matter what we return here, this shader is run just for the depth info
    return vec4(0);
}
