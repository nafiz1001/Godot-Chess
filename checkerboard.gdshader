shader_type canvas_item;

uniform int square_count = 8;
uniform vec4 color1 : source_color = vec4(1.0, 1.0, 1.0, 1.0); 
uniform vec4 color2 : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
    vec2 pos = floor(UV * float(square_count));
    float pattern_mask = mod(pos.x + mod(pos.y, 2.0), 2.0);
    COLOR = mix(color1, color2, pattern_mask);
}