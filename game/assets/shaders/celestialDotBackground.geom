#version 460 core

#define _DEBUG
#define SHADER_GEOM
#define SHADER_SUBPASS_0

#extension GL_ARB_shader_viewport_layer_array : enable

layout(std430, push_constant) uniform StarPushConstant {
	vec4 relativePosition; // w = sizeFactor
	
	// Used Only for celestials
	vec4 color;
	
	// Used Only for stars
	float minViewDistance;
	float maxViewDistance;
	
	float screenSize;
	float brightnessFactor;
};

float maxDistanceSqr = maxViewDistance*maxViewDistance;
float minDistanceSqr = minViewDistance*minViewDistance;
float sizeFactor = relativePosition.w;

uint RandomInt(inout uint seed) {
	return (seed = 1664525 * seed + 1013904223);
}
float RandomFloat(inout uint seed) {
	return (float(RandomInt(seed) & 0x00FFFFFF) / float(0x01000000));
}

// Vertex shader
#ifdef SHADER_VERT

	#ifdef USE_VERTEX_INPUTS
		layout(location = 0) in vec4 in_position;
		layout(location = 1) in vec4 in_color;
	#endif

	layout(location = 0) out vec4 out_color;

	void main() {
		#ifdef USE_VERTEX_INPUTS
			gl_Position = in_position;
			out_color = in_color;
		#else
			gl_Position = vec4(0);
			out_color = color;
		#endif
	}

#endif

// Geometry Shader
#ifdef SHADER_GEOM
	layout(points) in;
	layout(points, max_vertices = 6) out;
	layout(location = 0) in vec4 in_color[];
	layout(location = 0) out vec4 out_color;

	vec3 pos = relativePosition.xyz + gl_in[0].gl_Position.xyz;
	float pointDistanceSqr = dot(pos, pos);
	float dd = maxViewDistance==0? 1.0 : clamp(smoothstep(maxDistanceSqr, minDistanceSqr, pointDistanceSqr), 0, 1);
	float dd2 = maxViewDistance==0? 1.0 : clamp(smoothstep(0, minDistanceSqr, pointDistanceSqr), 0, 1);
	vec4 pointColor = vec4(in_color[0].rgb, clamp(pow(in_color[0].a * (dd + dd2) * brightnessFactor, 0.5), 0.0, 100.0));
	
	void EmmitStar(int layer, vec2 coord) {
		gl_Layer = layer;
		gl_Position = vec4(coord,0,1);
		gl_PointSize = gl_in[0].gl_Position.w * sizeFactor * 0.5 * (1.5 + sin(dot(coord.xy, coord.xy))); // adjust point size for corners
		if ((pointColor.a > 15)) {
			out_color = pointColor * 4;
		} else {
			out_color = pointColor;
		}
		EmitVertex();
	}

	void main(void) {
		if (maxDistanceSqr > 0 && pointDistanceSqr > maxDistanceSqr)
			return;
		if (pointColor.a < 0.0001)
			return;
			
		const float threshold = 0.5; // for a point to appear on multiple sides of the cubemap
		
		#ifdef USE_VERTEX_INPUTS
			uint i = gl_PrimitiveIDIn;
			pos += mix(vec3(RandomFloat(i), RandomFloat(i), RandomFloat(i))*2-1, vec3(0), dd);
		#endif
		
		if (pos.x > 0 && abs(pos.z)-threshold <= pos.x && abs(pos.y)-threshold <= pos.x)
			EmmitStar(0, vec2(-pos.z / pos.x, -pos.y / pos.x));
		if (-pos.x > 0 && abs(pos.z)-threshold <= -pos.x && abs(pos.y)-threshold <= -pos.x)
			EmmitStar(1, vec2(-pos.z / pos.x, pos.y / pos.x));
		if (pos.y > 0 && abs(pos.z)-threshold <= pos.y && abs(pos.x)-threshold <= pos.y)
			EmmitStar(2, vec2(pos.x / pos.y, pos.z / pos.y));
		if (-pos.y > 0 && abs(pos.z)-threshold <= -pos.y && abs(pos.x)-threshold <= -pos.y)
			EmmitStar(3, vec2(-pos.x / pos.y, pos.z / pos.y));
		if (pos.z > 0 && abs(pos.x)-threshold <= pos.z && abs(pos.y)-threshold <= pos.z)
			EmmitStar(4, vec2(pos.x / pos.z, -pos.y / pos.z));
		if (-pos.z > 0 && abs(pos.x)-threshold <= -pos.z && abs(pos.y)-threshold <= -pos.z)
			EmmitStar(5, vec2(pos.x / pos.z, pos.y / pos.z));
	}
#endif

// Fragment Shader
#ifdef SHADER_FRAG
	layout(location = 0) in vec4 in_color;
	layout(location = 0) out vec4 out_color;

	void main() {
		float center = max(0, 1.0 - pow(length(gl_PointCoord * 2 - 1), 4));
		out_color = vec4(in_color.rgb * in_color.a, in_color.a) * 0.1 * pow(center, 4);
	}
#endif


