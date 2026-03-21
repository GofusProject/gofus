shader_type canvas_item;

uniform int color_count = 3;

uniform vec4 src0 : source_color;
uniform vec4 src1 : source_color;
uniform vec4 src2 : source_color;

uniform vec4 dst0 : source_color;
uniform vec4 dst1 : source_color;
uniform vec4 dst2 : source_color;

uniform float tolerance = 0.2;

vec3 swap_color(vec3 c) {
    vec3 accum = c;
    float total_w = 1.0;

    if (color_count > 0) {
        float d = distance(c, src0.rgb);
        float w = smoothstep(tolerance, 0.0, d);
        accum = mix(accum, dst0.rgb, w);
        total_w += w;
    }
    if (color_count > 1) {
        float d = distance(c, src1.rgb);
        float w = smoothstep(tolerance, 0.0, d);
        accum = mix(accum, dst1.rgb, w);
        total_w += w;
    }
    if (color_count > 2) {
        float d = distance(c, src2.rgb);
        float w = smoothstep(tolerance, 0.0, d);
        accum = mix(accum, dst2.rgb, w);
        total_w += w;
    }

    return accum;
}

void fragment() {
    vec4 col = texture(TEXTURE, UV);
    if (col.a <= 0.0) {
        COLOR = col;
    } else {
        vec3 swapped = swap_color(col.rgb);
        COLOR = vec4(swapped, col.a);
    }
}