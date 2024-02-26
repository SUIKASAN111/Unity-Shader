// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unity Shaders Book/Chapter 6/Diffuse Vertex-Level"
{
    Properties{
        _Diffuse("Diffuse", Color) = (1, 1, 1, 1)
    }

    SubShader{
        Pass{
            // LightMode标签是Pass标签中的一种，用于定义该Pass在Unity光照流水线中的角色
            // 只有定义了正确的LightMode，才能得到Unity内置的光照变量
            Tags{
                "LightMode" = "ForwardBase"
            }

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            // 包含内置光照变量文件
            #include "Lighting.cginc"

            // 为了在Shader中使用Properties语义块中声明的属性，需要定义一个和该属性类型相匹配的变量
            fixed4 _Diffuse;

            // application to vertex shader
            struct a2v{
                float4 vertex: POSITION;
                float3 normal: NORMAL;
            };
            // vertex shader to fragment shader
            struct v2f{
                float4 pos: SV_POSITION;
                fixed3 color: COLOR;
            };

            // vertex shader
            v2f vert(a2v v){
                v2f o;
                // Transform the vertex from object-space to projection-space
                o.pos = UnityObjectToClipPos(v.vertex);

                // Get ambient term
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                // Transform the normal from object-space to world-space
                // fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                fixed3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                // Get the light direction in world-space
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                // fixed3 worldLight = normalize(UnityWorldSpaceLightDir(float3(0,0,0)));
                // Compute diffuse term
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));

                o.color = ambient + diffuse;

                return o;
            }

            // fragment shader
            fixed4 frag(v2f i): SV_Target{
                return fixed4(i.color, 1.0);
            }

            ENDCG
        }
    }

    Fallback "Diffuse"
}