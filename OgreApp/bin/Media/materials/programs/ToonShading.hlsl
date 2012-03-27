// ----------------------------------------------------------
// Global variables
// ----------------------------------------------------------

// World, view and projection matrices
uniform extern float4x4		worldMatrix;
uniform extern float4x4		viewMatrix;
uniform extern float4x4		projMatrix;

// Light position in world space
uniform extern float3		lightPosition;

// Camera position in world space
// uniform extern float3	cameraPosition;

// Default material color
uniform extern float4		defaultColor;


// ----------------------------------------------------------
// Input/Output structures
// ----------------------------------------------------------

struct VS_INPUT 
{
	// Position
	float4 pos			: POSITION; 
	// Normal
	float3 normal		: NORMAL;
};

struct VS_OUTPUT
{
	// Position
    float4 pos			: SV_POSITION;
	// Normal
	float3 normal		: NORMAL;
	// Normal in world coordinates
	float3 worldPos		: TEXCOORD0;
};


// ----------------------------------------------------------
// Vertex shader
// ----------------------------------------------------------

VS_OUTPUT ToonShadingVS( VS_INPUT input )
{
    VS_OUTPUT output = ( VS_OUTPUT )0;

	float4 worldPos		= mul( worldMatrix, input.pos );
	float4 cameraPos	= mul( viewMatrix, worldPos );
	output.pos			= mul( projMatrix, cameraPos );

	float3 worldNormal	= normalize( mul( input.normal, (float3x3)worldMatrix ) );
	output.normal		= worldNormal;

	output.worldPos		= worldPos.xyz;

    return output;
}


// ----------------------------------------------------------
// Texture samplers
// ----------------------------------------------------------

sampler gradientSampler : register( s0 );

sampler colorSampler	: register( s1 );


// ----------------------------------------------------------
// Pixel shader
// ----------------------------------------------------------

float4 ToonShadingPS( VS_OUTPUT input ) : SV_Target
{
	input.normal		= normalize( input.normal );

	float3 toLight		= lightPosition - input.worldPos; 
	float3 lightDir		= normalize( toLight );

	// float3 toCamera = cameraPosition - input.worldPos;
	// float3 cameraDir	= normalize( toCamera );

	// float cameraAngle = dot( input.normal, cameraDir );

	// if ( abs( cameraAngle ) < 0.2f )
	//		return float4( 0.0f, 0.0f, 0.0f, 1.0f );

	float gradientCoord = clamp( dot( input.normal, lightDir ), 0.0f, 1.0f );

	float4 color		= tex1D( gradientSampler, gradientCoord );

	color				= color * defaultColor;

	return color;
}