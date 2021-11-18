using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class KnockBackHitter : MonoBehaviour
{
    private Vector3 _prevMousePos = Vector3.zero;
    private Vector3 _selectDir = Vector3.zero;
    
    void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;
    }

    void Update()
    {
        // Debug.Log(Input.mousePosition);
    }

    private void OnDrawGizmos()
    {

        // TODO change this using a invisible circle idea
        if (Input.GetAxis("Mouse X") != 0 && Input.GetAxis("Mouse Y") != 0)
        {
            _selectDir = new Vector3(Input.GetAxis("Mouse X"), Input.GetAxis("Mouse Y"), 0).normalized;
        }

        Gizmos.DrawLine(transform.position, transform.position + _selectDir*40);

        _prevMousePos = Input.mousePosition;
    }
}
