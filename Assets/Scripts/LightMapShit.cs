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
        characterLight.intensity = GetLightLevel();
    }

    // Update is called once per frame
    void Update()
    {
        float grayscale = GetLightLevel();

        characterLight.intensity = Mathf.MoveTowards(characterLight.intensity, minMax.x + grayscale * (minMax.y - minMax.x), Time.deltaTime * changeSpeed * (minMax.y - minMax.x));
    }

    float GetLightLevel()
    {
        RaycastHit hit;
        Physics.Raycast(Camera.main.transform.position, (player.transform.position - Camera.main.transform.position).normalized, out hit, 100f, (1 << 0), QueryTriggerInteraction.UseGlobal);

        if (hit.transform == null)
            return 0f;


        Renderer r = hit.transform.gameObject.GetComponent<Renderer>();
        if (r == null || r.lightmapIndex == -1)
            return 0f;

        // Debug.Log($"{hit.transform.gameObject.GetComponent<Renderer>().lightmapIndex}   {hit.lightmapCoord}");

        return LightmapSettings.lightmaps[hit.transform.gameObject.GetComponent<Renderer>().lightmapIndex].lightmapColor.GetPixelBilinear(hit.lightmapCoord.x, hit.lightmapCoord.y).grayscale;
    }
}