using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class KnockBackHitter : MonoBehaviour
{
    private Vector3 _circlePoint = Vector3.zero;
    private Rigidbody _rigidbody;

    public float circleRadius = 5;

    public float forceMultiplayer;
    
    void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;
        _rigidbody = GetComponent<Rigidbody>();
    }

    void Update()
    {
        _circlePoint += new Vector3(Input.GetAxis("Mouse X"), Input.GetAxis("Mouse Y"), 0);

        if (Vector3.Distance(_circlePoint, Vector3.zero) > circleRadius)
        {
            _circlePoint = _circlePoint.normalized * circleRadius;
        }

        if (Input.GetMouseButtonDown(0))
        {
            if (Physics.Raycast(transform.position, _circlePoint, out var hitInfo, 5f))
            {
                _rigidbody.velocity = Vector3.zero;
                _rigidbody.AddForce((transform.position - hitInfo.point).normalized*forceMultiplayer, ForceMode.Impulse);
            }
        }

    }

    private void OnDrawGizmos()
    {
        Handles.color = Input.GetMouseButton(0) ? Color.red : Color.white;
        
        Handles.DrawSolidDisc(transform.position+_circlePoint, Vector3.back, circleRadius/10);
        Handles.DrawWireDisc(transform.position, Vector3.back, circleRadius);
    }
}
