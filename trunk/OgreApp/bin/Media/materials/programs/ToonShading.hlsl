// ----------------------------------------------------------
// Global variables
// ----------------------------------------------------------

uniform extern float4x4	worldViewProj;

// Light position in object space
uniform extern float3	lightPosition;
// Eye position in object space
uniform extern float3	eyePosition;
// Shininess parameter
uniform extern float4	shininess;


// ----------------------------------------------------------
// Input/Output structures
// ----------------------------------------------------------

struct VS_INPUT 
{
	// Position
	float4 position			: POSITION; 
	// Normal
	float3 normal			: NORMAL;
};

struct VS_OUTPUT
{
	// Position
    float4 position			: SV_POSITION;
	
	// Diffusive component 
	float  diffusiveFactor	: TEXCOORD0;
	// Specular component
	float  specularFactor	: TEXCOORD1;
};


// ----------------------------------------------------------
// Vertex shader
// ----------------------------------------------------------

VS_OUTPUT ToonShadingVS( VS_INPUT input )
{
    VS_OUTPUT output			= ( VS_OUTPUT )0;

	// Calculate output position
	output.position				= mul( worldViewProj, input.position );

	// Calculate light vector
	float3 N					= normalize( input.normal );
	float3 L					= normalize( lightPosition - input.position.xyz );
	
	// Calculate diffuse component
	output.diffusiveFactor		= max( dot( N, L ), 0 );

	float3 E					= normalize( eyePosition - input.position.xyz );

	if ( output.diffusiveFactor == 0 ) 
	{
		// Cancel specular if diffuse is 0
		output.specularFactor	= 0;
	}
	else 
	{
		// Calculate specular component
		float3 H				= normalize( L + E );
		output.specularFactor	= pow( max( dot( N, H ), 0 ), shininess );
	}

    return output;
}


// ----------------------------------------------------------
// Texture samplers and light parameters
// ----------------------------------------------------------

uniform sampler1D diffusiveGradient	: register( s0 );
uniform sampler1D specularGradient	: register( s1 );

uniform float4 diffusiveComponent;
uniform float4 specularComponent;


// ----------------------------------------------------------
// Pixel shader
// ----------------------------------------------------------

float4 ToonShadingPS( VS_OUTPUT input ) : SV_Target
{
	float diffusiveFactor	= tex1D(diffusiveGradient, input.diffusiveFactor).x;
	float specularFactor	= tex1D(specularGradient, input.specularFactor).x;

	float4 color			= ((diffusiveComponent * diffusiveFactor) + 
								(specularComponent * specularFactor));

	return color;
}