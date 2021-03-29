using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DissolveLevelController : MonoBehaviour
{
    public float repeatCycle = 2.0f;
    float elapsedTime = 0f;
    Material mat;
    // Start is called before the first frame update
    void Start()
    {
        elapsedTime = 0f;
        mat = GetComponent<Renderer>().material;
    }

    private void Update()
    {
        mat.SetFloat("_Level", (Mathf.Sin(elapsedTime / repeatCycle * 2f) + 1f) * 0.5f);
        elapsedTime += Time.deltaTime;
    }
}
