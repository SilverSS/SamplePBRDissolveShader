using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DissolveLevelController : MonoBehaviour
{
    public float repeatCycle = 2.0f;
    Material mat;
    // Start is called before the first frame update
    void Start()
    {
        mat = GetComponent<Renderer>().material;
        StartCoroutine(RepeatDissolveLevel());
    }

    IEnumerator RepeatDissolveLevel()
    {
        float elpasedTime = 0f;
        while(true)
        {
            float level = (Mathf.Sin(elpasedTime / repeatCycle * 2) + 1f) * 0.5f;
            mat.SetFloat("_Level", level);
            elpasedTime += Time.deltaTime;
            yield return null;
        }
    }
}
