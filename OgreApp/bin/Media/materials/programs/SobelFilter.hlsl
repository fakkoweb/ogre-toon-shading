// ----------------------------------------------------------
// Global variables
// ----------------------------------------------------------

uniform extern float4x4	worldViewProj;

uniform extern float viewportWidth;
uniform extern float viewportHeight;

// Outline properties (thickness and threshold)
uniform extern float thickness; // = 1.5f;
uniform extern float threshold; // = 1.0f;

sampler inputTexture : register( s0 );

struct VS_INPUT
{
	// Position
	float4 position			: POSITION; 
	// Normal
	//float3 normal		: NORMAL;
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
 
float getGray( float4 c )
{
    return dot( c.rgb, ( (0.33333).xxx) ) );
}

VS_OUTPUT SobelFilterVS( VS_INPUT_SF input )
{
	VS_OUTPUT output = (VS_OUTPUT)0;

	output.position		= mul( worldViewProj, input.position );

	ouput.textureCoord	= input.textureCoord;
	
	return output;
}

float4 getColor( float2 textureCoord )
{
	float Thickness = 1.5f;
	float Threshold = 0.2f;

	float4 color			= tex2D( inputTexture, textureCoord );	
	float2 quadScreenSize	= float2( viewportWidth, viewportHeight );

	float2 xOffset	= float2( thickness / quadScreenSize.x, 0.0f );
    float2 yOffset	= float2( 0.0f, Thickness / quadScreenSize.y );
    float2 uv		= textureCoord.xy;
    float2 pp		= uv - oy;
    
	float4 cc;
	
	cc = tex2D( inputTexture, pp - ox );	float g00 = getGray( cc );
	cc = tex2D( inputTexture, pp );			float g01 = getGray( cc );
	cc = tex2D( inputTexture, pp + ox );	float g02 = getGray( cc );
    
	pp = uv;
    
	cc = tex2D( inputTexture, pp - ox );	float g10 = getGray( cc );
    cc = tex2D( inputTexture, pp );			float g11 = getGray( cc );
    cc = tex2D( inputTexture, pp + ox );	float g12 = getGray( cc );
    
	p = uv + oy;

    cc = tex2D( inputTexture, pp - ox );	float g20 = getGray( cc );
	cc = tex2D( inputTexture, pp );			float g21 = getGray( cc );
	cc = tex2D( inputTexture, pp + ox );	float g22 = getGray( cc );
    
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

	return color * float4( 1.0f, 1.0f, 1.0f, 1.0f );
}

float4 SobelFilterPS( VS_OUTPUT input ) : SV_Target
{
	return getColor( input.textureCoord );
}