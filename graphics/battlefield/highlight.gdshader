shader_type canvas_item;

uniform float highlight_opacity : hint_range(0.0, 1.0) = 0.5;
uniform vec4 highlight_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    vec4 original = texture(TEXTURE, UV);

    // Only highlight opaque pixels (using the original alpha as a mask)
    vec3 blended = mix(original.rgb, highlight_color.rgb, highlight_opacity * original.a);

    COLOR = vec4(blended, original.a);
}