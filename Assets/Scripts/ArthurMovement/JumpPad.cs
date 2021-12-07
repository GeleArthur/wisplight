using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class JumpPad : MonoBehaviour, IKnockBack
{
    public float upForce = 40;

    public void Hit()
    {
        var playerKnockBack = GameObject.Find("Player").GetComponent<Rigidbody>();

        var newForce = transform.up * upForce;

        var x = ChangeDir(playerKnockBack.velocity.x, newForce.x);
        var y = ChangeDir(playerKnockBack.velocity.y, newForce.y);
        var z = ChangeDir(playerKnockBack.velocity.z, newForce.z);
        
        playerKnockBack.velocity = new Vector3(
            x, 
            y, 
            z);
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawLine(transform.GetComponent<Renderer>().bounds.center, transform.GetComponent<Renderer>().bounds.center+transform.up*upForce/2);
    }

    private float ChangeDir(float currentVel, float goingVel)
    {
        if ((goingVel >= 0 && currentVel > 0))
        {
            return currentVel + goingVel;
        }

        if (goingVel <= 0 && currentVel < 0)
        {
            return currentVel + goingVel;
        }

        return goingVel;
    }
}