using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UseWalkParticle : MonoBehaviour
{
    private ParticleSystem walkParticle;
    private GroundCheck groundCheck;
    
    void Awake()
    {
        walkParticle = GetComponentInChildren<ParticleSystem>();
        groundCheck = GetComponentInChildren<GroundCheck>();
    }

    void Update()
    {
        if (groundCheck.onGround)
        {
            walkParticle.gameObject.SetActive(true);
        }
        else
        {
            walkParticle.gameObject.SetActive(false);
        }
    }
}
