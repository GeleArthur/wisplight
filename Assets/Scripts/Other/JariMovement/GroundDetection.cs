using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class GroundDetection : MonoBehaviour, IIsGrounded
{
    public bool IsGrounded { get; set; }
    [SerializeField] private LayerMask layermask;
    [SerializeField] private Vector3 scale;
    [SerializeField] private float height;
    private CapsuleCollider c;
    private Transform loc;

    private void Start()
    {
        loc = GetComponent<Transform>();
        c = GetComponent<CapsuleCollider>();
    }

    void Update()
    {
        IsGrounded = Physics.CheckBox(loc.position + (Vector3.down * height), scale * 0.5f, Quaternion.identity,
            layermask);
    }

    private void OnDrawGizmos()
    {
        Gizmos.DrawWireCube(transform.position + (Vector3.down * height), scale);
    }

    
}
