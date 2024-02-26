Shader "Unity Shaders Book/Chapter 5/False Color"{
    SubShader{
        Pass{
            CGPROGRAM

                #pragma vertex vert
                #pragma fragment frag

                #include "UnityCG.cginc"

                struct v2f{
                    float4 pos: SV_POSITION;
                    fixed4 color: COLOR0;
                };

                // vertex shader
                // appdata_full为"UnityCG.cginc"中定义的结构体，可以用于顶点着色器的输入，包含变量：顶点位置、顶点切线、顶点法线、四组（或更多）纹理坐标
                // "UnityCG.cginc"中常用结构体详见Unity Shader入门精要 P108 表5.3
                v2f vert(appdata_full v){
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);

                    // 可视化法线方向
                    // o.color = fixed4(v.normal * 0.5 + fixed3(0.5, 0.5, 0.5), 1.0);

                    // 可视化切线方向
                    // o.color = fixed4(v.tangent * 0.5 + fixed3(0.5, 0.5, 0.5), 1.0);

                    // // 可视化副切线方向
                    // fixed3 binormal = cross(v.normal, v.tangent.xyz) * v.tangent.w;
                    // o.color = fixed4(binormal * 0.5 + fixed3(0.5, 0.5, 0.5), 1.0);

                    // // 可视化第一组纹理坐标
                    // o.color = fixed4(v.texcoord.xy, 0.0, 1.0);

                    // // 可视化第二组纹理坐标
                    o.color = fixed4(v.texcoord1.xy, 0.0, 1.0);

                    // // 可视化第一组纹理坐标的小数部分
                    // o.color = frac(v.texcoord);
                    // if(any(saturate(v.texcoord) - v.texcoord)){
                    //     o.color.b = 0.5;
                    // }
                    // o.color.a = 1.0;

                    // // 可视化第二组纹理坐标的小数部分
                    // o.color = frac(v.texcoord);
                    // if(any(saturate(v.texcoord1) - v.texcoord1)){
                    //     o.color.b = 0.5;
                    // }
                    // o.color.a = 1.0;

                    // 可视化顶点颜色
                    // o.color = v.color;

                    return o;
                }

                // fragment shader
                fixed4 frag(v2f i) : SV_Target{
                    return i.color;
                }

            ENDCG
        }
    }
}