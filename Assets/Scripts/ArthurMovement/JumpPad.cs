using System;
using System.Collections;
using System.Collections.Generic;
using Unity.Mathematics;
using UnityEditor;
using UnityEngine;

public class JumpPad : MonoBehaviour, IKnockBack
{
    [SerializeField] private GameObject hitParticles;
    [SerializeField] private float showParticleDuration;
    
    public float upForce = 40;

    private void Start()
    {
        hitParticles.SetActive(false);
    }

    public void Hit()
    {
        var playerKnockBack = GameObject.Find("Player").GetComponent<Rigidbody>();

        StartCoroutine(ShowParticles());
        
        var newForce = transform.up * upForce;

        var x = ChangeDir(playerKnockBack.velocity.x, newForce.x);
        var y = ChangeDir(playerKnockBack.velocity.y, newForce.y);
        var z = ChangeDir(playerKnockBack.velocity.z, newForce.z);
        
        playerKnockBack.velocity = new Vector3(x, y, z);
        AudioManager.instance.Play("Boost");
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawLine(transform.GetComponent<Renderer>().bounds.center, transform.GetComponent<Renderer>().bounds.center+transform.up*upForce/2);
    }

    IEnumerator ShowParticles()
    {
        hitParticles.SetActive(true);
        yield return new WaitForSeconds(showParticleDuration);
        hitParticles.SetActive(false);

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
