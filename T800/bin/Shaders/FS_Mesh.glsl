
uniform mediump sampler2D DiffuseTex;

#ifdef SPECULAR_MAP
uniform mediump sampler2D SpecularTex;
#endif

#ifdef GLOSS_MAP
uniform mediump sampler2D GlossTex;
#endif

#ifdef NORMAL_MAP
uniform mediump sampler2D NormalTex;
#endif

uniform highp vec4 LightPos;
uniform highp vec4 LightColor;
uniform highp vec4 CameraPosition;
uniform highp vec4 CameraInfo;
uniform highp vec4 Ambient;


#define PHONG 1
#define BLINN 2

#define SPECULAR_MODEL BLINN

#if   SPECULAR_MODEL == PHONG
#define USING_PHONG
#elif SPECULAR_MODEL == BLINN
#define USING_BLINN
#endif


#define AMBIENT
#define DIFFUSE
#define SPECULAR
#define FRESNEL 
/*

#ifdef DIFFUSE_MAP
#undef DIFFUSE_MAP
#endif

#ifdef SPECULAR_MAP
#undef SPECULAR_MAP
#endif

#ifdef GLOSS_MAP
#undef GLOSS_MAP
#endif 

#ifdef NORMAL_MAP
#undef NORMAL_MAP
#endif

*/

#ifdef USE_TEXCOORD0
	#ifdef ES_30
		in highp vec2 vecUVCoords;
	#else
		varying highp vec2 vecUVCoords;
	#endif
#endif


#ifdef USE_NORMALS
	#ifdef ES_30
		in highp vec4 hnormal;
	#else
		varying highp vec4 hnormal;
	#endif
#endif

#ifdef USE_TANGENTS
	#ifdef ES_30
		in highp vec4 htangent;
	#else
		varying highp vec4 htangent;
	#endif
#endif

#ifdef USE_BINORMALS
	#ifdef ES_30
		in highp vec4 hbinormal;
	#else
		varying highp vec4 hbinormal;
	#endif
#endif

#ifdef ES_30
	in highp vec4 Pos;
	in highp vec4 WorldPos;
#else
	varying highp vec4 Pos;
	varying highp vec4 WorldPos;
#endif

#ifdef SIMPLE_COLOR
	#ifdef ES_30
	layout(location = 0) out highp vec4 colorOut;
	#endif
void main(){
	#ifdef ES_30
		colorOut = vec4(0.5,0.5,0.5,1.0);
	#else
		gl_FragColor = vec4(0.5,0.5,0.5,1.0);
	#endif
}
#elif defined(G_BUFFER_PASS)
#ifdef ES_30
	layout(location = 0) out highp vec4 colorOut_0;
#ifdef USING_16BIT_NORMALS
	layout(location = 1) out highp vec2 colorOut_1;
#else
	layout(location = 1) out highp vec4 colorOut_1;
#endif
	layout(location = 2) out highp vec4 colorOut_2;
	layout(location = 3) out highp vec4 colorOut_3;
#endif
void main(){
	lowp vec4 color    = vec4(0.5,0.5,0.5,1.0);
	highp vec4 normal   = vec4(0.5,0.5,0.5,1.0);
	lowp vec4 specular = vec4(0.5,0.5,0.5,1.0);
	lowp vec4 reflect  = vec4(0.5,0.5,0.5,1.0);

	mediump float specIntesivity = 0.8;
	mediump float shinness = 2.0;
	
	#ifdef DIFFUSE_MAP
		#ifdef ES_30
			color = texture(DiffuseTex,vecUVCoords);
		#else
			color = texture2D(DiffuseTex,vecUVCoords);
		#endif
	#endif
	
	normal.xyz   = normalize(hnormal).xyz;  
	#ifdef NORMAL_MAP	
		#ifdef ES_30
			highp vec3 normalTex  = texture(NormalTex,vecUVCoords).xyz;
		#else
			highp vec3 normalTex  = texture2D(NormalTex,vecUVCoords).xyz;
		#endif
		normalTex 		 	 = normalTex*vec3(2.0,2.0,2.0) - vec3(1.0,1.0,1.0);
		normalTex		 	 = normalize(normalTex);
		normalTex.g 	 	 = -normalTex.g;
		lowp vec3 tangent	 = normalize(htangent).xyz;
		lowp vec3 binormal	 = normalize(hbinormal).xyz;
		lowp mat3	TBN 	 = mat3(tangent,binormal,normal);
		normal.xyz		 	 = TBN*normalTex;
		normal.xyz		 	 = normalize(normal.xyz);
	#endif

	#ifdef SPECULAR_MAP
		#ifdef ES_30
			specular = texture(SpecularTex,vecUVCoords);
		#else
			specular = texture2D(SpecularTex,vecUVCoords);
		#endif
	#endif
	
	#ifdef GLOSS_MAP
		#ifdef ES_30
			shinness = texture(GlossTex,vecUVCoords).r + shinness;
		#else
			shinness = texture2D(GlossTex,vecUVCoords).r + shinness;
		#endif		
	#endif
	
		
	#ifdef USING_16BIT_NORMALS
		highp vec2 N = normalize(normal.xy) * (sqrt(-normal.z*0.5+0.5));
		N = N*0.5+0.5;
	#else	
		normal.xyz		 = normal.xyz*0.5 + 0.5;	
	#endif	
	
	
	#ifdef ES_30
		colorOut_0.rgb  = color.rgb;
		colorOut_0.a 	= specIntesivity;

	#ifdef USING_16BIT_NORMALS
		colorOut_1  = vec4(N,0.0,0.0);
	#else
		colorOut_1.rgb  = normal.xyz;
		colorOut_1.a 	= shinness;
	#endif
		colorOut_2.rgb  = specular.rgb;
		colorOut_2.a 	= shinness;

		#ifdef NO_LIGHT
			colorOut_3	= vec4(1.0,0.0,1.0,1.0);
		#else
			#ifdef NORMAL_MAP	
				colorOut_3 	= vec4(0.0,0.0,0.0,1.0);
			#else
				colorOut_3 	= vec4(0.0,0.0,1.0,1.0);
			#endif
		#endif

		#ifdef NON_LINEAR_DEPTH
			gl_FragDepth = Pos.z / Pos.w;
		#else
			gl_FragDepth = Pos.z / CameraInfo.y;
		#endif
	#else
		gl_FragData[0].rgb  = color.rgb;
		gl_FragData[0].a 	= specIntesivity;
		
#ifdef USING_16BIT_NORMALS
		gl_FragData[1]  = vec4(N,0.0,0.0);
#else
		gl_FragData[1].rgb  = normal.xyz;
		gl_FragData[1].a 	= shinness;
#endif	
		gl_FragData[2].rgb  = specular.rgb;
		gl_FragData[2].a 	= shinness;

		#ifdef NO_LIGHT
			gl_FragData[3]	= vec4(1.0,0.0,1.0,1.0);
		#else
			#ifdef NORMAL_MAP	
				gl_FragData[3] 	= vec4(0.0,0.0,0.0,1.0);
			#else
				gl_FragData[3] 	= vec4(0.0,0.0,1.0,1.0);
			#endif
		#endif

		#ifdef NON_LINEAR_DEPTH
			gl_FragDepth	= Pos.z / Pos.w;
		#else
			gl_FragDepth = Pos.z / CameraInfo.y;
		#endif
	#endif
	
}
#elif defined(SHADOW_MAP_PASS)
void main(){
#ifdef NON_LINEAR_DEPTH
	gl_FragDepth = Pos.z / Pos.w;
#else
	gl_FragDepth = Pos.z / CameraInfo.y;
#endif
}
#else
	#ifdef ES_30
		layout(location = 0) out highp vec4 colorOut;
	#endif
void main(){

	lowp vec4 color = vec4(0.5,0.5,0.5,1.0);
	lowp vec4 Final = vec4(0.0,0.0,0.0,1.0);
	
#ifdef USE_TEXCOORD0
	#ifdef NO_LIGHT
		#ifdef ES_30
			color = texture(DiffuseTex,vecUVCoords);
		#else
			color = texture2D(DiffuseTex,vecUVCoords);
		#endif
	#else
		#ifdef DIFFUSE_MAP
			#ifdef ES_30
				color = texture(DiffuseTex,vecUVCoords);
			#else
				color = texture2D(DiffuseTex,vecUVCoords);
			#endif
		#endif
		
		#ifdef SPECULAR_MAP
			#ifdef ES_30
				lowp vec4 specularmap = texture(SpecularTex,vecUVCoords);
			#else
				lowp vec4 specularmap = texture2D(SpecularTex,vecUVCoords);
			#endif
		#endif
		
		#ifdef USE_NORMALS
			lowp vec4 Ambiental = color*Ambient;
		
			lowp vec4   Lambert  = LightColor;
			lowp vec4 	Specular = LightColor;
			lowp vec4	Fresnel  = LightColor;
			lowp vec3	LightDir = normalize(LightPos-WorldPos).xyz;
			lowp vec3   EyeDir   = normalize(CameraPosition-WorldPos).xyz;
			lowp vec3	normal   = normalize(hnormal).xyz;  
			mediump float att			 = 1.0;
			
			
		#ifdef NORMAL_MAP	
			#ifdef ES_30
				lowp vec3 normalTex = texture(NormalTex,vecUVCoords).xyz;
			#else
				lowp vec3 normalTex = texture2D(NormalTex,vecUVCoords).xyz;
			#endif
			normalTex 		 = normalTex*vec3(2.0,2.0,2.0) - vec3(1.0,1.0,1.0);
			normalTex		 = normalize(normalTex);
			normalTex.g 	 = -normalTex.g;
			lowp vec3 tangent	 = normalize(htangent).xyz;
			lowp vec3 binormal	 = normalize(hbinormal).xyz;
			lowp mat3	TBN = mat3(tangent,binormal,normal);
			normal			 = TBN*normalTex;
			normal			 = normalize(normal);
		#endif
		
		#ifdef DIFFUSE
			att		 	     = dot(normal,LightDir)*0.5 + 0.5;
			att				 = pow( att , 2.0 );	
			att				 = clamp( att , 0.0 , 1.0 );
			Lambert			*= color*att;
		#endif
		
		#ifdef SPECULAR
			highp float specular  = 0.0;
			highp float specIntesivity = 0.8;
			highp float shinness = 8.0;
			
			#ifdef GLOSS_MAP
				#ifdef ES_30
					shinness = texture(GlossTex,vecUVCoords).r + shinness;
				#else
					shinness = texture2D(GlossTex,vecUVCoords).r + shinness;
				#endif
			#endif

		#ifdef USING_PHONG
			lowp vec3 ReflectedLight = reflect(-LightDir,normal);
			//specular = max ( dot(ReflectedLight,EyeDir), 0.0);	
			specular =  dot(ReflectedLight,EyeDir)*0.5 + 0.5;	
			specular = pow( specular ,shinness);		
		#elif defined(USING_BLINN)
			lowp vec3 ReflectedLight = normalize(EyeDir+LightDir); 
			specular = max ( dot(ReflectedLight,normal)*0.5 + 0.5, 0.0);	
			specular = pow( specular ,shinness);	
		#endif
			
			specular *= att; 
			specular *= specIntesivity;
			Specular *= specular;
			
			#ifdef SPECULAR_MAP
				Specular.xyz *= specularmap.xyz;
			#endif
				
		#endif
		
	#ifdef FRESNEL
		mediump float  FresnelAtt	= dot(normal,EyeDir);
		lowp float  FresnelIntensity = 1.0;
		#ifdef SPECULAR_MAP
			lowp vec4 FresnelCol = vec4(specularmap.xyz,1.0);
		#else
			lowp vec4 FresnelCol = vec4(1.0,1.0,1.0,1.0);	
		#endif
		FresnelAtt		= abs(FresnelAtt);
		FresnelAtt 		= 1.0 - FresnelAtt;
		FresnelAtt 		= clamp( FresnelAtt , 0.0 , 1.0 );
		FresnelAtt		= pow( FresnelAtt , 4.0 );	
		FresnelAtt 		= clamp(FresnelAtt , 0.0 , 1.0 );
		Fresnel 		= FresnelCol*FresnelIntensity*FresnelAtt; 
	#endif
		
		#ifdef AMBIENT
			Final += Ambiental;
		#endif
		
		#ifdef DIFFUSE
			Final += Lambert;
		#endif
		
		#ifdef SPECULAR
			Final += Specular;
		#endif
		
		#ifdef SPECULAR
			Final += Specular;
		#endif
		
		#ifdef FRESNEL
			Final += Fresnel;
		#endif
		
		color = Final;
		#endif
	#endif
#endif

	#ifdef ES_30
		colorOut = color;
	#else
		gl_FragColor = color;
	#endif
	
}

#endif