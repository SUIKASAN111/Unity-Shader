using System.Collections;
using System.ComponentModel;
using System.Net.Mail;
using System.Threading;
using Unity.Burst;
using Unity.VisualScripting;
using UnityEngine;

public class GaussianBlur : PostEffectsBase
{
    public Shader gaussianBlurShader;
    private Material gaussianBlurMaterial = null;

    public Material material{
        get{
            gaussianBlurMaterial = CheckShaderAndCreateMaterial(gaussianBlurShader, gaussianBlurMaterial);
            return gaussianBlurMaterial;
        }
    }

    // Blur iterations - larger number means more blur
    [Range(0, 4)]
    public int iteration = 3;

    // Blur spread for each iteration - larger value means more blur
    [Range(0.2f, 3.0f)]
    public float blurSpread = 0.6f;

    [Range(1, 8)]
    public int downSample = 2;

    // 1st edition: just apply blur
    // void OnRenderImage(RenderTexture src, RenderTexture dest){
    //     if(material != null){
    //         int rtW = src.width;
    //         int rtH = src.height;
    //         RenderTexture buffer = RenderTexture.GetTemporary(rtW, rtH, 0);

    //         // Render the vertical pass
    //         Graphics.Blit(src, buffer, material, 0);
    //         // Render the horizontal pass
    //         Graphics.Blit(buffer, dest, material, 1);

    //         RenderTexture.ReleaseTemporary(buffer);
    //     }
    //     else{
    //         Graphics.Blit(src, dest);
    //     }
    // }

    // 2nd edition: scale the render texture
    // void OnRenderImage(RenderTexture src, RenderTexture dest){
    //     if(material != null){
    //         int rtW = src.width / downSample;
    //         int rtH = src.height / downSample;
    //         RenderTexture buffer = RenderTexture.GetTemporary(rtW, rtH, 0);
    //         buffer.filterMode = FilterMode.Bilinear;

    //         // Render the vertical pass
	// 		Graphics.Blit(src, buffer, material, 0);
	// 		// Render the horizontal pass
	// 		Graphics.Blit(buffer, dest, material, 1);

	// 		RenderTexture.ReleaseTemporary(buffer);

    //     }
    //     else{
    //         Graphics.Blit(src, dest);
    //     }
    // }

    // 3rd edition: use iterations for larger blur
    void OnRenderImage(RenderTexture src, RenderTexture dest){
        if(material != null){
            int rtW = src.width / downSample;
            int rtH = src.height / downSample;
            RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
            buffer0.filterMode = FilterMode.Bilinear;

            Graphics.Blit(src, buffer0);

            for(int i = 0; i < iteration; ++i){
                material.SetFloat("_BlurSize", 1.0f + i * blurSpread);

                RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                // Render the vertical pass
                Graphics.Blit(buffer0, buffer1, material, 0);
                buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);

                // Render the horizontal pass
                Graphics.Blit(buffer1, buffer0, material, 1);
                RenderTexture.ReleaseTemporary(buffer1);
            }

            Graphics.Blit(buffer0, dest);
            RenderTexture.ReleaseTemporary(buffer0);
        }
        else{
            Graphics.Blit(src, dest);
        }
    }
}
