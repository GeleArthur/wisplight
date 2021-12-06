using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class JumpPad : MonoBehaviour, IKnockBack
{
    public Vector3 Hit()
    {
        return Vector3.up*30;
    }

    private void OnDrawGizmos()
    {
        
    }
}
