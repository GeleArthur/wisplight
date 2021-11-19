using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class KnockBackHitter : MonoBehaviour
{
    private Vector3 _selectDir = Vector3.zero;
    private Vector3 _circlePoint = Vector3.zero;
    private Rigidbody _rigidbody;
    

    public float forceMultiplayer;
    
    void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;
        _rigidbody = GetComponent<Rigidbody>();
    }

    void Update()
    {
        if (Input.GetAxis("Mouse X") != 0 && Input.GetAxis("Mouse Y") != 0)
        {
            _selectDir = new Vector3(Input.GetAxis("Mouse X"), Input.GetAxis("Mouse Y"), 0).normalized;
        }
        
        
        if (Input.GetMouseButtonDown(0))
        {
            if (Physics.Raycast(transform.position, _selectDir, out var hitInfo, 5f))
            {
                _rigidbody.AddForce((transform.position - hitInfo.point).normalized*forceMultiplayer, ForceMode.Impulse);
            }
        }
        
    }

    private void OnDrawGizmos()
    {
        // TODO change this using a invisible circle idea <-------------
        Gizmos.DrawLine(transform.position, transform.position + _selectDir*40);
        
        // Handles.DrawWireDisc(transform.position, Vector3.back, );
    }
}
