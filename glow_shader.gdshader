shader_type canvas_item;

uniform vec4 color : source_color = vec4(1.0);
uniform float width : hint_range(0, 50) = 1.0;

void vertex() {
  VERTEX += (UV * 2.0 - 1.0) * width;
}

bool hasContraryNeighbour(vec2 uv, vec2 texture_pixel_size, sampler2D texture) {
  for (float x = -10.0; x <= 10.0; x++) {
    float offset = width - abs(x);
    for (float y = -10.0; y <= 10.0; y++) {
      if (abs(x) + abs(y) <= width) {
        vec2 xy = uv + texture_pixel_size * vec2(x, y);
        
        if (xy == clamp(xy, vec2(0.0), vec2(1.0)) && texture(texture, xy).a != 0.0) {
          return true;
        }
      }
    }
  }
  
  return false;
}

void fragment() {
  vec2 uv = UV;
  
  vec2 texture_pixel_size = vec2(1.0) / (vec2(1.0) / TEXTURE_PIXEL_SIZE + vec2(width * 2.0));
  
  uv = (uv - texture_pixel_size * width) * TEXTURE_PIXEL_SIZE / texture_pixel_size;
  
  if (uv != clamp(uv, vec2(0.0), vec2(1.0))) {
    COLOR.a = 0.0;
  } else {
    COLOR = texture(TEXTURE, uv);
  }
  
  if (COLOR.a <= 0.0 && hasContraryNeighbour(uv, TEXTURE_PIXEL_SIZE, TEXTURE)) {
    COLOR = vec4(1.0);
  }
}