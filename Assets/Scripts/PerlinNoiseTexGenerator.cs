using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

// 노이즈 텍스쳐 생성 스크립트
public class PerlinNoiseTexGenerator : MonoBehaviour
{
    public int pixWidth;
    public int pixHeight;
    public float xOrg;
    public float yOrg;

    // 노이즈 텍스쳐 배율
    public float scale = 1.0F;

    private Texture2D noiseTex;
    private Color[] pix;
    private Renderer rend;

    private void OnEnable()
    {
        // 다시 보여질 때마다 펄린 노이즈 갱신
        rend = GetComponent<Renderer>();

        if (noiseTex == null)
            noiseTex = new Texture2D(pixWidth, pixHeight);

        if (pix == null)
            pix = new Color[noiseTex.width * noiseTex.height];

        rend.material.SetTexture("_NoiseTex", noiseTex);

        CalcNoise();
    }

    public void CalcNoise()
    {
        float y = 0.0F;

        // 노이즈 오프셋 랜덤 생성
        xOrg = Random.Range(-50f, 50f);
        yOrg = Random.Range(-50f, 50f);

        while (y < noiseTex.height)
        {
            float x = 0.0F;
            while (x < noiseTex.width)
            {
                float xCoord = xOrg + x / noiseTex.width * scale;
                float yCoord = yOrg + y / noiseTex.height * scale;
                float sample = Mathf.PerlinNoise(xCoord, yCoord);
                int pixelIndex = (int)(y * noiseTex.width + x);
                pix[pixelIndex] = new Color(sample, sample, sample);
                x++;
            }
            y++;
        }
        noiseTex.SetPixels(pix);
        noiseTex.Apply();
    }
}
