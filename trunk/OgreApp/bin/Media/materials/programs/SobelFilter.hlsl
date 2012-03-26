sampler textureInput : register( s0 );
// World, view and projection matrices
uniform extern float4x4		worldMatrix;
uniform extern float4x4		viewMatrix;
uniform extern float4x4		projMatrix;

//float ViewportWidth = 800;
//float ViewportHeight = 600;

uniform extern float ViewportWidth;
uniform extern float ViewportHeight;

// Use these two variables to set the outline properties( thickness and threshold )
float Thickness = 1.5f;
float Threshold = 1.0f;

struct VS_INPUT_SF 
{
	// Position
	float4 pos			: POSITION; 
	
	float3 normal		: NORMAL;
	// Texture coordinates
    float2 tex			: TEXCOORD0;
};

struct VS_OUTPUT_SF
{
	// Position
    float4 pos			: SV_POSITION;
	float2 tex		: TEXCOORD0;
};
 
float getGray(float4 c)
{
    return(dot(c.rgb,((0.33333).xxx)));
}

VS_OUTPUT_SF SobelFilterVS(VS_INPUT_SF input)
{
	VS_OUTPUT_SF o;
//	o.pos = input.pos;
//	o.tex = input.tex;
	
	float4 worldPos		= mul( worldMatrix, input.pos );
	float4 cameraPos	= mul( viewMatrix, worldPos );
	o.pos			= mul( projMatrix, cameraPos );
	o.tex = input.tex;
	return o;
}
float4 getColor(float2 Tex)
{
//	return (1.0f - ViewportHeight, 1,0,1);
	
	float Thickness = 1.5f;
float Threshold = 0.2f;

	float4 Color = tex2D(textureInput, Tex);	
	float2 QuadScreenSize = float2(ViewportWidth,ViewportHeight);

	float2 ox = float2( Thickness / QuadScreenSize.x, 0.0);
    float2 oy = float2(0.0, Thickness / QuadScreenSize.y);
    float2 uv = Tex.xy;
    float2 PP = uv - oy;
    
	float4 CC = tex2D(textureInput,PP-ox); 
	float g00 = getGray(CC);
    
	CC = tex2D(textureInput,PP); 
	float g01 = getGray(CC);
    
	CC = tex2D(textureInput,PP+ox); float g02 = getGray(CC);
    PP = uv;
    
	CC = tex2D(textureInput,PP-ox); float g10 = getGray(CC);
    CC = tex2D(textureInput,PP);    float g11 = getGray(CC);
    CC = tex2D(textureInput,PP+ox); float g12 = getGray(CC);
    PP = uv + oy;
    CC = tex2D(textureInput,PP-ox); float g20 = getGray(CC);
    
	CC = tex2D(textureInput,PP);    float g21 = getGray(CC);
    
	CC = tex2D(textureInput,PP+ox); float g22 = getGray(CC);
    
	float K00 = -1;
    float K01 = -2;
    float K02 = -1;
    float K10 = 0;
    float K11 = 0;
    float K12 = 0;
    float K20 = 1;
    float K21 = 2;
    float K22 = 1;
    float sx = 0;
    float sy = 0;
    sx += g00 * K00;
    sx += g01 * K01;
    sx += g02 * K02;
    sx += g10 * K10;
    sx += g11 * K11;
    sx += g12 * K12;
    sx += g20 * K20;
    sx += g21 * K21;
    sx += g22 * K22;
	 
    sy += g00 * K00;
    sy += g01 * K10;
    sy += g02 * K20;
    sy += g10 * K01;
    sy += g11 * K11;
    sy += g12 * K21;
    sy += g20 * K02;
    sy += g21 * K12;
    sy += g22 * K22; 
    float dist = sqrt(sx*sx+sy*sy);
    //float result = 1;
    //if (dist>Threshold) { result = 0; }
    
	if (dist>Threshold)
		return float4(0,0,0,1);
	return Color * float4(1,1,1,1);
    // The scene will be in black and white, so to render
    // everything normaly, except for the edges, bultiply the
    // edge texture with the scenecolor
    //return Color*result.xxxx;
}
 float4 SobelFilterPS ( VS_OUTPUT_SF input ) : SV_Target
//float4 SobelFilterPS ( float2 Tex: TEXCOORD0 ) : COLOR
{

	//return float4(0.5 , 0.0,0.0,1.0);
	return getColor(input.tex);
	//TODO: global?
/*	float K00 = -1;
    float K01 = -2;
    float K02 = -1;
    float K10 = 0;
    float K11 = 0;
    float K12 = 0;
    float K20 = 1;
    float K21 = 2;
    float K22 = 1;
	
	float2 offsetX = float2(Thickness/ViewportWidth,0.0);
    float2 offsetY = float2(0.0,Thickness/ViewportHeight);

	float2 upperRowTexelOffsetY = input.tex - offsetY;
	//row 0
	float4 NW = tex2D(textureInput,upperRowTexelOffsetY - offsetX);
	float4 N = tex2D(textureInput,upperRowTexelOffsetY);
	float4 NE = tex2D(textureInput,upperRowTexelOffsetY + offsetX);

	//row 1
	float4 W = tex2D(textureInput,input.tex - offsetX);
	float4 C = tex2D(textureInput,input.tex);
	float4 E = tex2D(textureInput,input.tex + offsetX);

	float2 lowerRowTexelOffsetY = input.tex + offsetY;
	//row 1
	float4 SW = tex2D(textureInput,lowerRowTexelOffsetY - offsetX);
	float4 S = tex2D(textureInput,lowerRowTexelOffsetY);
	float4 SE = tex2D(textureInput,lowerRowTexelOffsetY + offsetX);

	//To grey scale:

	float g00 = getGray(NW);
	float g01 = getGray(N);
	float g02 = getGray(NE);
	
	float g10 = getGray(W);
	float g11 = getGray(C);
	float g12 = getGray(E);
	
	float g20 = getGray(SW);
	float g21 = getGray(S);
	float g22 = getGray(SE);
	
	//Convolution 
	float GX = 0;
	float GY = 0;

	GX += g00 * K00;
    GX += g01 * K01;
    GX += g02 * K02;
    GX += g10 * K10;
    GX += g11 * K11;
    GX += g12 * K12;
    GX += g20 * K20;
    GX += g21 * K21;
    GX += g22 * K22;
	
	GY += g00 * K00;
    GY += g01 * K10;
    GY += g02 * K20;
    GY += g10 * K01;
    GY += g11 * K11;
    GY += g12 * K21;
    GY += g20 * K02;
    GY += g21 * K12;
    GY += g22 * K22; 
    
	float G = sqrt(GX*GX+GY*GY);

	if (G>Threshold)
		return float4(0,0,0,1);
	return C;
	*/
//	float4 color = tex2D( textureInput, input.tex );
//	float4 color = float4(Tex.x, Tex.y,0.2,1);
//	return color;
	//return float4(0,1,0,1);
}