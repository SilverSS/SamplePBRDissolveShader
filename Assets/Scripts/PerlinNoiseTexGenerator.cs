using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

// ������ �ؽ��� ���� ��ũ��Ʈ
public class PerlinNoiseTexGenerator : MonoBehaviour
{
    public int pixWidth;
    public int pixHeight;
    public float xOrg;
    public float yOrg;

    // ������ �ؽ��� ����
    public float scale = 1.0F;

    private Texture2D noiseTex;
    private Color[] pix;
    private Renderer rend;

    private void OnEnable()
    {
        // �ٽ� ������ ������ �޸� ������ ����
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

        // ������ ������ ���� ����
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
