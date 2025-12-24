shader_type spatial;

uniform float viewmodel_fov = 90.0f;
uniform vec3 uv1_scale = vec3(1.0f);
uniform vec3 uv1_offset = vec3(0.0f);
uniform vec3 uv2_scale = vec3(1.0f);
uniform vec3 uv2_offset = vec3(0.0f);

void vertex() {
	UV= UV * uv1_scale.xy - uv1_offset.xy;
	
	float onetanfov = 1.0f / tan(0.5f * (viewmodel_fov * PI / 180.0f));
	float aspect = VIEWPORT_SIZE.x / VIEWPORT_SIZE.y;
	// modify projection matrix
	PROJECTION_MATRIX[1][1] = -onetanfov;
	PROJECTION_MATRIX[0][0] = onetanfov / aspect;

	// draws the viewmodel over everything (disable if you want dof near on viewmodel)
	POSITION = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX.xyz, 1.0);
	POSITION.z = mix(POSITION.z, 0, 0.99);
}