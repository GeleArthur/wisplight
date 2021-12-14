using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShadowProjector : MonoBehaviour
{
    public Transform player;
    public LayerMask layers;
    public float offset;

    private Vector3 castPos1;
    private Vector3 castPos2;

    // Start is called before the first frame update
    void Start()
    {
        if(player == null)
            player = transform.parent;
    }

    // Update is called once per frame
    void Update()
    {
        Bounds bounds = player.GetComponent<PlayerMovement>().characterModel.GetComponent<Renderer>().bounds;

        castPos1 = player.position + new Vector3(bounds.size.x / 2f, -bounds.size.y / 2f + 0.1f, 0);
        bool cast1 = Physics.Raycast(castPos1,
            Vector3.down, out RaycastHit hitInfo1, Single.MaxValue, layers);

        castPos2 = player.position + new Vector3(-bounds.size.x / 2f, -bounds.size.y / 2f + 0.1f, 0);
        bool cast2 = Physics.Raycast(castPos2,
            Vector3.down, out RaycastHit hitInfo2, Single.MaxValue, layers);

        float shadowLength = 0;

        if (cast1 == true) shadowLength = hitInfo1.distance;
        if (cast2 == true && hitInfo2.distance < shadowLength) shadowLength = hitInfo2.distance;

        transform.localScale = new Vector3(transform.localScale.x, transform.localScale.y, shadowLength);
        transform.position = player.position - new Vector3(0, bounds.size.y / 2f, 0) - new Vector3(0, shadowLength / 2-offset, 0);

        // if (Physics.Raycast(player.position, Vector3.down, out var hitInfo, Single.MaxValue, layers))
        // {
        //     transform.position = hitInfo.point - new Vector3(0, 4, 0);
        // }
    }

#if UNITY_EDITOR
    private void OnDrawGizmos()
    {
        if(player == null)
            player = transform.parent;
        Bounds wut = player.GetComponent<PlayerMovement>().characterModel.GetComponent<Renderer>().bounds;

        Gizmos.DrawRay(castPos1, Vector3.down);
        Gizmos.DrawRay(castPos2, Vector3.down);
    }
#endif
}