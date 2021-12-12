using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShadowProjector : MonoBehaviour
{
    public Transform player;
    public LayerMask layers;
    
    // Start is called before the first frame update
    void Start()
    {
        player = transform.parent;
    }

    // Update is called once per frame
    void Update()
    {
        if (Physics.SphereCast(player.position, 0.5f, Vector3.down, out var hitInfo, Single.MaxValue, layers))
        {
            transform.position = hitInfo.point - new Vector3(0, 4, 0);
        }
    }
}
