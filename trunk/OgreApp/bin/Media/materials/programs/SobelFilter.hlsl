// ----------------------------------------------------------
// Global variables
// ----------------------------------------------------------

uniform extern float4x4	worldViewProj;

uniform extern float viewportWidth;
uniform extern float viewportHeight;

// Outline properties (thickness and threshold)
uniform extern float thickness;
uniform extern float threshold;

uniform extern bool coloredMode;

// ----------------------------------------------------------
// Input/Output structures
// ----------------------------------------------------------

struct VS_INPUT
{
	// Position
	float4 position			: POSITION; 
	// Texture coordinates
    float2 textureCoord		: TEXCOORD0;
};

struct VS_OUTPUT
{
	// Position
    float4 position			: SV_POSITION;
	// Texture coordinates
	float2 textureCoord		: TEXCOORD0;
};


// ----------------------------------------------------------
// Vertex shader
// ----------------------------------------------------------

VS_OUTPUT SobelFilterVS( VS_INPUT input )
{
	VS_OUTPUT output = (VS_OUTPUT)0;

	output.position		= mul( worldViewProj, input.position );

	output.textureCoord	= input.textureCoord;
	
	return output;
}


// ----------------------------------------------------------
// Texture sampler
// ----------------------------------------------------------

sampler inputTexture : register( s0 );


// ----------------------------------------------------------
// Utility functions
// ----------------------------------------------------------

float getGray( float4 c )
{
    return dot( c.rgb, ( (0.33333).xxx) );
}

float4 getEdge( float2 textureCoord )
{
	float2 quadScreenSize	= float2( viewportWidth, viewportHeight );

	float2 xOffset	= float2( thickness / quadScreenSize.x, 0.0f );
    float2 yOffset	= float2( 0.0f, thickness / quadScreenSize.y );
    float2 uv		= textureCoord.xy;
    float2 pp		= uv - yOffset;
    
	float4 cc;
	
	cc = tex2D( inputTexture, pp - xOffset );	float g00 = getGray( cc );
	cc = tex2D( inputTexture, pp );				float g01 = getGray( cc );
	cc = tex2D( inputTexture, pp + xOffset );	float g02 = getGray( cc );
    
	pp = uv;
    
	cc = tex2D( inputTexture, pp - xOffset );	float g10 = getGray( cc );
    cc = tex2D( inputTexture, pp );				float g11 = getGray( cc );
    cc = tex2D( inputTexture, pp + xOffset );	float g12 = getGray( cc );
    
	pp = uv + yOffset;

    cc = tex2D( inputTexture, pp - xOffset );	float g20 = getGray( cc );
	cc = tex2D( inputTexture, pp );				float g21 = getGray( cc );
	cc = tex2D( inputTexture, pp + xOffset );	float g22 = getGray( cc );
    
	// Sobel filter kernel
	float K00	= -1;
    float K01	= -2;
    float K02	= -1;
    float K10	= 0;
    float K11	= 0;
    float K12	= 0;
    float K20	= 1;
    float K21	= 2;
    float K22	= 1;

    float Gx	= 0;
    float Gy	= 0;
    
	// Gx
	Gx += g00 * K00;
    Gx += g01 * K01;
    Gx += g02 * K02;
    Gx += g10 * K10;
    Gx += g11 * K11;
    Gx += g12 * K12;
    Gx += g20 * K20;
    Gx += g21 * K21;
    Gx += g22 * K22;
	 
	// Gy
    Gy += g00 * K00;
    Gy += g01 * K10;
    Gy += g02 * K20;
    Gy += g10 * K01;
    Gy += g11 * K11;
    Gy += g12 * K21;
    Gy += g20 * K02;
    Gy += g21 * K12;
    Gy += g22 * K22; 
    
	float norm = sqrt( Gx * Gx + Gy * Gy );
    
	if (norm > threshold)
	{
		return float4( 0.0f, 0.0f, 0.0f, 1.0f );
	}

	return float4( 1.0f, 1.0f, 1.0f, 1.0f );
}


// ----------------------------------------------------------
// Pixel shader
// ----------------------------------------------------------

float4 SobelFilterPS( VS_OUTPUT input ) : SV_Target
{
	float4 color = tex2D( inputTexture, input.textureCoord );

	color = color * getEdge( input.textureCoord );

	return color;
}