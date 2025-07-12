shader_type canvas_item;

uniform float radius      : hint_range(0.0, 10.0) = 3.0;
uniform float desat_amt   : hint_range(0.0, 1.0)  = 0.1;
uniform float brightness  : hint_range(0.0, 1.0)  = 0.45;

void fragment() {
    vec2 texel = TEXTURE_PIXEL_SIZE;
    vec4 sum = vec4(0.0);

    // 3×3 box blur
    for (int xi = -1; xi <= 1; xi++) {
        for (int yi = -1; yi <= 1; yi++) {
            float x = float(xi);
            float y = float(yi);
            sum += texture(TEXTURE, UV + vec2(x, y) * texel * radius);
        }
    }
    vec4 blurred = sum / 9.0;

    // desaturate
    float gray = dot(blurred.rgb, vec3(0.3, 0.59, 0.11));
    vec3 desat = mix(blurred.rgb, vec3(gray), desat_amt);

    // darken
    vec3 darkened = desat * brightness;

    COLOR = vec4(darkened, blurred.a);
}
