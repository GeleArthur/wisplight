using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bullet : MonoBehaviour, IKnockBack
{
    [SerializeField] private float speed;
    
    private Rigidbody rb;
    public Vector3 dir;
    
    private void Awake()
    {
        rb = GetComponent<Rigidbody>();
    }
    
    void FixedUpdate()
    {
        rb.position += dir.normalized * speed;
    }

    private void OnTriggerEnter(Collider other)
    {
        Destroy(gameObject, 5f);
    }

    public void Hit()
    {
        var playerKnockback = GameObject.FindGameObjectWithTag("Player").GetComponent<KnockBackHitter>();
        dir = playerKnockback._circlePoint;
    }
}
