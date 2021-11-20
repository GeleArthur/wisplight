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
    public int hitAngles = 4;

    public float forceMultiplayer;

    public Vector3 newdir;
    
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
            _rigidbody.AddForce(GetKnockBackForce(), ForceMode.Impulse);
        }
    }

    private Vector3 GetKnockBackForce()
    {
        _rigidbody.velocity = Vector3.zero;

        float anglePoint = Mathf.Atan2(_circlePoint.x, _circlePoint.y);
        float oneAngle = Mathf.PI * 2 / hitAngles;
        float angleNumber = Mathf.Floor(anglePoint/oneAngle);

        float angleOne = angleNumber * oneAngle;
        float angleTwo = (angleNumber+1) * oneAngle;
        
        Debug.Log(angleOne - anglePoint);
        Debug.Log(anglePoint - angleTwo);
        if (angleOne - anglePoint > anglePoint - angleTwo)
        {
            newdir = new Vector3(Mathf.Sin(angleOne), Mathf.Cos(angleOne), 0);
        }
        else
        {
            newdir = new Vector3(Mathf.Sin(angleTwo), Mathf.Cos(angleTwo), 0);
        }
        
        // Debug.Log(angleNumber);
        
        // if (Physics.Raycast(transform.position, newdir, out RaycastHit hitInfo, 5f))
        // {
        //     return (transform.position - hitInfo.point).normalized * forceMultiplayer;
        // }
        
        
        return Vector3.zero;
    }

    private void OnDrawGizmos()
    {
        Handles.color = Input.GetMouseButton(0) ? Color.red : Color.white;
        
        Handles.DrawSolidDisc(transform.position+_circlePoint, Vector3.back, circleRadius/10);
        Handles.DrawWireDisc(transform.position, Vector3.back, circleRadius);

        var oneAngle = Mathf.PI * 2 / hitAngles;
        
        Handles.color = Color.blue;
        for (int i = 0; i < hitAngles; i++)
        {
            Handles.DrawLine(transform.position, transform.position + new Vector3(Mathf.Sin(oneAngle*i)*circleRadius,Mathf.Cos(oneAngle*i)*circleRadius, 0));
        }
        
        Debug.DrawRay(transform.position, newdir*10, Color.yellow);

    }
}
