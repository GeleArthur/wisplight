using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GroundCheck : MonoBehaviour
{
    public bool onGround;
    
    private void OnTriggerEnter(Collider other)
    {
        onGround = true;
    }

    private void OnTriggerExit(Collider other)
    {
        onGround = false;
    }
}
