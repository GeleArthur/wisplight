using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class A2B : MonoBehaviour
{
    [SerializeField] private Transform[] waypoints;
    private int waypointIndex;
    [SerializeField] private float _speed;
    [SerializeField] private float reachedDestinationDist;
    
    bool _reverse;
    float _time;

    private Rigidbody rb;

    private void Awake()
    {
        waypointIndex = 0;
        rb = GetComponent<Rigidbody>();
    }

    private void Update()
    {
        if (ToNextWaypoint(waypoints[waypointIndex]))
        {
            _speed = -_speed;
            waypointIndex++;
        }
    }

    void FixedUpdate()
    {
       
    }


    private bool ToNextWaypoint(Transform dest)
    {
        if (Vector3.Distance(transform.position, dest.position) <= reachedDestinationDist) return true;
        return false;
    }
    

   

   
#if UNITY_EDITOR

    
    private void OnDrawGizmos()
    {
        Handles.DrawWireDisc(transform.position, Vector3.forward, reachedDestinationDist);
    }
#endif
}
