#version 460 core

#define _DEBUG
#define SHADER_RCHIT
#define SHADER_SUBPASS_2

#define SHADER_RAYTRACING
#ifndef _SHADER_BASE_INCLUDED_
#define _SHADER_BASE_INCLUDED_

#extension GL_EXT_buffer_reference2 : require
#extension GL_EXT_nonuniform_qualifier : require

#pragma region HEADER
	#ifdef __cplusplus
		#pragma once
		# include "v4d/core/utilities/graphics/shaders/cpp_glsl_head.hh"
		namespace game::graphics {
	#else
#ifndef __cplusplus
	#extension GL_EXT_shader_explicit_arithmetic_types_int8 : enable
	#extension GL_EXT_shader_explicit_arithmetic_types_int16 : enable
	#extension GL_EXT_shader_explicit_arithmetic_types_int32 : enable
	#extension GL_EXT_shader_explicit_arithmetic_types_int64 : enable
	#extension GL_EXT_shader_explicit_arithmetic_types_float32 : enable
	#extension GL_EXT_shader_explicit_arithmetic_types_float64 : enable
	#define STATIC_ASSERT_ALIGNED16_SIZE(T,X)
	#define STATIC_ASSERT_SIZE(T,X)
	#define VkDeviceAddress uint64_t
	#define BUFFER_REFERENCE_STRUCT(align) layout(buffer_reference, std430, buffer_reference_align = align) buffer
	#define BUFFER_REFERENCE_STRUCT_READONLY(align) layout(buffer_reference, std430, buffer_reference_align = align) buffer readonly
	#define BUFFER_REFERENCE_STRUCT_WRITEONLY(align) layout(buffer_reference, std430, buffer_reference_align = align) buffer writeonly
	#define BUFFER_REFERENCE_ADDR(type) type
#endif
	#endif
#pragma endregion

#define RENDERABLE_TYPE_SOLID_GEOMETRY (1u<< 0)
#define RENDERABLE_TYPE_TERRAIN (1u<< 1)
#define RENDERABLE_TYPE_TERRAIN_CLUTTER (1u<< 2)
#define RENDERABLE_TYPE_ATMOSPHERE (1u<< 3)
#define RENDERABLE_TYPE_LIGHT (1u<< 4)
// #define RENDERABLE_TYPE_xxx (1u<< 5)
// #define RENDERABLE_TYPE_xxx (1u<< 6)
// #define RENDERABLE_TYPE_xxx (1u<< 7)
#define RENDERABLE_ALL_SOLID (RENDERABLE_TYPE_SOLID_GEOMETRY | RENDERABLE_TYPE_TERRAIN | RENDERABLE_TYPE_TERRAIN_CLUTTER)
#define RENDERABLE_ALL_FOG (RENDERABLE_TYPE_ATMOSPHERE)

#define SET0_BINDING_RENDERABLE_INSTANCES_BUFFER 0
#define SET0_BINDING_SAMPLER_LIGHT_IMAGE 1
#define SET0_BINDING_SAMPLER_LIT_IMAGE 2
#define SET0_BINDING_SAMPLER_POST 3
#define SET0_BINDING_SAMPLER_HISTORY 4
#define SET0_BINDING_STORAGE_EMISSION_IMAGE 5
#define SET0_BINDING_INPUT_OVERLAY_IMAGE 6
#define SET0_BINDING_INPUT_OUTPUT_RESOLVED_IMAGE 7
#define SET0_BINDING_SAMPLER_RESOLVED_IMAGE 8
#define SET0_BINDING_STORAGE_HISTORY_IMAGE 9
#define SET0_BINDING_STORAGE_LIT_IMAGE 10
#define SET0_BINDING_STORAGE_POST_IMAGE 11
#define SET0_BINDING_SAMPLER_MOTION_IMAGE 12
#define SET0_BINDING_STORAGE_MOTION_IMAGE 13
#define SET0_BINDING_SAMPLER_BACKGROUND 14
#define SET0_BINDING_CAMERAS 16
#define SET0_BINDING_TEXTURES 17 // Must be the last descriptor in the set, because it's an unbounded array

#define SET1_BINDING_INPUT_GBUFFER_COLOR 0
#define SET1_BINDING_INPUT_GBUFFER_NORMAL 1
#define SET1_BINDING_INPUT_GBUFFER_PBR 2
#define SET1_BINDING_INPUT_GBUFFER_INDEX 3
#define SET1_BINDING_SAMPLER_RT_DEPTH 4
#define SET1_BINDING_STORAGE_RT_DEPTH 5
#define SET1_BINDING_SAMPLER_GBUFFER_DEPTH 6
#define SET1_BINDING_TLAS 7
#define SET1_BINDING_STORAGE_LIGHT_IMAGE 8
#define SET1_BINDING_STORAGE_GBUFFER_COLOR 9
#define SET1_BINDING_STORAGE_GBUFFER_NORMAL 10
#define SET1_BINDING_STORAGE_GBUFFER_PBR 11
#define SET1_BINDING_STORAGE_GBUFFER_INDEX 12
#define SET1_BINDING_STORAGE_INDEX_HISTORY 13
#define SET1_BINDING_SAMPLER_LIGHT_HISTORY 14
#define SET1_BINDING_xxxxx 15 // available
#define SET1_BINDING_STORAGE_FOG_IMAGE 16
#define SET1_BINDING_LUMINANCE_BUFFER 17
#define SET1_BINDING_MAXDEPTH_BUFFER 18
#define SET1_BINDING_TLAS_INSTANCES 19
#define SET1_BINDING_THUMBNAILS 20 // Must be the last descriptor in the set, because it's an unbounded array

#define LIGHT_LUMINOSITY_VISIBLE_THRESHOLD 0.02
#define MAX_TEXTURE_BINDINGS 65535u
#define MAX_CAMERAS 64u
#define HISTOGRAM_COMPUTE_INVOCATIONS_X 32
#define HISTOGRAM_COMPUTE_INVOCATIONS_Y 32
#define DENOISE_COMPUTE_INVOCATIONS_X 32
#define DENOISE_COMPUTE_INVOCATIONS_Y 32
#define SHARPEN_COMPUTE_INVOCATIONS_X 32
#define SHARPEN_COMPUTE_INVOCATIONS_Y 32
#define TXAA_SAMPLES 16

// up to 32 render options
#define RENDER_OPTION_GAMMA (1u<< 0)
#define RENDER_OPTION_HDR (1u<< 1)
#define RENDER_OPTION_TXAA (1u<< 2)
#define RENDER_OPTION_SOFT_SHADOWS (1u<< 3)
#define RENDER_OPTION_RT_REFLECTIONS (1u<< 4)
#define RENDER_OPTION_TEMPORAL_DENOISING (1u<< 5)
#define RENDER_OPTION_RAY_TRACED_VISIBILITY (1u<< 6)
#define RENDER_OPTION_DLSS (1u<< 7)

// up to 32 debug options
#define RENDER_DEBUG_LIGHTS (1u<< 0)
#define RENDER_DEBUG_HDR_FULL_RANGE (1u<< 1)
#define RENDER_DEBUG_FORCE_UNIFORM_SUNLIGHT (1u<< 2)
#define RENDER_DEBUG_ACCUMULATE_SAMPLES (1u<< 3)
#define RENDER_DEBUG_RT_SEEN_BY_GI_PASS (1u<< 4)
#define RENDER_DEBUG_USE_DEBUG_VALUES (1u<< 5)
#define RENDER_DEBUG_FORCE_AMBIENT_LIGHTING (1u<< 6)

// Debug view modes
#define RENDER_DEBUG_VIEWMODE_COLOR 1
#define RENDER_DEBUG_VIEWMODE_NORMAL 2
#define RENDER_DEBUG_VIEWMODE_DEPTH 3
#define RENDER_DEBUG_VIEWMODE_DISTANCE 4
#define RENDER_DEBUG_VIEWMODE_METALLIC 5
#define RENDER_DEBUG_VIEWMODE_ROUGHNESS 6
#define RENDER_DEBUG_VIEWMODE_FRESNEL 7
#define RENDER_DEBUG_VIEWMODE_LIGHTING 8
#define RENDER_DEBUG_VIEWMODE_RT_TIME 9
#define RENDER_DEBUG_VIEWMODE_MOTION 10
#define RENDER_DEBUG_VIEWMODE_EMISSION 11
#define RENDER_DEBUG_VIEWMODE_FOG 12
#define RENDER_DEBUG_VIEWMODE_THUMBNAIL 13

// 16 flags for Terrain Vertices
#define TERRAIN_VERTEX_FLAG_TESSELLATE (1u<< 0)
#define TERRAIN_VERTEX_FLAG_DISPLACE (1u<< 1)
#define TERRAIN_VERTEX_FLAG_ROTATE_TEXTURES (1u<< 2)
// #define TERRAIN_VERTEX_FLAG_ (1u<< 2)
// #define TERRAIN_VERTEX_FLAG_ (1u<< 3)
// #define TERRAIN_VERTEX_FLAG_ (1u<< 4)
// #define TERRAIN_VERTEX_FLAG_ (1u<< 5)
// #define TERRAIN_VERTEX_FLAG_ (1u<< 6)
// #define TERRAIN_VERTEX_FLAG_ (1u<< 7)
// #define TERRAIN_VERTEX_FLAG_ (1u<< 8)
// #define TERRAIN_VERTEX_FLAG_ (1u<< 9)
// #define TERRAIN_VERTEX_FLAG_ (1u<< 10)
// #define TERRAIN_VERTEX_FLAG_ (1u<< 11)
// #define TERRAIN_VERTEX_FLAG_ (1u<< 12)
// #define TERRAIN_VERTEX_FLAG_ (1u<< 13)
#define TERRAIN_VERTEX_FLAG_IS_FLAT (1u<< 14)
#define TERRAIN_VERTEX_FLAG_IS_SKIRT (1u<< 15)
#define TERRAIN_VERTEX_FLAGS_DEFAULT ( TERRAIN_VERTEX_FLAG_TESSELLATE | TERRAIN_VERTEX_FLAG_DISPLACE | TERRAIN_VERTEX_FLAG_ROTATE_TEXTURES )

// 8 Terrain Biomes
#define TERRAIN_BIOME_INDEX_BROWN 0
#define TERRAIN_BIOME_INDEX_WHITE 1
#define TERRAIN_BIOME_INDEX_GREY 2
#define TERRAIN_BIOME_INDEX_BLACK 3
#define TERRAIN_BIOME_INDEX_YELLOW 4
#define TERRAIN_BIOME_INDEX_RED 5
#define TERRAIN_BIOME_INDEX_BLUE 6
#define TERRAIN_BIOME_INDEX_GREEN 7
#define TERRAIN_BIOME_FLAG_BROWN (1u<<TERRAIN_BIOME_INDEX_BROWN)
#define TERRAIN_BIOME_FLAG_WHITE (1u<<TERRAIN_BIOME_INDEX_WHITE)
#define TERRAIN_BIOME_FLAG_GREY (1u<<TERRAIN_BIOME_INDEX_GREY)
#define TERRAIN_BIOME_FLAG_BLACK (1u<<TERRAIN_BIOME_INDEX_BLACK)
#define TERRAIN_BIOME_FLAG_YELLOW (1u<<TERRAIN_BIOME_INDEX_YELLOW)
#define TERRAIN_BIOME_FLAG_RED (1u<<TERRAIN_BIOME_INDEX_RED)
#define TERRAIN_BIOME_FLAG_BLUE (1u<<TERRAIN_BIOME_INDEX_BLUE)
#define TERRAIN_BIOME_FLAG_GREEN (1u<<TERRAIN_BIOME_INDEX_GREEN)

// 8 Terrain Features
#define TERRAIN_FEATURE_INDEX_CRATER 0
#define TERRAIN_FEATURE_INDEX_FOLDED 1
#define TERRAIN_FEATURE_INDEX_FAULTBLOCK 2
#define TERRAIN_FEATURE_INDEX_DOME 3
#define TERRAIN_FEATURE_INDEX_PLATEAU 4
#define TERRAIN_FEATURE_INDEX_VOLCANO 5
#define TERRAIN_FEATURE_INDEX_CANYON 6
#define TERRAIN_FEATURE_INDEX_LAKE 7
#define TERRAIN_FEATURE_FLAG_CRATER (1u<<TERRAIN_FEATURE_INDEX_CRATER)
#define TERRAIN_FEATURE_FLAG_FOLDED (1u<<TERRAIN_FEATURE_INDEX_FOLDED)
#define TERRAIN_FEATURE_FLAG_FAULTBLOCK (1u<<TERRAIN_FEATURE_INDEX_FAULTBLOCK)
#define TERRAIN_FEATURE_FLAG_DOME (1u<<TERRAIN_FEATURE_INDEX_DOME)
#define TERRAIN_FEATURE_FLAG_PLATEAU (1u<<TERRAIN_FEATURE_INDEX_PLATEAU)
#define TERRAIN_FEATURE_FLAG_VOLCANO (1u<<TERRAIN_FEATURE_INDEX_VOLCANO)
#define TERRAIN_FEATURE_FLAG_CANYON (1u<<TERRAIN_FEATURE_INDEX_CANYON)
#define TERRAIN_FEATURE_FLAG_LAKE (1u<<TERRAIN_FEATURE_INDEX_LAKE)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Structs and Buffer References -- Must use explicit arithmetic types (or VkDeviceAddress as an uint64_t, or BUFFER_REFERENCE_ADDR(StructType))
#define GeometryBufferReferences\
	VkDeviceAddress indexBufferPtr_u16;\
	VkDeviceAddress indexBufferPtr_u32;\
	VkDeviceAddress vertexBufferPtr_f32_3;\
	VkDeviceAddress normalBufferPtr_f32_3;\
	VkDeviceAddress colorBufferPtr_f32vec4;\
	VkDeviceAddress texCoord0BufferPtr_f32vec2;\
	VkDeviceAddress texCoord1BufferPtr_f32vec2;\
	VkDeviceAddress tangentBufferPtr_f32vec4;\

BUFFER_REFERENCE_STRUCT_READONLY(16) SharedGeometryData {
	GeometryBufferReferences
	u8vec4 material_albedo;
	uint8_t material_metallic;
	uint8_t material_roughness;
	uint16_t material_albedoTexture;
	uint16_t material_pbrTexture;
	uint16_t material_normalTexture;
	float32_t material_indexOfRefraction;
};
STATIC_ASSERT_ALIGNED16_SIZE(SharedGeometryData, 80)
BUFFER_REFERENCE_STRUCT_READONLY(16) TerrainGeometryData {
	GeometryBufferReferences
	f32vec2 uvOffset_unused; // Or VkDeviceAddress spotBuffer;
	float uvScale_unused; // Or uint8_t nbSpots; + uint8_t + uint16_t
	float chunkSize;
};
STATIC_ASSERT_ALIGNED16_SIZE(TerrainGeometryData, sizeof(SharedGeometryData))

BUFFER_REFERENCE_STRUCT_READONLY(16) TerrainExtraVertexData {
	u16vec4 textures;
	u8vec4 blending;
	float32_t temperature;
	f32vec3 upDir;
	uint16_t flags;
	uint8_t biomes;
	uint8_t features;
};
STATIC_ASSERT_ALIGNED16_SIZE(TerrainExtraVertexData, 32)

BUFFER_REFERENCE_STRUCT_READONLY(16) TerrainClutterAabbData {
	float32_t aabb[6];
	uint32_t seed;
	uint16_t flags;
	uint16_t tex;
};
STATIC_ASSERT_ALIGNED16_SIZE(TerrainClutterAabbData, 32)

BUFFER_REFERENCE_STRUCT_READONLY(16) GeometryInstanceData {
	uint32_t aimID; // 0 means no aim for this geometry
	uint16_t emissiveTexture;
	
	// Not implemented yet
	uint16_t _damageAlbedoTexture;
	uint16_t _damageNormalTexture;
	uint16_t _corrosionAlbedoTexture;
	uint16_t _corrosionNormalTexture;
	uint8_t _damageAmount;
	uint8_t _corrosionAmount;
	
	VkDeviceAddress extraBufferPtr;
	VkDeviceAddress geometryBufferPtr; // points to one of (SharedGeometryData, TerrainGeometryData, )
	f32vec4 albedo_opacity;
	f32vec4 emission_temperature;
};
STATIC_ASSERT_ALIGNED16_SIZE(GeometryInstanceData, 64)

BUFFER_REFERENCE_STRUCT_READONLY(16) ProceduralGeometryData {
	float32_t aabb[6];
	VkDeviceAddress geometryBufferPtr; // points to any custom buffer
	f32vec4 albedo_opacity;
	f32vec4 emission_temperature;
};
STATIC_ASSERT_ALIGNED16_SIZE(ProceduralGeometryData, 64)

#ifdef __cplusplus
	union GenericGeometryUnion {
		GeometryInstanceData geometryInstance;
		ProceduralGeometryData proceduralGeometry;
	};
	static_assert(sizeof(GeometryInstanceData) == sizeof(ProceduralGeometryData));
#endif

struct RenderableInstanceData {
	VkDeviceAddress instanceBufferPtr; // points to one of (GeometryInstanceData, LightSourceInstanceData, TerrainClutterAabbData, )
	uint64_t moduleVendor;
	uint64_t moduleID;
	uint64_t entityID;
};
STATIC_ASSERT_ALIGNED16_SIZE(RenderableInstanceData, 32)

struct RasterVertexPushConstant {
	f32mat4 modelViewMatrix;
	f32mat3x4 historyModelViewMatrix;
	uint32_t renderableInstanceIndex;
	uint32_t geometryIndex;
	uint32_t cameraIndex;
	uint32_t _unused1;
};
STATIC_ASSERT_SIZE(RasterVertexPushConstant, 128) // max 128 for AMD support, otherwise nvidia supports 256

struct LightSourceInstanceData {
	float32_t aabb[6];
	float32_t radius;
	float32_t maxDistance;
	f32vec3 color;
	float32_t power;
	f32vec3 direction;
	float32_t diffuse;
};
STATIC_ASSERT_ALIGNED16_SIZE(LightSourceInstanceData, 64)

struct RasterLightPushConstant {
	LightSourceInstanceData lightSource;
	f32vec3 viewSpacePosition;
	uint32_t cameraIndex;
};
STATIC_ASSERT_SIZE(RasterLightPushConstant, 80)

BUFFER_REFERENCE_STRUCT_READONLY(16) SunlightSource {
	f32vec3 position;
	float32_t radius;
	f32vec3 color;
	float32_t luminosity;
};

BUFFER_REFERENCE_STRUCT_READONLY(16) CelestialInstanceData {
	#ifdef __cplusplus
		SunlightSource sun[2];
	#else
		f32mat4 _sun;
	#endif
	float32_t aabb[6];
	float32_t surfaceTemperature;
	float32_t coronaTemperature;
	f32vec3 position;
	float32_t innerRadius;
	float32_t outerRadius;
	float32_t atmosphereSunGlow;
	float32_t _unused1;
	float32_t _unused2;
	f32vec4 atmosphereRayleigh;
	f32vec4 atmosphereMie;
};
STATIC_ASSERT_SIZE(CelestialInstanceData, 160)

struct RasterAtmospherePushConstant {
	f32mat4 modelViewMatrix;
	float32_t radius;
	uint32_t cameraIndex;
	uint32_t celestialInstanceIndex;
	uint32_t _unused;
};
STATIC_ASSERT_SIZE(RasterAtmospherePushConstant, 80)

struct SecondaryComputePushConstant {
	uint32_t secondaryCameraIndex;
};

struct RayTracingPushConstant {
	uint32_t cameraIndex;
};
STATIC_ASSERT_SIZE(RayTracingPushConstant, 4)

struct DenoisePushConstant {
	i32vec2 blurDir;
	uint32_t blurIndex;
};
STATIC_ASSERT_SIZE(DenoisePushConstant, 16)

BUFFER_REFERENCE_STRUCT_WRITEONLY(16) MVPBufferCurrent {f32mat4 mvp;};
BUFFER_REFERENCE_STRUCT_READONLY(16) MVPBufferHistory {f32mat4 mvp;};
BUFFER_REFERENCE_STRUCT_WRITEONLY(8) RealtimeBufferCurrent {uint64_t mvpFrameIndex;};
BUFFER_REFERENCE_STRUCT_READONLY(8) RealtimeBufferHistory {uint64_t mvpFrameIndex;};
BUFFER_REFERENCE_STRUCT(16) AimBuffer {
	uint32_t aimID;
	float distance;
	f32vec2 uv;
};

struct CameraData {
	f32mat4 viewMatrix;
	f32mat4 historyViewMatrix;
	f32mat4 projectionMatrix;
	f32mat4 projectionMatrixWithTXAA;
	f32mat4 reprojectionMatrix;
	f32mat4 inverseGalaxyWorld;
	f32vec4 luminance;
	f32vec2 txaaOffset;
	f32vec2 historyTxaaOffset;
	float32_t fov;
	float32_t zNear;
	float32_t zFar;
	float32_t brightness;
	float32_t contrast;
	float32_t gamma;
	float32_t framerate;
	float32_t renderScale;
	uint32_t width;
	uint32_t height;
	uint32_t options;
	uint32_t debug;
	uint32_t debugViewMode;
	uint32_t seed;
	uint32_t giBounces;
	uint32_t spp;
	float32_t tessellation;// 1-10
	float32_t tessellationDisplacement;
	float32_t terrainClutterDetail;
	float32_t debugValue1;
	float32_t debugValue2;
	float32_t roughnessFactor;
	uint64_t frameIndex;
	float32_t starBrightnessCompensationForMonitorDuringMovement;
	float32_t _unused1;
	float32_t _unused2;
	float32_t _unused3;
	BUFFER_REFERENCE_ADDR(MVPBufferCurrent) mvpBuffer;
	BUFFER_REFERENCE_ADDR(MVPBufferHistory) mvpBufferHistory;
	BUFFER_REFERENCE_ADDR(RealtimeBufferCurrent) realtimeBuffer;
	BUFFER_REFERENCE_ADDR(RealtimeBufferHistory) realtimeBufferHistory;
	BUFFER_REFERENCE_ADDR(AimBuffer) aimBuffer;
};
STATIC_ASSERT_ALIGNED16_SIZE(CameraData, 576) // max 1024 for support for up to 64 cameras

struct FSRPushConstant {
	u32vec4 Const0;
	u32vec4 Const1;
	u32vec4 Const2;
	u32vec4 Const3;
	u32vec4 Sample;
};
STATIC_ASSERT_SIZE(FSRPushConstant, 80)

struct TLASInstance {
	f32mat3x4 transform;
	uint32_t instanceCustomIndex_and_mask; // mask>>24, customIndex&0xffffff
	uint32_t instanceShaderBindingTableRecordOffset_and_flags; // flags>>24
	VkDeviceAddress accelerationStructureReference;
};

#pragma region FOOTER
	#ifdef __cplusplus
		# include "v4d/core/utilities/graphics/shaders/cpp_glsl_foot.hh"
		}
	#endif
#pragma endregion

// Set 0
layout(set = 0, binding = SET0_BINDING_RENDERABLE_INSTANCES_BUFFER) buffer RenderableInstances { RenderableInstanceData renderableInstances[]; };
layout(set = 0, binding = SET0_BINDING_SAMPLER_LIGHT_IMAGE) uniform sampler2D sampler_light;
layout(set = 0, binding = SET0_BINDING_SAMPLER_LIT_IMAGE) uniform sampler2D sampler_lit;
layout(set = 0, binding = SET0_BINDING_SAMPLER_POST) uniform sampler2D sampler_post;
layout(set = 0, binding = SET0_BINDING_SAMPLER_HISTORY) uniform sampler2D sampler_history;
layout(set = 0, binding = SET0_BINDING_SAMPLER_RESOLVED_IMAGE) uniform sampler2D sampler_resolved;
layout(set = 0, binding = SET0_BINDING_STORAGE_HISTORY_IMAGE, rgba16f) uniform image2D img_history;
layout(set = 0, binding = SET0_BINDING_STORAGE_LIT_IMAGE, rgba16f) uniform image2D img_lit;
layout(set = 0, binding = SET0_BINDING_STORAGE_POST_IMAGE, rgba8) uniform image2D img_post;
layout(set = 0, binding = SET0_BINDING_STORAGE_EMISSION_IMAGE, rgba32f) uniform image2D img_emission;
layout(set = 0, binding = SET0_BINDING_SAMPLER_MOTION_IMAGE) uniform sampler2D sampler_motion;
layout(set = 0, binding = SET0_BINDING_STORAGE_MOTION_IMAGE, rgba32f) uniform image2D img_motion;
layout(set = 0, binding = SET0_BINDING_SAMPLER_BACKGROUND) uniform samplerCube sampler_background;

#ifdef SHADER_FRAG
	layout(set = 0, input_attachment_index = 0, binding = SET0_BINDING_INPUT_OUTPUT_RESOLVED_IMAGE) uniform subpassInput in_img_resolved;
	layout(set = 0, input_attachment_index = 0, binding = SET0_BINDING_INPUT_OVERLAY_IMAGE) uniform subpassInput in_img_overlay;
#endif
layout(set = 0, binding = SET0_BINDING_CAMERAS) uniform CameraUniformBuffer {
	CameraData cameras[MAX_CAMERAS];
};
layout(set = 0, binding = SET0_BINDING_TEXTURES) uniform sampler2D textures[];

// Set 1
layout(set = 1, binding = SET1_BINDING_SAMPLER_GBUFFER_DEPTH) uniform sampler2D sampler_rasterDepth;
layout(set = 1, binding = SET1_BINDING_SAMPLER_RT_DEPTH) uniform sampler2D sampler_rtDepth;
layout(set = 1, binding = SET1_BINDING_STORAGE_RT_DEPTH, r32f) uniform image2D img_rtDepth;
layout(set = 1, binding = SET1_BINDING_STORAGE_INDEX_HISTORY, rg32ui) uniform uimage2D img_index_history;
layout(set = 1, binding = SET1_BINDING_SAMPLER_LIGHT_HISTORY) uniform sampler2D sampler_light_history;
layout(set = 1, binding = SET1_BINDING_STORAGE_LIGHT_IMAGE, rgba16f) uniform image2D img_light;
layout(set = 1, binding = SET1_BINDING_STORAGE_GBUFFER_COLOR, rgba8) uniform image2D img_color;
layout(set = 1, binding = SET1_BINDING_STORAGE_GBUFFER_NORMAL, rgba16f) uniform image2D img_normal;
layout(set = 1, binding = SET1_BINDING_STORAGE_GBUFFER_PBR, rg8) uniform image2D img_pbr;
layout(set = 1, binding = SET1_BINDING_STORAGE_GBUFFER_INDEX, rg32ui) uniform uimage2D img_index;
layout(set = 1, binding = SET1_BINDING_STORAGE_FOG_IMAGE, rgba32f) uniform image2D img_fog;
#ifdef SHADER_FRAG
	layout(set = 1, input_attachment_index = 0, binding = SET1_BINDING_INPUT_GBUFFER_COLOR) uniform subpassInput in_img_color;
	layout(set = 1, input_attachment_index = 1, binding = SET1_BINDING_INPUT_GBUFFER_NORMAL) uniform subpassInput in_img_normal;
	layout(set = 1, input_attachment_index = 2, binding = SET1_BINDING_INPUT_GBUFFER_PBR) uniform subpassInput in_img_pbr;
	layout(set = 1, input_attachment_index = 3, binding = SET1_BINDING_INPUT_GBUFFER_INDEX) uniform usubpassInput in_img_index;
#endif
#if defined(SHADER_RGEN) || defined(SHADER_RCHIT) || defined(SHADER_RMISS)
	#extension GL_EXT_ray_tracing : enable
	layout(set = 1, binding = SET1_BINDING_TLAS) uniform accelerationStructureEXT tlas;
#endif
#ifdef SHADER_SECONDARY_COMPUTE
	layout(set = 1, binding = SET1_BINDING_LUMINANCE_BUFFER) buffer writeonly HistoryOutputData { vec4 buffer_totalLuminance[]; };
	layout(set = 1, binding = SET1_BINDING_MAXDEPTH_BUFFER) buffer writeonly DepthOutputData { float buffer_maxDepthViewDistance[]; };
#endif
layout(set = 1, binding = SET1_BINDING_THUMBNAILS, rgba32f) uniform image2D thumbnails[];

layout(set = 1, binding = SET1_BINDING_TLAS_INSTANCES) buffer TLASInstances {
	TLASInstance tlasInstances[];
};

layout(buffer_reference, std430, buffer_reference_align = 2) buffer Indices16 { uint16_t index_u16; };
layout(buffer_reference, std430, buffer_reference_align = 4) buffer Indices32 { uint32_t index_u32; };
layout(buffer_reference, std430, buffer_reference_align = 4) buffer VertexPositions { float vertex_f32_3; };
layout(buffer_reference, std430, buffer_reference_align = 4) buffer VertexNormals { float normal_f32_3; };
layout(buffer_reference, std430, buffer_reference_align = 16) buffer VertexColorsF32 { vec4 color_f32vec4; };
layout(buffer_reference, std430, buffer_reference_align = 8) buffer VertexUVs { vec2 texCoord0BufferPtr_f32vec2; };
layout(buffer_reference, std430, buffer_reference_align = 8) buffer VertexUVs2 { vec2 texCoord1BufferPtr_f32vec2; };
layout(buffer_reference, std430, buffer_reference_align = 16) buffer VertexTangents { vec4 tangentBufferPtr_f32vec4; };
layout(buffer_reference, std430, buffer_reference_align = 16) buffer LightSourceInstances { LightSourceInstanceData lightSourceInstance; };

///////////////////////////////////////////////////////////////////////////

// Push Constants and current camera
#if defined(SHADER_FIRST_VISIBILITY_PASS)
	layout(push_constant, std430) uniform PushConstant {
		RasterVertexPushConstant pushConstant;
	};
	CameraData camera = cameras[pushConstant.cameraIndex];
#elif defined(SHADER_LIGHTING_PASS)
	layout(push_constant) uniform PushConstant {
		RasterLightPushConstant lightPushConstant;
	};
	CameraData camera = cameras[lightPushConstant.cameraIndex];
#elif defined(SHADER_SECONDARY_COMPUTE)
	layout(push_constant) uniform PushConstant {
		SecondaryComputePushConstant pushConstant;
	};
	CameraData camera = cameras[pushConstant.secondaryCameraIndex];
#elif defined(SHADER_DENOISE_COMPUTE)
	layout(push_constant) uniform PushConstant {
		DenoisePushConstant pushConstant;
	};
	CameraData camera = cameras[0];
#elif defined(SHADER_RAYTRACING)
	layout(push_constant) uniform PushConstant {
		RayTracingPushConstant pushConstant;
	};
	CameraData camera = cameras[pushConstant.cameraIndex];
#elif defined(SHADER_ATMOSPHERE)
	layout(push_constant) uniform PushConstant {
		RasterAtmospherePushConstant pushConstant;
	};
	CameraData camera = cameras[pushConstant.cameraIndex];
#elif defined(SHADER_FSR)
	layout(push_constant) uniform PushConstant {
		FSRPushConstant pushConstant;
	};
	CameraData camera = cameras[0];
#else
	CameraData camera = cameras[0];
#endif

#if defined(SHADER_VERT) || defined(SHADER_FRAG) || defined(SHADER_TESC) || defined(SHADER_TESE)
	// Rasterization pipeline
	#if defined(SHADER_VERT)
		#define VERTEX_INDEX_VALUE gl_VertexIndex
		#define AABB_INDEX_VALUE gl_VertexIndex
		#ifdef SHADER_FIRST_VISIBILITY_PASS
			#define INSTANCE_GEOMETRY_INDEX (pushConstant.renderableInstanceIndex << 12 | pushConstant.geometryIndex)
			#define INSTANCE_INDEX_VALUE pushConstant.renderableInstanceIndex
			#define GEOMETRY_INDEX_VALUE pushConstant.geometryIndex
			#define MODELVIEW pushConstant.modelViewMatrix
			#define MODELVIEW_HISTORY transpose(mat4(pushConstant.historyModelViewMatrix))
			#define MVP (camera.projectionMatrix * MODELVIEW)
			#define MVP_AA (camera.projectionMatrixWithTXAA * MODELVIEW)
			#define MVP_HISTORY (camera.projectionMatrix * MODELVIEW_HISTORY)
			#define MODELVIEWNORMAL inverse(transpose(mat3(pushConstant.modelViewMatrix)))
		#else
			#define INSTANCE_GEOMETRY_INDEX 0
			#define INSTANCE_INDEX_VALUE 0
			#define GEOMETRY_INDEX_VALUE 0
		#endif
	#else
		#ifdef SHADER_FIRST_VISIBILITY_PASS
			#define INSTANCE_GEOMETRY_INDEX (pushConstant.renderableInstanceIndex << 12 | pushConstant.geometryIndex)
			#define INSTANCE_INDEX_VALUE pushConstant.renderableInstanceIndex
			#define GEOMETRY_INDEX_VALUE pushConstant.geometryIndex
			#define MODELVIEW pushConstant.modelViewMatrix
			#define MODELVIEW_HISTORY transpose(mat4(pushConstant.historyModelViewMatrix))
			#define MVP (camera.projectionMatrix * MODELVIEW)
			#define MVP_AA (camera.projectionMatrixWithTXAA * MODELVIEW)
			#define MVP_HISTORY (camera.projectionMatrix * MODELVIEW_HISTORY)
			#define MODELVIEWNORMAL inverse(transpose(mat3(pushConstant.modelViewMatrix)))
			#define AABB_INDEX_VALUE gl_PrimitiveID
			#ifdef SHADER_TOPOLOGY_QUADS
				#define VERTEX_INDEX_VALUE (gl_PrimitiveID*4)
			#else
				#define VERTEX_INDEX_VALUE (gl_PrimitiveID*3)
			#endif
		#else
			#if defined(SHADER_ATMOSPHERE)
				#define INSTANCE_GEOMETRY_INDEX pushConstant.celestialInstanceIndex
				#define INSTANCE_INDEX_VALUE pushConstant.celestialInstanceIndex
				#define GEOMETRY_INDEX_VALUE 0
				#define VERTEX_INDEX_VALUE 0
				#define AABB_INDEX_VALUE 0
			#elif defined(SHADER_LIGHTING_PASS) || defined(SHADER_COMPOSITE_PASS)
				#define INSTANCE_GEOMETRY_INDEX subpassLoad(in_img_index).r
				#define INSTANCE_INDEX_VALUE (subpassLoad(in_img_index).r >> 12)
				#define GEOMETRY_INDEX_VALUE (subpassLoad(in_img_index).r & 4095)
				#define VERTEX_INDEX_VALUE subpassLoad(in_img_index).g
				#define AABB_INDEX_VALUE subpassLoad(in_img_index).g
			#else
				#define INSTANCE_GEOMETRY_INDEX 0
				#define INSTANCE_INDEX_VALUE 0
				#define GEOMETRY_INDEX_VALUE 0
				#define VERTEX_INDEX_VALUE 0
				#define AABB_INDEX_VALUE 0
			#endif
		#endif
	#endif
#else
	// Ray-tracing pipeline
	#if defined(SHADER_RCHIT) || defined(SHADER_RAHIT) || defined(SHADER_RINT)
		#define MODELVIEW mat4(gl_ObjectToWorldEXT)
		#define MVP (camera.projectionMatrix * MODELVIEW)
		#define MVP_AA (camera.projectionMatrixWithTXAA * MODELVIEW)
		#define MVP_HISTORY (camera.projectionMatrix * MODELVIEW_HISTORY)
		#define INSTANCE_GEOMETRY_INDEX imageLoad(img_index, gl_LaunchSizeEXT.xy).r
		#define INSTANCE_INDEX_VALUE gl_InstanceCustomIndexEXT
		#define GEOMETRY_INDEX_VALUE gl_GeometryIndexEXT
		#ifdef SHADER_TOPOLOGY_QUADS
			#define VERTEX_INDEX_VALUE (gl_PrimitiveID*4)
		#else
			#define VERTEX_INDEX_VALUE (gl_PrimitiveID*3)
		#endif
		#define AABB_INDEX_VALUE gl_PrimitiveID
	#else // geometry and compute shaders
		#define MODELVIEW mat4(1)
		#define INSTANCE_GEOMETRY_INDEX 0
		#define INSTANCE_INDEX_VALUE 0
		#define GEOMETRY_INDEX_VALUE 0
		#define VERTEX_INDEX_VALUE 0
		#define AABB_INDEX_VALUE 0
	#endif
#endif

#if defined(SHADER_RGEN) || defined(SHADER_RMISS) || defined(SHADER_RCHIT) || defined(SHADER_RAHIT) || defined(SHADER_RINT) || defined(SHADER_RCALL)
	#extension GL_EXT_ray_tracing : require
	#extension GL_EXT_ray_query : enable
#endif

#ifdef SHADER_RAYTRACING
	#define RAY_PAYLOAD_VISIBILITY 0
	struct RayPayload {
		vec3 position;
		float totalDistanceFromEye;
		vec3 normal;
		float fresnel;
		vec4 color;
		vec3 emission;
		float hitDistance;
		vec2 pbr;
		uvec2 index;
		vec3 vertexPosition;
		uint tlasInstanceIndex;
		vec3 bump;
		float iOR;
	};
	#define RAY_PAYLOAD_FOG 1
	struct FogRayPayload {
		vec4 fog;
		vec4 emission;
		float opaqueDepth;
		float fogDepth;
	};
	#define RAY_PAYLOAD_LIGHT 2
	const int NB_LIGHTS = 16;
	struct LightRayPayload {
		vec4 positions[NB_LIGHTS];
		uint32_t lights[NB_LIGHTS];
		uint32_t nbLights;
	};
	#define RAY_PAYLOAD_SHADOW 3
	struct ShadowRayPayload {
		float opacity;
	};
	#ifdef SHADER_RGEN
		layout(location = RAY_PAYLOAD_VISIBILITY) rayPayloadEXT RayPayload ray;
		layout(location = RAY_PAYLOAD_FOG) rayPayloadEXT FogRayPayload fogRay;
		layout(location = RAY_PAYLOAD_LIGHT) rayPayloadEXT LightRayPayload lightRay;
		layout(location = RAY_PAYLOAD_SHADOW) rayPayloadEXT ShadowRayPayload shadowRay;
	#endif
	#if defined(SHADER_RCHIT) || defined(SHADER_RAHIT) || defined(SHADER_RMISS)
		layout(location = RAY_PAYLOAD_VISIBILITY) rayPayloadInEXT RayPayload ray;
		layout(location = RAY_PAYLOAD_FOG) rayPayloadInEXT FogRayPayload fogRay;
		layout(location = RAY_PAYLOAD_LIGHT) rayPayloadInEXT LightRayPayload lightRay;
		layout(location = RAY_PAYLOAD_SHADOW) rayPayloadInEXT ShadowRayPayload shadowRay;
	#endif
#endif

#define DECLARE_DEFAULT_VISIBILITY_FRAGMENT_OUTPUT \
	layout(location = 0) out vec4 out_color;\
	layout(location = 1) out vec4 out_normalAndFresnel;\
	layout(location = 2) out vec2 out_pbr;\
	layout(location = 3) out uvec2 out_index;\
	layout(location = 4) out vec4 out_motion;\
	layout(location = 5) out vec4 out_emission;\
	layout(location = 6) out float out_depth;\

// LightSource Instance
LightSourceInstanceData GetLightSourceInstance(uint32_t lightSourceID) {
	uint32_t instanceIndex = lightSourceID >> 12;
	uint32_t lightIndex = lightSourceID & 4095;
	return LightSourceInstances(renderableInstances[instanceIndex].instanceBufferPtr)[lightIndex].lightSourceInstance;
}

// Celestial Instance
CelestialInstanceData GetCelestialInstance(uint32_t celestialID) {
	uint32_t instanceIndex = celestialID >> 12;
	uint32_t index = celestialID & 4095;
	return CelestialInstanceData(renderableInstances[instanceIndex].instanceBufferPtr)[index];
}

vec4 GetTexture(in sampler2D tex, in vec2 coords, in float t) {
	const uvec2 texSize = textureSize(tex, 0).st;
	const float resolutionRatio = min(texSize.s, texSize.t) / (max(camera.width, camera.height) / camera.renderScale);
	return textureLod(nonuniformEXT(tex), coords, pow(t,0.5) * resolutionRatio - 0.5);
}

vec4 ApplyTexture(in uint index, in vec2 uv) {
	if (index != 0) {
		#if defined(SHADER_RAYTRACING) && (defined(SHADER_RCHIT) || defined(SHADER_RAHIT) || defined(SHADER_RMISS))
			return GetTexture(textures[nonuniformEXT(index)], uv, ray.totalDistanceFromEye);
		#else
			return texture(textures[nonuniformEXT(index)], uv);
		#endif
	} else return vec4(0);
}

vec4 ApplyTexture(in sampler2D tex, in vec2 uv) {
	#if defined(SHADER_RAYTRACING) && (defined(SHADER_RCHIT) || defined(SHADER_RAHIT) || defined(SHADER_RMISS))
		return GetTexture(tex, uv, ray.totalDistanceFromEye);
	#else
		return texture(tex, uv);
	#endif
}

vec3 ApplyNormalMap(in uint index, in vec3 normal, in vec4 tangent, in vec2 uv) {
	vec3 bitangent = cross(tangent.xyz, normal.xyz) * tangent.w;
	mat3 TBN = mat3(tangent.xyz, bitangent.xyz, normal.xyz);
	return normalize(TBN * normalize(ApplyTexture(index, uv).xyz * 2 - 1));
}

#if defined(SHADER_VERT) || defined(SHADER_GEOM) || defined(SHADER_FRAG) || defined(SHADER_RCHIT) || defined(SHADER_RAHIT) || defined(SHADER_RINT) || defined(SHADER_TESC) || defined(SHADER_TESE)

	// Renderable Instance
	RenderableInstanceData GetRenderableInstance() {
		return renderableInstances[INSTANCE_INDEX_VALUE];
	}

	// Geometry Instance
	GeometryInstanceData GetGeometryInstance() {
		return GeometryInstanceData(GetRenderableInstance().instanceBufferPtr)[GEOMETRY_INDEX_VALUE];
	}
	
	// Procedural Geometry
	ProceduralGeometryData GetProceduralGeometry() {
		return ProceduralGeometryData(GetRenderableInstance().instanceBufferPtr)[AABB_INDEX_VALUE];
	}
	
	// LightSource Instance
	LightSourceInstanceData GetLightSourceInstance() {
		return LightSourceInstances(GetRenderableInstance().instanceBufferPtr)[GEOMETRY_INDEX_VALUE].lightSourceInstance;
	}
	uint32_t GetLightSourceID() {
		return (INSTANCE_INDEX_VALUE << 12) | GEOMETRY_INDEX_VALUE;
	}
 
	// Celestial Instance
	CelestialInstanceData GetCelestialInstance() {
		return CelestialInstanceData(GetRenderableInstance().instanceBufferPtr)[GEOMETRY_INDEX_VALUE];
	}
	uint32_t GetCelestialID() {
		return (INSTANCE_INDEX_VALUE << 12) | GEOMETRY_INDEX_VALUE;
	}
 
	// Shared Geometry
	SharedGeometryData GetSharedGeometry() {
		return SharedGeometryData(GetGeometryInstance().geometryBufferPtr);
	}
	
	// Terrain Geometry
	TerrainGeometryData GetTerrainGeometry() {
		return TerrainGeometryData(GetGeometryInstance().geometryBufferPtr);
	}

	vec4 GetMaterialAlbedo() {
		return vec4(GetSharedGeometry().material_albedo) / 255.0;
	}

	float GetMaterialMetallic() {
		return float(GetSharedGeometry().material_metallic) / 255.0;
	}

	float GetMaterialRoughness() {
		return float(GetSharedGeometry().material_roughness) / 255.0;
	}
	
	float GetMaterialIndexOfRefraction() {
		return GetSharedGeometry().material_indexOfRefraction;
	}
	
	vec4 GetMaterialAlbedo(in vec2 uv) {
		uint index = GetSharedGeometry().material_albedoTexture;
		if (index > 0) {
			#if defined(SHADER_RCHIT) || defined(SHADER_RAHIT) || defined(SHADER_RMISS)
				vec4 tex = GetTexture(textures[nonuniformEXT(index)], uv, ray.totalDistanceFromEye);
			#else
				vec4 tex = texture(textures[nonuniformEXT(index)], uv);
			#endif
			return tex * GetMaterialAlbedo();
		} else {
			return GetMaterialAlbedo();
		}
	}
	
	vec3 GetMaterialNormal(in vec3 normal, in vec4 tangent, in vec2 uv) {
		uint index = GetSharedGeometry().material_normalTexture;
		if (index > 0 && tangent.w != 0) {
			return ApplyNormalMap(index, normal, tangent, uv);
		} else {
			return normal;
		}
	}

	vec2 GetMaterialMetallicRoughness(in vec2 uv) {
		uint index = GetSharedGeometry().material_pbrTexture;
		if (index > 0) {
			return texture(textures[nonuniformEXT(index)], uv).bg * vec2(GetMaterialMetallic(), GetMaterialRoughness());
		} else {
			return vec2(GetMaterialMetallic(), GetMaterialRoughness());
		}
	}

	bool IsValidGeometry() {
		if (GetRenderableInstance().instanceBufferPtr == 0) return false;
		if (GetGeometryInstance().geometryBufferPtr == 0) return false;
		if (GetSharedGeometry().vertexBufferPtr_f32_3 == 0) return false;
		return true;
	}

	uint32_t GetInstancedGeometryID() {
		return (uint32_t(INSTANCE_INDEX_VALUE) << 12) | uint32_t(GEOMETRY_INDEX_VALUE);
	}
	
	float GetRadiationAtTemperatureForWavelength(float temperature_kelvin, float wavelength_nm) {
		float hcltkb = 14387769.6 / (wavelength_nm * temperature_kelvin);
		float w = wavelength_nm / 1000.0;
		return 119104.2868 / (w * w * w * w * w * (exp(hcltkb) - 1.0));
	}

	vec3 GetEmissionColor(float temperatureKelvin) {
		return vec3(
			GetRadiationAtTemperatureForWavelength(temperatureKelvin, 680.0),
			GetRadiationAtTemperatureForWavelength(temperatureKelvin, 550.0),
			GetRadiationAtTemperatureForWavelength(temperatureKelvin, 440.0)
		);
	}
	
	vec3 GetEmissionColor(vec4 emission_temperature) {
		return emission_temperature.rgb + GetEmissionColor(emission_temperature.a);
	}

	vec3 GetEmissionColor() {
		return GetEmissionColor(GetGeometryInstance().emission_temperature);
	}
	
	// Index
	uint GetVertexIndex(uint offset) {
		return GetSharedGeometry().indexBufferPtr_u16 != 0? 
			uint(Indices16(GetSharedGeometry().indexBufferPtr_u16)[VERTEX_INDEX_VALUE + offset].index_u16)
			: (GetSharedGeometry().indexBufferPtr_u32 != 0? 
				Indices32(GetSharedGeometry().indexBufferPtr_u32)[VERTEX_INDEX_VALUE + offset].index_u32
				: (VERTEX_INDEX_VALUE + offset)
			)
		;
	}
	uint GetVertexIndex() {
		return GetSharedGeometry().indexBufferPtr_u16 != 0? 
			uint(Indices16(GetSharedGeometry().indexBufferPtr_u16)[VERTEX_INDEX_VALUE].index_u16)
			: (GetSharedGeometry().indexBufferPtr_u32 != 0? 
				Indices32(GetSharedGeometry().indexBufferPtr_u32)[VERTEX_INDEX_VALUE].index_u32
				: (VERTEX_INDEX_VALUE)
			)
		;
	}

	// Vertex Position
	vec3 GetVertexPosition(uint index) {
		return vec3(
			VertexPositions(GetSharedGeometry().vertexBufferPtr_f32_3)[index*3].vertex_f32_3,
			VertexPositions(GetSharedGeometry().vertexBufferPtr_f32_3)[index*3+1].vertex_f32_3,
			VertexPositions(GetSharedGeometry().vertexBufferPtr_f32_3)[index*3+2].vertex_f32_3
		);
	}

	// Normal
	bool HasVertexNormal() {
		return GetSharedGeometry().normalBufferPtr_f32_3 != 0;
	}
	vec3 GetVertexNormal(uint index) {
		return HasVertexNormal()? vec3(
			VertexNormals(GetSharedGeometry().normalBufferPtr_f32_3)[index*3].normal_f32_3,
			VertexNormals(GetSharedGeometry().normalBufferPtr_f32_3)[index*3+1].normal_f32_3,
			VertexNormals(GetSharedGeometry().normalBufferPtr_f32_3)[index*3+2].normal_f32_3
		) : vec3(0);
	}

	// Color
	bool HasVertexColor() {
		return GetSharedGeometry().colorBufferPtr_f32vec4 != 0;
	}
	vec4 GetVertexColor(uint index) {
		return HasVertexColor()? VertexColorsF32(GetSharedGeometry().colorBufferPtr_f32vec4)[index].color_f32vec4 : vec4(1);
	}

	// UV
	bool HasVertexTexCoord0() {
		return GetSharedGeometry().texCoord0BufferPtr_f32vec2 != 0;
	}
	vec2 GetVertexTexCoord0(uint index) {
		return HasVertexTexCoord0()? VertexUVs(GetSharedGeometry().texCoord0BufferPtr_f32vec2)[index].texCoord0BufferPtr_f32vec2 : vec2(0);
	}
	bool HasVertexTexCoord1() {
		return GetSharedGeometry().texCoord1BufferPtr_f32vec2 != 0;
	}
	vec2 GetVertexTexCoord1(uint index) {
		return HasVertexTexCoord1()? VertexUVs2(GetSharedGeometry().texCoord1BufferPtr_f32vec2)[index].texCoord1BufferPtr_f32vec2 : vec2(0);
	}

	// Tangents
	bool HasVertexTangent() {
		return GetSharedGeometry().tangentBufferPtr_f32vec4 != 0;
	}
	vec4 GetVertexTangent(uint index) {
		return HasVertexTangent()? VertexTangents(GetSharedGeometry().tangentBufferPtr_f32vec4)[index].tangentBufferPtr_f32vec4 : vec4(0);
	}
	
	// Terrain
	bool HasExtraBuffer() {
		return GetGeometryInstance().extraBufferPtr != 0;
	}
	TerrainExtraVertexData GetTerrainExtraVertexData(uint index) {
		return TerrainExtraVertexData(GetGeometryInstance().extraBufferPtr)[index];
	}

#endif

#if defined(SHADER_VERT) || defined(SHADER_FRAG) || defined(SHADER_TESC) || defined(SHADER_TESE) || defined(SHADER_RCHIT) || defined(SHADER_RAHIT) || defined(SHADER_GEOM)
	
	// Vertex Position
	vec3 GetVertexPosition() {
		return GetVertexPosition(GetVertexIndex());
	}

	// Normal
	vec3 GetVertexNormal() {
		return GetVertexNormal(GetVertexIndex());
	}

	// Color
	vec4 GetVertexColor() {
		return GetVertexColor(GetVertexIndex());
	}

	// UV
	vec2 GetVertexTexCoord0() {
		return GetVertexTexCoord0(GetVertexIndex());
	}
	vec2 GetVertexTexCoord1() {
		return GetVertexTexCoord1(GetVertexIndex());
	}
	
	// Tangent
	vec4 GetVertexTangent() {
		return GetVertexTangent(GetVertexIndex());
	}
	
	// Terrain
	TerrainExtraVertexData GetTerrainExtraVertexData() {
		return GetTerrainExtraVertexData(GetVertexIndex());
	}
	
#endif

#if defined(SHADER_RCHIT) || defined(SHADER_RAHIT) || defined(SHADER_RINT)
	vec3 DoubleSidedNormals(in vec3 viewSpaceNormal) {
		return -sign(dot(viewSpaceNormal, gl_WorldRayDirectionEXT)) * viewSpaceNormal;
	}
	vec3 DoubleSidedNormals(in vec3 viewSpaceNormal, in float bias) {
		return -sign(dot(viewSpaceNormal, gl_WorldRayDirectionEXT)-bias) * viewSpaceNormal;
	}
#endif

#if defined(SHADER_VERT)
	#define IMPORT_DEFAULT_FULLSCREEN_VERTEX_SHADER \
		void main() {\
			gl_Position = vec4(vec2((gl_VertexIndex << 1) & 2, 1-(gl_VertexIndex & 2)) * 2.0f -1.0f, 0.0f, 1.0f);\
		}
#endif

vec3 GetViewSpacePositionFromDepthAndUV(float depth, vec2 uv) {
	vec4 viewSpacePos = inverse(camera.projectionMatrixWithTXAA) * vec4((uv * 2 - 1), depth, 1);
	viewSpacePos.xyz /= viewSpacePos.w;
	if (depth == 0) viewSpacePos.z = camera.zFar;
	return viewSpacePos.xyz;
}

float GetDepth(vec2 uv) {
	#if defined(SHADER_FIRST_VISIBILITY_PASS) || defined(SHADER_ATMOSPHERE)
		return texture(sampler_rasterDepth, uv).r;
	#else
		return texture(sampler_rtDepth, uv).r;
	#endif
}

#if defined(SHADER_FRAG) || defined(SHADER_RAYTRACING)
	vec3 GetFragViewSpacePosition(vec2 uv) {
		return GetViewSpacePositionFromDepthAndUV(GetDepth(uv), uv);
	}
#endif

#ifdef SHADER_FRAG
	vec2 GetFragUV() {
		return gl_FragCoord.st / vec2(camera.width, camera.height);
	}
	vec3 GetFragViewSpacePosition() {
		return GetFragViewSpacePosition(GetFragUV());
	}
	vec3 GetFragSceneSpacePosition() {
		return (inverse(camera.viewMatrix) * vec4(GetFragViewSpacePosition(), 1)).xyz;
	}
#endif

float GetTrueDistanceFromDepthBuffer(float depth) {
	if (depth == 0 || depth == 1) return camera.zFar;
	return 2.0 * (camera.zFar * camera.zNear) / (camera.zNear + camera.zFar - (depth * 2.0 - 1.0) * (camera.zNear - camera.zFar));
}

float GetTrueDistanceFromDepthBuffer(float depth, uint cameraIndex) {
	CameraData camera = cameras[cameraIndex];
	if (depth == 0 || depth == 1) return camera.zFar;
	return 2.0 * (camera.zFar * camera.zNear) / (camera.zNear + camera.zFar - (depth * 2.0 - 1.0) * (camera.zNear - camera.zFar));
}

vec3 GetScreenCoordFromViewSpacePosition(vec3 viewSpacePosition) {
	vec4 coord = camera.projectionMatrixWithTXAA * vec4(viewSpacePosition, 1);
	coord.xyz /= coord.w;
	return coord.xyz * 0.5 + 0.5;
}

double GetDepthBufferFromTrueDistance(double dist) {
	if (dist <= 0) return 0;
	return (((((2.0 * (camera.zFar * camera.zNear)) / dist) - camera.zNear - camera.zFar) / (camera.zFar - camera.zNear)) + 1) / 2.0;
}

float GetFragDepthFromViewSpacePosition(vec3 viewSpacePos) {
	vec4 clipSpace = mat4(camera.projectionMatrixWithTXAA) * vec4(viewSpacePos, 1);
	return clipSpace.z / clipSpace.w;
}

bool IsNaN(mat4 mat) {
	bvec4 b0 = isnan(mat[0]);
	bvec4 b1 = isnan(mat[1]);
	bvec4 b2 = isnan(mat[2]);
	bvec4 b3 = isnan(mat[3]);
	return false
		|| b0.x || b0.y || b0.z || b0.z
		|| b1.x || b1.y || b1.z || b1.z
		|| b2.x || b2.y || b2.z || b2.z
		|| b3.x || b3.y || b3.z || b3.z
	;
}


#define RAHIT_SHADOW_RAY_OPACITY(o) {\
	shadowRay.opacity += o;\
	if (shadowRay.opacity >= 0.95) terminateRayEXT;\
	ignoreIntersectionEXT;\
}


/////////////////////
// Motion Vectors

vec3 GetMotionVector(in vec2 uv, in float depth) {
	vec4 ndc = vec4(uv * 2 - 1, depth, 1);
	vec4 ndcHistory = camera.reprojectionMatrix * ndc;
	return ndcHistory.xyz / ndcHistory.w - ndc.xyz;
}

#define RGEN_WRITE_MOTION_VECTORS {\
	uint instanceIndex = ray.index.x >> 12;\
	mat4 mvp = camera.projectionMatrix * mat4(transpose(tlasInstances[ray.tlasInstanceIndex].transform));\
	cameras[pushConstant.cameraIndex].mvpBuffer[instanceIndex].mvp = mvp;\
	cameras[pushConstant.cameraIndex].realtimeBuffer[instanceIndex].mvpFrameIndex = camera.frameIndex;\
	vec4 ndc = mvp * vec4(ray.vertexPosition, 1);\
	ndc /= ndc.w;\
	mat4 mvpHistory;\
	if (cameras[pushConstant.cameraIndex].realtimeBufferHistory[instanceIndex].mvpFrameIndex == camera.frameIndex - 1) {\
		mvpHistory = cameras[pushConstant.cameraIndex].mvpBufferHistory[instanceIndex].mvp;\
	} else {\
		mvpHistory = camera.reprojectionMatrix * mvp;\
	}\
	vec4 ndc_history = mvpHistory * vec4(ray.vertexPosition, 1);\
	ndc_history /= ndc_history.w;\
	imageStore(img_motion, imgCoords, vec4(ndc_history.xyz - ndc.xyz, 0));\
}
#define VERT_PREP_MOTION_VECTORS(_vertexPosition) {\
	out_pos = MVP * _vertexPosition;\
	out_pos_history = MVP_HISTORY * _vertexPosition;\
}
#define FRAG_WRITE_MOTION_VECTORS \
	out_index = uvec2(GetInstancedGeometryID(), VERTEX_INDEX_VALUE);\
	out_motion = vec4(\
		in_pos_history.xyz / in_pos_history.w - in_pos.xyz / in_pos.w, 0\
	);

////////////////////////

#define RCHIT_VISIBILITY_BEGIN_T(_t) {\
	ray.hitDistance = _t;\
	ray.totalDistanceFromEye += _t;\
	ray.position = gl_WorldRayOriginEXT + gl_WorldRayDirectionEXT * ray.hitDistance;\
	ray.index = uvec2(GetInstancedGeometryID(), VERTEX_INDEX_VALUE);\
	ray.vertexPosition = gl_ObjectRayOriginEXT + gl_ObjectRayDirectionEXT * ray.hitDistance;\
	ray.tlasInstanceIndex = gl_InstanceID;\
}
#define RCHIT_VISIBILITY_BEGIN RCHIT_VISIBILITY_BEGIN_T(gl_HitTEXT)
#define RCHIT_VISIBILITY_END {\
	float rDotN = dot(gl_WorldRayDirectionEXT, ray.normal);\
	if (rDotN < 0.5 && rDotN > -0.05) {\
		vec3 tmp = normalize(cross(gl_WorldRayDirectionEXT, ray.normal));\
		ray.normal = normalize(mix(-gl_WorldRayDirectionEXT, normalize(cross(-gl_WorldRayDirectionEXT, tmp)), 0.95));\
	}\
	ray.normal = DoubleSidedNormals(ray.normal);\
	ray.fresnel = Fresnel(ray.position, ray.normal, ray.iOR);\
}

#if defined(SHADER_RCHIT)
	#define AIMABLE(_aimID, _uv) {\
		if (_aimID != 0) {\
			const bool isMiddleOfScreen = ivec2(gl_LaunchIDEXT.xy) == (ivec2(gl_LaunchSizeEXT.xy) / 2);\
			if (isMiddleOfScreen) {\
				if (cameras[0].aimBuffer.aimID == 0) {\
					cameras[0].aimBuffer.aimID = _aimID;\
					cameras[0].aimBuffer.distance = ray.totalDistanceFromEye;\
					cameras[0].aimBuffer.uv = _uv;\
				}\
			}\
		}\
	}
#elif defined(SHADER_FRAG)
	#define AIMABLE(_aimID, _uv) {\
		if (_aimID != 0) {\
			const bool isMiddleOfScreen = ivec2(gl_FragCoord.xy) == (ivec2(camera.width, camera.height) / 2);\
			if (isMiddleOfScreen) {\
				if (cameras[0].aimBuffer.aimID == 0) {\
					cameras[0].aimBuffer.aimID = _aimID;\
					cameras[0].aimBuffer.distance = GetTrueDistanceFromDepthBuffer(gl_FragCoord.z / gl_FragCoord.w);\
					cameras[0].aimBuffer.uv = _uv;\
				}\
			}\
		}\
	}
#endif

/////////////////////////////// Lighting helpers /////////////////////////////////////////////////////////

const float PI = 3.141592654;
const float GOLDEN_RATIO = 1.61803398875;

float Fresnel(const vec3 position, const vec3 normal, const float indexOfRefraction) {
	vec3 incident = normalize(position);
	float cosi = clamp(dot(incident, normal), -1, 1);
	float etai;
	float etat;
	if (cosi > 0) {
		etat = 1;
		etai = indexOfRefraction;
	} else {
		etai = 1;
		etat = indexOfRefraction;
	}
	// Compute sini using Snell's law
	float sint = etai / etat * sqrt(max(0.0, 1.0 - cosi * cosi));
	if (sint >= 1) {
		// Total internal reflection
		return 1.0;
	} else {
		float cost = sqrt(max(0.0, 1.0 - sint * sint));
		cosi = abs(cosi);
		float Rs = ((etat * cosi) - (etai * cost)) / ((etat * cosi) + (etai * cost));
		float Rp = ((etai * cosi) - (etat * cost)) / ((etai * cosi) + (etat * cost));
		return (Rs * Rs + Rp * Rp) / 2;
	}
}

vec3 BasicLighting(const LightSourceInstanceData light, vec3 lightPosition, const vec3 pos, const vec3 normal, const float fresnel, const float metallic, const float roughness) {
	const vec3 lightDir = normalize(lightPosition - pos);
	const float dist = max(0.0, distance(lightPosition, pos) - light.radius);
	const float cosTheta = clamp(dot(lightDir, normal), 0, 1);
	const float diffuseScattering = max(pow(cosTheta, 1-light.diffuse), light.diffuse);
	const float attenuation = 4.0*PI*dist*dist + 1.0;
	const float diffuse = mix(mix((cosTheta + cosTheta*fresnel)*0.5, diffuseScattering, roughness), cosTheta*fresnel*roughness*roughness, metallic);
	const float intensity = max(0, light.power / attenuation * diffuse);
	return max(vec3(0), light.color * intensity - LIGHT_LUMINOSITY_VISIBLE_THRESHOLD);
}

float GetOptimalBounceStartDistance(float distance) {
	return 0.0001*distance;
}

bool ReprojectHistoryUV(inout vec2 uv) {
	uv += texture(sampler_motion, uv).rg * 0.5;
	return uv.x > 0 && uv.x < 1 && uv.y > 0 && uv.y < 1;
}

vec3 GetVariance(in sampler2D tex, in vec2 uv) {
	vec3 nearColor0 = texture(tex, uv).rgb;
	vec3 nearColor1 = textureLodOffset(tex, uv, 0.0, ivec2( 1,  0)).rgb;
	vec3 nearColor2 = textureLodOffset(tex, uv, 0.0, ivec2( 0,  1)).rgb;
	vec3 nearColor3 = textureLodOffset(tex, uv, 0.0, ivec2(-1,  0)).rgb;
	vec3 nearColor4 = textureLodOffset(tex, uv, 0.0, ivec2( 0, -1)).rgb;
	vec3 nearColor5 = textureLodOffset(tex, uv, 0.0, ivec2( 1,  1)).rgb;
	vec3 nearColor6 = textureLodOffset(tex, uv, 0.0, ivec2(-1,  1)).rgb;
	vec3 nearColor7 = textureLodOffset(tex, uv, 0.0, ivec2(-1, -1)).rgb;
	vec3 nearColor8 = textureLodOffset(tex, uv, 0.0, ivec2( 1, -1)).rgb;
	vec3 m1 = nearColor0
			+ nearColor1
			+ nearColor2
			+ nearColor3
			+ nearColor4
			+ nearColor5
			+ nearColor6
			+ nearColor7
			+ nearColor8
	; m1 /= 9;
	vec3 m2 = nearColor0*nearColor0
			+ nearColor1*nearColor1
			+ nearColor2*nearColor2
			+ nearColor3*nearColor3
			+ nearColor4*nearColor4
			+ nearColor5*nearColor5
			+ nearColor6*nearColor6
			+ nearColor7*nearColor7
			+ nearColor8*nearColor8
	; m2 /= 9;
	return sqrt(m2 - m1*m1);
}

float GetVariance(in float a, in float b) {
	float m1 = a * 0.5 + b * 0.5;
	float m2 = a*a * 0.5 + b*b * 0.5;
	return sqrt(m2 - m1*m1);
}

vec2 GetVariance(in vec2 a, in vec2 b) {
	vec2 m1 = a * 0.5 + b * 0.5;
	vec2 m2 = a*a * 0.5 + b*b * 0.5;
	return sqrt(m2 - m1*m1);
}

vec3 GetVariance(in vec3 a, in vec3 b) {
	vec3 m1 = a * 0.5 + b * 0.5;
	vec3 m2 = a*a * 0.5 + b*b * 0.5;
	return sqrt(m2 - m1*m1);
}

vec4 GetVariance(in vec4 a, in vec4 b) {
	vec4 m1 = a * 0.5 + b * 0.5;
	vec4 m2 = a*a * 0.5 + b*b * 0.5;
	return sqrt(m2 - m1*m1);
}

vec3 GetVariance(in sampler2D tex, in vec2 uv, int kernelSize) {
	float accumulation = 0;
	vec3 m1 = vec3(0);
	vec3 m2 = vec3(0);
	for (int x = -kernelSize/2; x <= +kernelSize/2; ++x) {
		for (int y = -kernelSize/2; y <= +kernelSize/2; ++y) {
			const vec2 offset = vec2(x, y) / textureSize(tex, 0);
			vec3 value = texture(tex, uv + offset).rgb;
			m1 += value;
			m2 += value*value;
			++accumulation;
		}
	}
	m1 /= accumulation;
	m2 /= accumulation;
	return sqrt(m2 - m1*m1);
}

vec3 VarianceClamp5(in vec3 color, in sampler2D tex, in vec2 uv) {
	vec3 nearColor0 = texture(tex, uv).rgb;
	vec3 nearColor1 = textureLodOffset(tex, uv, 0.0, ivec2( 1,  0)).rgb;
	vec3 nearColor2 = textureLodOffset(tex, uv, 0.0, ivec2( 0,  1)).rgb;
	vec3 nearColor3 = textureLodOffset(tex, uv, 0.0, ivec2(-1,  0)).rgb;
	vec3 nearColor4 = textureLodOffset(tex, uv, 0.0, ivec2( 0, -1)).rgb;
	vec3 m1 = nearColor0
			+ nearColor1
			+ nearColor2
			+ nearColor3
			+ nearColor4
	; m1 /= 5;
	vec3 m2 = nearColor0*nearColor0
			+ nearColor1*nearColor1
			+ nearColor2*nearColor2
			+ nearColor3*nearColor3
			+ nearColor4*nearColor4
	; m2 /= 5;
	vec3 sigma = sqrt(m2 - m1*m1);
	vec3 boxMin = m1 - sigma;
	vec3 boxMax = m1 + sigma;
	return clamp(color, boxMin, boxMax);
}

vec3 VarianceClamp9(in vec3 color, in sampler2D tex, in vec2 uv) {
	vec3 nearColor0 = texture(tex, uv).rgb;
	vec3 nearColor1 = textureLodOffset(tex, uv, 0.0, ivec2( 1,  0)).rgb;
	vec3 nearColor2 = textureLodOffset(tex, uv, 0.0, ivec2( 0,  1)).rgb;
	vec3 nearColor3 = textureLodOffset(tex, uv, 0.0, ivec2(-1,  0)).rgb;
	vec3 nearColor4 = textureLodOffset(tex, uv, 0.0, ivec2( 0, -1)).rgb;
	vec3 nearColor5 = textureLodOffset(tex, uv, 0.0, ivec2( 1,  1)).rgb;
	vec3 nearColor6 = textureLodOffset(tex, uv, 0.0, ivec2(-1,  1)).rgb;
	vec3 nearColor7 = textureLodOffset(tex, uv, 0.0, ivec2(-1, -1)).rgb;
	vec3 nearColor8 = textureLodOffset(tex, uv, 0.0, ivec2( 1, -1)).rgb;
	vec3 m1 = nearColor0
			+ nearColor1
			+ nearColor2
			+ nearColor3
			+ nearColor4
			+ nearColor5
			+ nearColor6
			+ nearColor7
			+ nearColor8
	; m1 /= 9;
	vec3 m2 = nearColor0*nearColor0
			+ nearColor1*nearColor1
			+ nearColor2*nearColor2
			+ nearColor3*nearColor3
			+ nearColor4*nearColor4
			+ nearColor5*nearColor5
			+ nearColor6*nearColor6
			+ nearColor7*nearColor7
			+ nearColor8*nearColor8
	; m2 /= 9;
	vec3 sigma = sqrt(m2 - m1*m1);
	vec3 boxMin = m1 - sigma;
	vec3 boxMax = m1 + sigma;
	return clamp(color, boxMin, boxMax);
}

vec3 VarianceMax(in vec3 color, in sampler2D tex, in vec2 uv) {
	vec3 nearColor0 = texture(tex, uv).rgb;
	vec3 nearColor1 = textureLodOffset(tex, uv, 0.0, ivec2( 1,  0)).rgb;
	vec3 nearColor2 = textureLodOffset(tex, uv, 0.0, ivec2( 0,  1)).rgb;
	vec3 nearColor3 = textureLodOffset(tex, uv, 0.0, ivec2(-1,  0)).rgb;
	vec3 nearColor4 = textureLodOffset(tex, uv, 0.0, ivec2( 0, -1)).rgb;
	vec3 nearColor5 = textureLodOffset(tex, uv, 0.0, ivec2( 1,  1)).rgb;
	vec3 nearColor6 = textureLodOffset(tex, uv, 0.0, ivec2(-1,  1)).rgb;
	vec3 nearColor7 = textureLodOffset(tex, uv, 0.0, ivec2(-1, -1)).rgb;
	vec3 nearColor8 = textureLodOffset(tex, uv, 0.0, ivec2( 1, -1)).rgb;
	vec3 m1 = nearColor0
			+ nearColor1
			+ nearColor2
			+ nearColor3
			+ nearColor4
			+ nearColor5
			+ nearColor6
			+ nearColor7
			+ nearColor8
	; m1 /= 9;
	vec3 m2 = nearColor0*nearColor0
			+ nearColor1*nearColor1
			+ nearColor2*nearColor2
			+ nearColor3*nearColor3
			+ nearColor4*nearColor4
			+ nearColor5*nearColor5
			+ nearColor6*nearColor6
			+ nearColor7*nearColor7
			+ nearColor8*nearColor8
	; m2 /= 9;
	vec3 sigma = sqrt(m2 - m1*m1);
	vec3 boxMax = m1 + sigma;
	return clamp(color, vec3(0), boxMax);
}

vec3 VarianceClamp(in vec3 color, in sampler2D tex, in vec2 uv, int kernelSize) {
	const vec2 size = textureSize(tex, 0);
	float accumulation = 0;
	vec3 m1 = vec3(0);
	vec3 m2 = vec3(0);
	for (int x = -kernelSize/2; x <= +kernelSize/2; ++x) {
		for (int y = -kernelSize/2; y <= +kernelSize/2; ++y) {
			const vec2 offset = vec2(x, y) / size;
			vec3 value = texture(tex, uv + offset).rgb;
			m1 += value;
			m2 += value*value;
			++accumulation;
		}
	}
	m1 /= accumulation;
	m2 /= accumulation;
	vec3 sigma = sqrt(m2 - m1*m1);
	vec3 boxMin = m1 - sigma;
	vec3 boxMax = m1 + sigma;
	return clamp(color, boxMin, boxMax);
}

vec4 TextureBlurred(in sampler2D tex, in vec2 uv) {
	vec4 color = texture(tex, uv);
	color += textureLodOffset(tex, uv, 0.0, ivec2( 1,  0));
	color += textureLodOffset(tex, uv, 0.0, ivec2( 0,  1));
	color += textureLodOffset(tex, uv, 0.0, ivec2(-1,  0));
	color += textureLodOffset(tex, uv, 0.0, ivec2( 0, -1));
	color += textureLodOffset(tex, uv, 0.0, ivec2( 1,  1));
	color += textureLodOffset(tex, uv, 0.0, ivec2(-1,  1));
	color += textureLodOffset(tex, uv, 0.0, ivec2(-1, -1));
	color += textureLodOffset(tex, uv, 0.0, ivec2( 1, -1));
	return color / 9;
}

vec4 TextureBlurred(in sampler2D tex, in vec2 uv, int kernelSize) {
	const vec2 size = textureSize(tex, 0);
	vec4 color = texture(tex, uv);
	float accumulation = 1;
	for (int x = -kernelSize/2; x <= +kernelSize/2; ++x) {
		for (int y = -kernelSize/2; y <= +kernelSize/2; ++y) {
			const vec2 offset = vec2(x, y) / size;
			color += texture(tex, uv + offset);
			++accumulation;
		}
	}
	return color / accumulation;
}

vec4 TextureBlurred(in samplerCube tex, in vec3 p) {
	const float size = textureSize(tex, 0).x * 0.5;
	vec4 color = texture(tex, p) * 0.4;
	color += texture(tex, p + vec3(1,0,0)/size) * 0.1;
	color += texture(tex, p + vec3(0,1,0)/size) * 0.1;
	color += texture(tex, p + vec3(0,0,1)/size) * 0.1;
	color += texture(tex, p + vec3(-1,0,0)/size) * 0.1;
	color += texture(tex, p + vec3(0,-1,0)/size) * 0.1;
	color += texture(tex, p + vec3(0,0,-1)/size) * 0.1;
	return color;
}

float GetDepthBlurred(vec2 uv) {
	#if defined(SHADER_FIRST_VISIBILITY_PASS) || defined(SHADER_ATMOSPHERE)
		return TextureBlurred(sampler_rasterDepth, uv).r;
	#else
		return TextureBlurred(sampler_rtDepth, uv).r;
	#endif
}

vec4 ImageBlurred(in image2D img, in ivec2 coord, int kernelSize) {
	const ivec2 size = imageSize(img).xy;
	float accumulation = 0;
	vec4 color = vec4(0);
	for (int x = -kernelSize/2; x <= +kernelSize/2; ++x) {
		for (int y = -kernelSize/2; y <= +kernelSize/2; ++y) {
			ivec2 xy = coord + ivec2(x,y);
			if (xy.x < 0 || xy.y < 0 || xy.x >= size.x || xy.y >= size.y) continue;
			color += imageLoad(img, xy);
			++accumulation;
		}
	}
	return color / accumulation;
}

vec4 ImageBlurred(in image2D img, in ivec2 coord) {
	return ImageBlurred(img, coord, 3);
}

vec3 TextureSharp(in sampler2D tex, in vec2 uv, float strength) {
	vec2 renderSize = textureSize(tex, 0);
	float dx = 1.0 / renderSize.x;
	float dy = 1.0 / renderSize.y;
	vec3 sum = vec3(0.0);
	sum += -strength * texture(tex, uv + vec2( -1.0 * dx , 0.0 * dy)).rgb;
	sum += -strength * texture(tex, uv + vec2( 0.0 * dx , -1.0 * dy)).rgb;
	sum += (1.0 + 4.0*strength) * texture(tex, uv + vec2( 0.0 * dx , 0.0 * dy)).rgb;
	sum += -strength * texture(tex, uv + vec2( 0.0 * dx , 1.0 * dy)).rgb;
	sum += -strength * texture(tex, uv + vec2( 1.0 * dx , 0.0 * dy)).rgb;
	return sum;
}

vec3 TextureSharp(in sampler2D tex, in vec2 uv) {
	return TextureSharp(tex, uv, 0.5);
}

vec3 Heatmap(float t) {
	if (t <= 0) return vec3(0);
	if (t >= 1) return vec3(1);
	const vec3 c[10] = {
		vec3(0.0f / 255.0f,   2.0f / 255.0f,  91.0f / 255.0f),
		vec3(0.0f / 255.0f, 108.0f / 255.0f, 251.0f / 255.0f),
		vec3(0.0f / 255.0f, 221.0f / 255.0f, 221.0f / 255.0f),
		vec3(51.0f / 255.0f, 221.0f / 255.0f,   0.0f / 255.0f),
		vec3(255.0f / 255.0f, 252.0f / 255.0f,   0.0f / 255.0f),
		vec3(255.0f / 255.0f, 180.0f / 255.0f,   0.0f / 255.0f),
		vec3(255.0f / 255.0f, 104.0f / 255.0f,   0.0f / 255.0f),
		vec3(226.0f / 255.0f,  22.0f / 255.0f,   0.0f / 255.0f),
		vec3(191.0f / 255.0f,   0.0f / 255.0f,  83.0f / 255.0f),
		vec3(145.0f / 255.0f,   0.0f / 255.0f,  65.0f / 255.0f)
	};

	const float s = t * 10.0f;

	const int cur = int(s) <= 9 ? int(s) : 9;
	const int prv = cur >= 1 ? cur - 1 : 0;
	const int nxt = cur < 9 ? cur + 1 : 9;

	const float blur = 0.8f;

	const float wc = smoothstep(float(cur) - blur, float(cur) + blur, s) * (1.0f - smoothstep(float(cur + 1) - blur, float(cur + 1) + blur, s));
	const float wp = 1.0f - smoothstep(float(cur) - blur, float(cur) + blur, s);
	const float wn = smoothstep(float(cur + 1) - blur, float(cur + 1) + blur, s);

	const vec3 r = wc * c[cur] + wp * c[prv] + wn * c[nxt];
	return vec3(clamp(r.x, 0.0f, 1.0f), clamp(r.y, 0.0f, 1.0f), clamp(r.z, 0.0f, 1.0f));
}

vec4 SumOne(vec4 blending) {
	float total = blending.x + blending.y + blending.z + blending.w;
	if (total == 0) return vec4(1,0,0,0);
	return blending / total;
}


vec3 ApplyToneMapping(in vec3 in_color) {
	vec3 color = in_color;
	
	float exposure = camera.luminance.a / (camera.luminance.r + camera.luminance.g + camera.luminance.b);
	
	// HDR ToneMapping (Reinhard)
	if ((camera.options & RENDER_OPTION_HDR) != 0) {
		if ((camera.debug & RENDER_DEBUG_HDR_FULL_RANGE) != 0) {
			// Full range Exposure
			color.rgb = vec3(1.0) - exp(-color.rgb * exposure);
		} else {
			// Human Eye Exposure
			color.rgb = vec3(1.0) - exp(-color.rgb * clamp(exposure, 0.00001, 1000.0));
		}
	}
	
	// Contrast / Brightness
	if (camera.contrast != 1.0 || camera.brightness != 1.0) {
		color.rgb = mix(vec3(0.5), color.rgb, camera.contrast) * camera.brightness;
	}
	
	// Gamma correction
	if ((camera.options & RENDER_OPTION_GAMMA) != 0) {
		color.rgb = pow(color.rgb, vec3(1.0 / camera.gamma));
	}
	
	return color;
}

//////////////////////////// Random helpers //////////////////////////////////////////////////////////

#extension GL_EXT_control_flow_attributes : require
uint InitRandomSeed(uint val0, uint val1) {
	uint v0 = val0, v1 = val1, s0 = 0;
	[[unroll]]
	for (uint n = 0; n < 16; n++) {
		s0 += 0x9e3779b9;
		v0 += ((v1 << 4) + 0xa341316c) ^ (v1 + s0) ^ ((v1 >> 5) + 0xc8013ea4);
		v1 += ((v0 << 4) + 0xad90777d) ^ (v0 + s0) ^ ((v0 >> 5) + 0x7e95761e);
	}
	return v0;
}
uint RandomInt(inout uint seed) {
	return (seed = 1664525 * seed + 1013904223);
}
float RandomFloat(inout uint seed) {
	return (float(RandomInt(seed) & 0x00FFFFFF) / float(0x01000000));
}
vec2 RandomInUnitSquare(inout uint seed) {
	return 2 * vec2(RandomFloat(seed), RandomFloat(seed)) - 1;
}
vec2 RandomInUnitDisk(inout uint seed) {
	for (;;) {
		const vec2 p = 2 * vec2(RandomFloat(seed), RandomFloat(seed)) - 1;
		if (dot(p, p) < 1) {
			return p;
		}
	}
}
vec3 RandomInUnitSphere(inout uint seed) {
	for (;;) {
		const vec3 p = 2 * vec3(RandomFloat(seed), RandomFloat(seed), RandomFloat(seed)) - 1;
		if (dot(p, p) < 1) {
			return p;
		}
	}
}

vec2 RotateUV(vec2 uv, float rotation) {
	vec2 mid = vec2(0.5);
	float cosAngle = cos(rotation);
	float sinAngle = sin(rotation);
	return vec2(
		cosAngle * (uv.x - mid.x) + sinAngle * (uv.y - mid.y) + mid.x,
		cosAngle * (uv.y - mid.y) - sinAngle * (uv.x - mid.x) + mid.y
	);
}

const vec2 BlueNoiseInDisk[64] = vec2[64](
	vec2(0.478712,0.875764),
	vec2(-0.337956,-0.793959),
	vec2(-0.955259,-0.028164),
	vec2(0.864527,0.325689),
	vec2(0.209342,-0.395657),
	vec2(-0.106779,0.672585),
	vec2(0.156213,0.235113),
	vec2(-0.413644,-0.082856),
	vec2(-0.415667,0.323909),
	vec2(0.141896,-0.939980),
	vec2(0.954932,-0.182516),
	vec2(-0.766184,0.410799),
	vec2(-0.434912,-0.458845),
	vec2(0.415242,-0.078724),
	vec2(0.728335,-0.491777),
	vec2(-0.058086,-0.066401),
	vec2(0.202990,0.686837),
	vec2(-0.808362,-0.556402),
	vec2(0.507386,-0.640839),
	vec2(-0.723494,-0.229240),
	vec2(0.489740,0.317826),
	vec2(-0.622663,0.765301),
	vec2(-0.010640,0.929347),
	vec2(0.663146,0.647618),
	vec2(-0.096674,-0.413835),
	vec2(0.525945,-0.321063),
	vec2(-0.122533,0.366019),
	vec2(0.195235,-0.687983),
	vec2(-0.563203,0.098748),
	vec2(0.418563,0.561335),
	vec2(-0.378595,0.800367),
	vec2(0.826922,0.001024),
	vec2(-0.085372,-0.766651),
	vec2(-0.921920,0.183673),
	vec2(-0.590008,-0.721799),
	vec2(0.167751,-0.164393),
	vec2(0.032961,-0.562530),
	vec2(0.632900,-0.107059),
	vec2(-0.464080,0.569669),
	vec2(-0.173676,-0.958758),
	vec2(-0.242648,-0.234303),
	vec2(-0.275362,0.157163),
	vec2(0.382295,-0.795131),
	vec2(0.562955,0.115562),
	vec2(0.190586,0.470121),
	vec2(0.770764,-0.297576),
	vec2(0.237281,0.931050),
	vec2(-0.666642,-0.455871),
	vec2(-0.905649,-0.298379),
	vec2(0.339520,0.157829),
	vec2(0.701438,-0.704100),
	vec2(-0.062758,0.160346),
	vec2(-0.220674,0.957141),
	vec2(0.642692,0.432706),
	vec2(-0.773390,-0.015272),
	vec2(-0.671467,0.246880),
	vec2(0.158051,0.062859),
	vec2(0.806009,0.527232),
	vec2(-0.057620,-0.247071),
	vec2(0.333436,-0.516710),
	vec2(-0.550658,-0.315773),
	vec2(-0.652078,0.589846),
	vec2(0.008818,0.530556),
	vec2(-0.210004,0.519896) 
);

vec4 GetBlueNoise(uvec2 pixelCoord, uint64_t texIndex) {
	const uint NOISE_TEXTURES_OFFSET = 1;
	const uint NB_NOISE_TEXTURES = 64;
	uint noiseTexIndex = uint(texIndex % NB_NOISE_TEXTURES);
	vec2 texSize = vec2(textureSize(textures[nonuniformEXT(noiseTexIndex+NOISE_TEXTURES_OFFSET)], 0).st);
	vec2 noiseTexCoord = (vec2(pixelCoord) + 0.5) / texSize;
	return texture(textures[nonuniformEXT(noiseTexIndex+NOISE_TEXTURES_OFFSET)], noiseTexCoord);
}

vec4 GetBlueNoise(vec2 uv, uint64_t texIndex) {
	const uint NOISE_TEXTURES_OFFSET = 1;
	const uint NB_NOISE_TEXTURES = 64;
	uint noiseTexIndex = uint(texIndex % NB_NOISE_TEXTURES);
	return texture(textures[nonuniformEXT(noiseTexIndex+NOISE_TEXTURES_OFFSET)], uv);
}

vec3 _random3(vec3 pos) { // used in FastSimplex
	float j = 4096.0*sin(dot(pos,vec3(17.0, 59.4, 15.0)));
	vec3 r;
	r.z = fract(512.0*j);
	j *= .125;
	r.x = fract(512.0*j);
	j *= .125;
	r.y = fract(512.0*j);
	return r-0.5;
}
float FastSimplex(vec3 pos) {
	const float F3 = 0.3333333;
	const float G3 = 0.1666667;

	vec3 s = floor(pos + dot(pos, vec3(F3)));
	vec3 x = pos - s + dot(s, vec3(G3));

	vec3 e = step(vec3(0.0), x - x.yzx);
	vec3 i1 = e * (1.0 - e.zxy);
	vec3 i2 = 1.0 - e.zxy * (1.0 - e);

	vec3 x1 = x - i1 + G3;
	vec3 x2 = x - i2 + 2.0 * G3;
	vec3 x3 = x - 1.0 + 3.0 * G3;

	vec4 w, d;

	w.x = dot(x, x);
	w.y = dot(x1, x1);
	w.z = dot(x2, x2);
	w.w = dot(x3, x3);

	w = max(0.6 - w, 0.0);

	d.x = dot(_random3(s), x);
	d.y = dot(_random3(s + i1), x1);
	d.z = dot(_random3(s + i2), x2);
	d.w = dot(_random3(s + 1.0), x3);

	w *= w;
	w *= w;
	d *= w;

	return (dot(d, vec4(52.0)));
}
float FastSimplexFractal(vec3 pos, int octaves) {
	float amplitude = 0.5333333333;
	float frequency = 1.0;
	float f = FastSimplex(pos * frequency);
	for (int i = 1; i < octaves; ++i) {
		amplitude /= 2.0;
		frequency *= 2.0;
		f += amplitude * FastSimplex(pos * frequency);
	}
	return f;
}
float GrainyNoise(vec3 pos) {
	return clamp(FastSimplexFractal(pos*500, 2)/2+.5, 0, 1);
}

mat3 RotationMatrix(vec3 axis, float angle) {
	axis = normalize(axis);
	float s = sin(angle);
	float c = cos(angle);
	float oc = 1.0 - c;
	return mat3(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,
				oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,
				oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c);
}

// Triplanar Functions
vec3 TriplanarBlending(vec3 norm, float sharpness) {
	vec3 blending = abs(norm);
	blending = normalize(max(blending, 0.00001));
	blending = pow(blending, vec3(sharpness));
	float b = blending.x + blending.y + blending.z;
	blending /= vec3(b);
	if (blending.x > 0.9) blending = vec3(1,0,0);
	if (blending.y > 0.9) blending = vec3(0,1,0);
	if (blending.z > 0.9) blending = vec3(0,0,1);
	return blending;
}
vec4 TriplanarTextureRGBA(sampler2D tex, vec3 coords, vec3 blending) {
	vec4 value = vec4(0);
	if (blending.x > 0) value += blending.x * ApplyTexture( tex, coords.zy);
	if (blending.y > 0) value += blending.y * ApplyTexture( tex, coords.xz);
	if (blending.z > 0) value += blending.z * ApplyTexture( tex, coords.xy);
	return value;
}
vec3 TriplanarTextureRGB(sampler2D tex, vec3 coords, vec3 blending) {
	vec3 value = vec3(0);
	if (blending.x > 0) value += blending.x * ApplyTexture( tex, coords.zy).rgb;
	if (blending.y > 0) value += blending.y * ApplyTexture( tex, coords.xz).rgb;
	if (blending.z > 0) value += blending.z * ApplyTexture( tex, coords.xy).rgb;
	return value;
}
float TriplanarTextureR(sampler2D tex, vec3 coords, vec3 blending) {
	float value = 0;
	if (blending.x > 0) value += blending.x * ApplyTexture( tex, coords.zy).r;
	if (blending.y > 0) value += blending.y * ApplyTexture( tex, coords.xz).r;
	if (blending.z > 0) value += blending.z * ApplyTexture( tex, coords.xy).r;
	return value;
}
float TriplanarTextureA(sampler2D tex, vec3 coords, vec3 blending) {
	float value = 0;
	if (blending.x > 0) value += blending.x * ApplyTexture( tex, coords.zy).a;
	if (blending.y > 0) value += blending.y * ApplyTexture( tex, coords.xz).a;
	if (blending.z > 0) value += blending.z * ApplyTexture( tex, coords.xy).a;
	return value;
}
vec3 TriplanarLocalNormalMap(sampler2D normalTex, vec3 coords, vec3 normal, vec3 blending) {
	if (blending.x > 0) normal += blending.x * vec3(0, ApplyTexture( normalTex, coords.zy).yx * 2 - 1);
	if (blending.y > 0) normal += blending.y * vec3(1,0,1) * (ApplyTexture( normalTex, coords.xz).xzy * 2 - 1);
	if (blending.z > 0) normal += blending.z * vec3(ApplyTexture( normalTex, coords.xy).xy * 2 - 1, 0);
	return normalize(normal);
}
vec4 TriplanarTextureRGBA(uint texIndex, vec3 coords, vec3 blending) {
	if (texIndex == 0) return vec4(0);
	#ifdef SHADER_RAYTRACING
		return TriplanarTextureRGBA(textures[nonuniformEXT(texIndex)], coords, blending);
	#else
		return TriplanarTextureRGBA(textures[texIndex], coords, blending);
	#endif
}
vec3 TriplanarTextureRGB(uint texIndex, vec3 coords, vec3 blending) {
	if (texIndex == 0) return vec3(0);
	#ifdef SHADER_RAYTRACING
		return TriplanarTextureRGB(textures[nonuniformEXT(texIndex)], coords, blending);
	#else
		return TriplanarTextureRGB(textures[texIndex], coords, blending);
	#endif
}
float TriplanarTextureR(uint texIndex, vec3 coords, vec3 blending) {
	if (texIndex == 0) return 0;
	#ifdef SHADER_RAYTRACING
		return TriplanarTextureR(textures[nonuniformEXT(texIndex)], coords, blending);
	#else
		return TriplanarTextureR(textures[texIndex], coords, blending);
	#endif
}
float TriplanarTextureA(uint texIndex, vec3 coords, vec3 blending) {
	if (texIndex == 0) return 0;
	#ifdef SHADER_RAYTRACING
		return TriplanarTextureA(textures[nonuniformEXT(texIndex)], coords, blending);
	#else
		return TriplanarTextureA(textures[texIndex], coords, blending);
	#endif
}
vec3 TriplanarLocalNormalMap(uint normalTexIndex, vec3 coords, vec3 localFaceNormal, vec3 blending) {
	if (normalTexIndex == 0) return vec3(0);
	#ifdef SHADER_RAYTRACING
		return TriplanarLocalNormalMap(textures[nonuniformEXT(normalTexIndex)], coords, localFaceNormal, blending);
	#else
		return TriplanarLocalNormalMap(textures[normalTexIndex], coords, localFaceNormal, blending);
	#endif
}

#define NormalFromBumpNoise(normalBump, localHitPosition, noiseFunc) {\
	vec3 _tangentX = normalize(cross(normalize(vec3(0.356,1.2145,0.24537)), normalBump.xyz));\
	vec3 _tangentY = normalize(cross(normalBump.xyz, _tangentX));\
	mat3 _TBN = mat3(_tangentX, _tangentY, normalBump.xyz);\
	float _altitudeTop = noiseFunc(localHitPosition + _tangentY/1000);\
	float _altitudeBottom = noiseFunc(localHitPosition - _tangentY/1000);\
	float _altitudeRight = noiseFunc(localHitPosition + _tangentX/1000);\
	float _altitudeLeft = noiseFunc(localHitPosition - _tangentX/1000);\
	vec3 _bump = normalize(vec3((_altitudeRight-_altitudeLeft), (_altitudeBottom-_altitudeTop), 2));\
	normalBump.xyz = normalize(_TBN * _bump);\
	normalBump.a *= 0.25*(_altitudeTop+_altitudeBottom+_altitudeRight+_altitudeLeft);\
}

#endif // _SHADER_BASE_INCLUDED_

const float EPSILON = 0.00001;

struct CapsuleAttr {
	float radius;
	float len;
	vec3 normal;
};

hitAttributeEXT CapsuleAttr capsuleAttr;

#ifdef SHADER_RINT
	void main() {
		ProceduralGeometryData geometry = GetProceduralGeometry();
		const vec3 aabb_min = vec3(geometry.aabb[0], geometry.aabb[1], geometry.aabb[2]);
		const vec3 aabb_max = vec3(geometry.aabb[3], geometry.aabb[4], geometry.aabb[5]);
		
		const vec3 ro = gl_ObjectRayOriginEXT;
		const vec3 rd = gl_ObjectRayDirectionEXT;
		
		// Compute pa, pb, r  from just the aabb info
		float r;
		vec3 pa;
		vec3 pb;
		{
			const float x = aabb_max.x - aabb_min.x;
			const float y = aabb_max.y - aabb_min.y;
			const float z = aabb_max.z - aabb_min.z;
			if (abs(x-y) < EPSILON) { // Z is length
				r = (aabb_max.x - aabb_min.x) / 2.0;
				pa.xy = (aabb_min.xy + aabb_max.xy) / 2.0;
				pb.xy = pa.xy;
				pa.z = aabb_min.z + sign(aabb_max.z - aabb_min.z) * r;
				pb.z = aabb_max.z + sign(aabb_min.z - aabb_max.z) * r;
			} else if (abs(x-z) < EPSILON) { // Y is length
				r = (aabb_max.x - aabb_min.x) / 2.0;
				pa.xz = (aabb_min.xz + aabb_max.xz) / 2.0;
				pb.xz = pa.xz;
				pa.y = aabb_min.y + sign(aabb_max.y - aabb_min.y) * r;
				pb.y = aabb_max.y + sign(aabb_min.y - aabb_max.y) * r;
			} else { // X is length
				r = (aabb_max.y - aabb_min.y) / 2.0;
				pa.yz = (aabb_min.yz + aabb_max.yz) / 2.0;
				pb.yz = pa.yz;
				pa.x = aabb_min.x + sign(aabb_max.x - aabb_min.x) * r;
				pb.x = aabb_max.x + sign(aabb_min.x - aabb_max.x) * r;
			}
		}
		
		// Ray-Capsule Intersection (ro, rd, pa, pb, r)
		const vec3 ba = pb - pa;
		const vec3 oa = ro - pa;
		const float baba = dot(ba, ba);
		const float bard = dot(ba, rd);
		const float baoa = dot(ba, oa);
		const float rdoa = dot(rd, oa);
		const float oaoa = dot(oa, oa);
		float a = baba - bard*bard;
		float b = baba*rdoa - baoa*bard;
		float c = baba*oaoa - baoa*baoa - r*r*baba;
		float h = b*b - a*c;
		
		if (h >= 0.0) {
			const float t1 = (-b-sqrt(h)) / a;
			const float t2 = (-b+sqrt(h)) / a;
			const float y1 = baoa + t1*bard;
			const float y2 = baoa + t2*bard;
			
			// cylinder body Outside surface
			if (y1 > 0.0 && y1 < baba && gl_RayTminEXT <= t1) {
				capsuleAttr.radius = r;
				capsuleAttr.len = length(ba);
				const vec3 posa = (gl_ObjectRayOriginEXT + gl_ObjectRayDirectionEXT * t1) - pa;
				capsuleAttr.normal = normalize((posa - clamp(dot(posa, ba) / dot(ba, ba), 0.0, 1.0) * ba) / r);
				reportIntersectionEXT(t1, 0);
				return;
			}
			
			vec3 oc;
			
			// rounded caps Outside surface
			// BUG: There is currently an issue with this when the ray origin starts inside the cylinder between points A and B, we can see part of the sphere of cap A. This should not be a problem if we always render the outside surfaces or for collision detection.
			oc = (y1 <= 0.0)? oa : ro - pb;
			b = dot(rd, oc);
			c = dot(oc, oc) - r*r;
			h = b*b - c;
			if (h > 0.0) {
				const float t = -b - sqrt(h);
				if (gl_RayTminEXT <= t) {
					capsuleAttr.radius = r;
					const vec3 posa = (gl_ObjectRayOriginEXT + gl_ObjectRayDirectionEXT * t) - pa;
					capsuleAttr.normal = normalize((posa - clamp(dot(posa, ba) / dot(ba, ba), 0.0, 1.0) * ba) / r);
					if (dot(capsuleAttr.normal, rd) < 0) {
						capsuleAttr.len = length(ba);
						reportIntersectionEXT(t, 2);
						return;
					}
				}
			}
			
			// cylinder body Inside surface
			if (y2 > 0.0 && y2 < baba && gl_RayTminEXT <= t2) {
				capsuleAttr.radius = r;
				capsuleAttr.len = length(ba);
				const vec3 posa = (gl_ObjectRayOriginEXT + gl_ObjectRayDirectionEXT * t2) - pa;
				capsuleAttr.normal = -normalize((posa - clamp(dot(posa, ba) / dot(ba, ba), 0.0, 1.0) * ba) / r);
				reportIntersectionEXT(t2, 1);
				return;
			}
			
			// rounded caps Inside surface
			oc = (y2 <= 0.0)? oa : ro - pb;
			b = dot(rd, oc);
			c = dot(oc, oc) - r*r;
			h = b*b - c;
			if (h > 0.0) {
				const float t = -b + sqrt(h);
				if (gl_RayTminEXT <= t) {
					capsuleAttr.radius = r;
					capsuleAttr.len = length(ba);
					const vec3 posa = (gl_ObjectRayOriginEXT + gl_ObjectRayDirectionEXT * t) - pa;
					capsuleAttr.normal = -normalize((posa - clamp(dot(posa, ba) / dot(ba, ba), 0.0, 1.0) * ba) / r);
					reportIntersectionEXT(t, 3);
					return;
				}
			}
			
		}
		
	}
#endif

#ifdef SHADER_RCHIT
	void main() {
		RCHIT_VISIBILITY_BEGIN
			ProceduralGeometryData geometry = GetProceduralGeometry();
		
			ray.normal = normalize(mat3(MODELVIEW) * capsuleAttr.normal);
			ray.color = vec4(geometry.albedo_opacity.rgb, geometry.albedo_opacity.a);
			ray.pbr = vec2(1, 0);
			ray.emission = GetEmissionColor(geometry.emission_temperature);
			ray.bump = vec3(0);
			ray.iOR = 1.45;
			
			// Transparency tests
			if ((camera.debug & RENDER_DEBUG_USE_DEBUG_VALUES) != 0) {
				ray.color.a = 1.0 - camera.debugValue1;
				ray.iOR = 1.0 + camera.debugValue2;
			}
			
		RCHIT_VISIBILITY_END
	}
#endif


