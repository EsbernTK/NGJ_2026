shader_type canvas_item;

uniform float alpha = 1.0; // you can assign a default value to uniforms
uniform float radius = 0.3; // you can assign a default value to uniforms
uniform vec2 target = vec2 (-1.0f, -1.0f);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 dist = target - UV;
	float d = sqrt(dist.x * dist.x + dist.y * dist.y);
	
	if (d < radius) {
		COLOR = vec4(UV, 0.5, 0.1);
	}
	else {
		COLOR = vec4(UV, 0.5, alpha);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
