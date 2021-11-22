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

    public Vector3 clickDiraction;
    
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
            clickDiraction = GetClickDirection();
            if (Physics.Raycast(transform.position, clickDiraction, out RaycastHit hitInfo, circleRadius))
            {
                Vector3 force = -clickDiraction * forceMultiplayer;

                // Vector3 CurrentVelocity = new Vector3(
                //     force.x > _rigidbody.velocity.x ? 0 : _rigidbody.velocity.x,
                //     force.y > _rigidbody.velocity.y ? 0 : _rigidbody.velocity.y, 0);
                
                // Debug.Log(CurrentVelocity);

                // force += CurrentVelocity;
                Debug.Log(force);
                
                _rigidbody.velocity = force;
                // _rigidbody.velocity = Vector3.zero;
                // _rigidbody.AddForce(force, ForceMode.Impulse);
            }
            
        }
    }

    private Vector3 GetClickDirection()
    {
        // Calculate the angle of the point
        float anglePoint = Mathf.Atan2(_circlePoint.x, _circlePoint.y);
        // Calculate how large one piece of the circle pie
        float oneAngle = Mathf.PI * 2 / hitAngles;
        // Calculate what line on the circle 
        float angleNumber = Mathf.Floor(anglePoint/oneAngle);

        // The point is between line 1 and line +1
        float angleOne = angleNumber * oneAngle;
        float angleTwo = (angleNumber+1) * oneAngle;
        
        // Look what angle is closer to the point Select that line
        return angleOne - anglePoint > anglePoint - angleTwo ? 
            new Vector3(Mathf.Sin(angleOne), Mathf.Cos(angleOne), 0) : 
            new Vector3(Mathf.Sin(angleTwo), Mathf.Cos(angleTwo), 0);
    }

    private void OnDrawGizmos()
    {
        clickDiraction = GetClickDirection();
        if (Physics.Raycast(transform.position, clickDiraction, out RaycastHit hitInfo, circleRadius))
        {
            // Handles.color = Color.green;
            Handles.color = Input.GetMouseButton(0) ? Color.red : Color.green;
        }
        

        
        Handles.DrawSolidDisc(transform.position+_circlePoint, Vector3.back, circleRadius/10);
        Handles.DrawWireDisc(transform.position, Vector3.back, circleRadius);

        // var oneAngle = Mathf.PI * 2 / hitAngles;
        
        // Handles.color = Color.blue;
        // for (int i = 0; i < hitAngles; i++)
        // {
        //     Handles.DrawLine(transform.position, transform.position + new Vector3(Mathf.Sin(oneAngle*i)*circleRadius,Mathf.Cos(oneAngle*i)*circleRadius, 0));
        // }
        
        Debug.DrawRay(transform.position, clickDiraction*10, Color.yellow);

    }
}
