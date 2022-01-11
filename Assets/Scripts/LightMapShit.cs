using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LightMapShit : MonoBehaviour
{
    //[SerializeField] float multiplier = 2f;
    [SerializeField] Vector2 minMax = Vector2.up;

    GameObject player;
    Light light;

    // Start is called before the first frame update
    void Start()
    {
        player = GameObject.FindGameObjectWithTag("Player");
        light = GetComponent<Light>();
    }

    // Update is called once per frame
    void Update()
    {
        RaycastHit hit;
        Physics.Raycast(transform.position, (player.transform.position - transform.position).normalized, out hit, 100f, (1 << 0), QueryTriggerInteraction.UseGlobal);

        Debug.Log(hit.transform.gameObject.GetComponent<Renderer>().lightmapIndex);

        Color color = LightmapSettings.lightmaps[hit.transform.gameObject.GetComponent<Renderer>().lightmapIndex].lightmapColor.GetPixelBilinear(hit.lightmapCoord.x, hit.lightmapCoord.y);

        light.intensity = minMax.x + color.grayscale * (minMax.y - minMax.x);
    }
}
