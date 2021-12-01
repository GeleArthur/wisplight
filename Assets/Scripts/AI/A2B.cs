using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class A2B : MonoBehaviour
{
    [SerializeField] private Transform a, b;
    [SerializeField] private float _speed;
    float _time;
    private bool _reverse;
    [SerializeField] private float reachedDestinationDist;
    [SerializeField] private float friction = 0.25f;

    private Rigidbody rb;

    private float _xInput;

    private void Awake()
    {
        rb = GetComponent<Rigidbody>();
    }

    void Start()
    {
        _speed *= .5f;
    }

    private void Update()
    {
        _xInput = Input.GetAxisRaw("Horizontal");
    }

    void FixedUpdate()
    {
        _time += _speed * Time.deltaTime;
        if (_reverse == true)
        {
            var bDist = Vector3.Distance(transform.position, b.position);
            transform.position = Vector3.Lerp(a.position, b.position, _time);
            if (bDist <= reachedDestinationDist) _reverse = false;
            if (_time >= 1f) _time = 0;
        }
        else
        {
            var bDist = Vector3.Distance(transform.position, a.position);
            transform.position = Vector3.Lerp(b.position, a.position, _time);
            if (bDist <= reachedDestinationDist) _reverse = true;
            if (_time >= 1f) _time = 0;
        }

    } 
    //rb.velocity = Vector3.Lerp(rb.velocity, movementDirection, friction);
    private void OnDrawGizmos()
    {
        Handles.DrawWireDisc(transform.position, Vector3.forward, reachedDestinationDist);
    }
}
