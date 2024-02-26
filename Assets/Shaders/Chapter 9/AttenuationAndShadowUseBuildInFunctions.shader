Shader "Unity Shaders Book/Chapter 9/Attenuation And Shadow Use Build-in Functions"
{
    Properties{
        _Color("Color Tint", Color) = (1, 1, 1, 1)
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Range(8.0, 256)) = 20
    }
    SubShader{
        Tags{
            "RenderType" = "Opaque"
        }

        Pass{
            // Pass for ambient light & first pixel light (directional light)
            Tags{
                "LightMode" = "ForwardBase"
            }

            CGPROGRAM

            // Apparently need to add this declaration
            #pragma multi_compile_fwdbase

            #pragma vertex vert
			#pragma fragment frag
			
            // Need these files to get built-in macros
			#include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _Color;
            fixed4 _Specular;
            float _Gloss;

            struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
                SHADOW_COORDS(2)
			};

            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                // Pass shadow coordinates to pixel shader
                TRANSFER_SHADOW(o);

                return o;
            }

            fixed4 frag(v2f i): SV_Target{
                fixed3 worldNormal = normalize(i.worldNormal);
                // fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

                // Get ambient term
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                // Compute specular term
                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(worldLightDir, worldNormal));

                // Compute specular term
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 halfDir = normalize(worldLightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(halfDir, worldNormal)), _Gloss);

                // The attenuation of directional light is always 1
                // fixed atten = 1.0;

                // UNITY_LIGHT_ATTENUATION not only compute attenuation, but also shadow infos
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                return fixed4(ambient + (diffuse + specular) * atten, 1.0);
            }

            ENDCG
        }

        Pass{
            // Pass for other pixel lights
            Tags{
                "LightMode" = "ForwardAdd"
            }

            Blend One One

            CGPROGRAM

            // Apparently need to add this declaration
            #pragma multi_compile_fwdadd
            // Use the line below to add shadows for point and spot lights
//			#pragma multi_compile_fwdadd_fullshadows

            #pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

            fixed4 _Color;
			fixed4 _Specular;
			float _Gloss;

            struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				SHADOW_COORDS(2)
			};

            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
			 	TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i): SV_Target{
                fixed3 worldNormal = normalize(i.worldNormal);

                #ifdef USING_DIRECTIONAL_LIGHT
                    fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                #else
                    fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
                #endif

                // No need to add ambient term once again

                // Compute specular term
                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(worldLightDir, worldNormal));

                // Compute specular term
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 halfDir = normalize(worldLightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(halfDir, worldNormal)), _Gloss);

                // #ifdef USING_DIRECTIONAL_LIGHT
                //     fixed atten = 1.0;
                // #else
                //     #if defined (POINT)
                //         float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
                //         fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
                //     #elif defined (SPOT)
                //         float4 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1))
                //         fixed atten = (lightCoord.z > 0) * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
                //     #else
                //         fixed atten = 1.0;
                //     #endif
                // #endif

                // UNITY_LIGHT_ATTENUATION not only compute attenuation, but also shadow infos
				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                return fixed4((diffuse + specular) * atten, 1.0);
            }

            ENDCG
        }
    }
    Fallback "Specular"
}