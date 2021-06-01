#pragma language glsl3

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

attribute vec3 VertexNormal;

out vec4 worldPosition;
out vec3 normal;

vec4 position(mat4 transform_projection, vec4 vertex_position)
{
    normal = normalize((model * vec4(VertexNormal, 0.0)).xyz);
    worldPosition = model * vertex_position;
    return projection * view * model * vertex_position;
}