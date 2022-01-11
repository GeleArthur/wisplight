using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LightMapShit : MonoBehaviour
{
    [SerializeField] Vector2 minMax = Vector2.up;
    [SerializeField] float changeSpeed = 1f;

    GameObject player;
    Light characterLight;

    // Start is called before the first frame update
    void Start()
    {
        player = GameObject.FindGameObjectWithTag("Player");
        characterLight = GetComponent<Light>();
    }

    // Update is called once per frame
    void Update()
    {
        RaycastHit hit;
        Physics.Raycast(Camera.main.transform.position, (player.transform.position - Camera.main.transform.position).normalized, out hit, 100f, (1 << 0), QueryTriggerInteraction.UseGlobal);

        float grayscale = LightmapSettings.lightmaps[hit.transform.gameObject.GetComponent<Renderer>().lightmapIndex].lightmapColor.GetPixelBilinear(hit.lightmapCoord.x, hit.lightmapCoord.y).grayscale;

        characterLight.intensity = Mathf.MoveTowards(characterLight.intensity, minMax.x + grayscale * (minMax.y - minMax.x), Time.deltaTime * changeSpeed * (minMax.y - minMax.x));
    }
}
