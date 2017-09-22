#version 140

precision highp float; // needed only for version 1.30

in  vec3 ex_Normal;
in  vec4 ex_Color;
in  vec2 ex_UV;

out vec4 out_Color;

uniform sampler2D u_Texture;

void main(void)
{
    vec4 tex = texture(u_Texture, ex_UV);
    out_Color = ex_Color * tex;
}
