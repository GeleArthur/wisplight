using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class KnockBackHitter : MonoBehaviour
{
    private Vector3 _circlePoint = Vector3.zero;
    private Vector3 _clickDirection;
    private Rigidbody _rigidbody;
    private long _timeUntilClick;
    public GameObject circlePointGm;
    public GameObject circleStrokeGm;
    
    public float circleRadius = 5;
    public int hitAngles = 4;
    public float forceMultiplayer;
    public int waitTimeMilliseconds;

    void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;
        _rigidbody = GetComponent<Rigidbody>();
    }

    void Update()
    {
        _circlePoint = PatrickDirection() * circleRadius;
        

        if (Input.GetMouseButtonDown(0))
        {
            _timeUntilClick = DateTime.Now.Ticks + waitTimeMilliseconds * TimeSpan.TicksPerMillisecond;
        }

        if (_timeUntilClick > DateTime.Now.Ticks)
        {
            _clickDirection = GetClickDirection();
            
            if (Physics.Raycast(transform.position, _clickDirection, out RaycastHit hitInfo, circleRadius))
            {
                _timeUntilClick = DateTime.Now.Ticks;

                IKnockBack specialHit = hitInfo.transform.GetComponent<IKnockBack>();
                if (specialHit != null)
                {
                    specialHit.Hit();
                    return;
                }

                Vector3 force = -_clickDirection * forceMultiplayer;

                // Add velocity of player if it doesn't want to change direction
                float x = 0;
                if (_rigidbody.velocity.x > 0 && force.x > 0 ||
                    _rigidbody.velocity.x < 0 && force.x < 0 ||
                    Mathf.Abs(force.x) < 0.000000001f
                )
                {
                    x = _rigidbody.velocity.x;
                }

                force += new Vector3(x, 0, 0);

                _rigidbody.velocity = force;
            }
        }

        UpdateFakeGizmos();
    }

    private Vector3 GetClickDirection()
    {
        // Calculate the angle of the point
        float anglePoint = Mathf.Atan2(_circlePoint.x, _circlePoint.y);
        // Calculate how large one piece of the circle pie
        float oneAngle = Mathf.PI * 2 / hitAngles;
        // Calculate what line on the circle
        float angleNumber = Mathf.Floor(anglePoint / oneAngle);

        // The point is between line 1 and line +1
        float angleOne = angleNumber * oneAngle;
        float angleTwo = (angleNumber + 1) * oneAngle;

        // Look what angle is closer to the point Select that line
        return angleOne - anglePoint > anglePoint - angleTwo ?
            new Vector3(Mathf.Sin(angleOne), Mathf.Cos(angleOne), 0) :
            new Vector3(Mathf.Sin(angleTwo), Mathf.Cos(angleTwo), 0);
    }

    private void UpdateFakeGizmos()
    {
        circlePointGm.transform.localPosition = _circlePoint;
        Vector3 clickDirectionGiz = GetClickDirection();
        if (Physics.Raycast(transform.position, clickDirectionGiz, out RaycastHit hitInfo, circleRadius))
        {
            circlePointGm.GetComponent<MeshRenderer>().material.color = Input.GetMouseButton(0) ? Color.red : Color.green;
            circleStrokeGm.GetComponent<MeshRenderer>().material.color = Input.GetMouseButton(0) ? Color.red : Color.green;
        }
        else
        {
            circlePointGm.GetComponent<MeshRenderer>().material.color = Color.white;
            circleStrokeGm.GetComponent<MeshRenderer>().material.color = Color.white;
        }
    }


    private Vector3 PatrickDirection()
    {
        Vector2 dir = new Vector2(Input.GetAxis("Mouse X"), Input.GetAxis("Mouse Y"));
        if (Application.platform == RuntimePlatform.WebGLPlayer) dir *= 0.1f;

        float speed = dir.magnitude;
        dir.Normalize();
        float tAngle = Vector2.SignedAngle(Vector2.up, dir);
        float cAngle = Vector2.SignedAngle(Vector2.up, _circlePoint.normalized);
        float rAngle = Mathf.MoveTowardsAngle(cAngle, tAngle, speed * 10f);
        //if(speed > 0)
        // Debug.Log($"{tAngle}");
        /*{cAngle} => {tAngle} = {rAngle} */
        return Quaternion.Euler(0f, 0f, rAngle) * Vector3.up;
    }

#if UNITY_EDITOR
    private void OnDrawGizmos()
    {
        var clickDirectionGiz = GetClickDirection();
        if (Physics.Raycast(transform.position, clickDirectionGiz, out RaycastHit hitInfo, circleRadius))
        {
            Handles.color = Input.GetMouseButton(0) ? Color.red : Color.green;
        }

        Handles.DrawSolidDisc(transform.position + _circlePoint, Vector3.back, circleRadius / 10);
        Handles.DrawWireDisc(transform.position, Vector3.back, circleRadius, 3f);

        // var oneAngle = Mathf.PI * 2 / hitAngles;

        // Handles.color = Color.blue;
        // for (int i = 0; i < hitAngles; i++)
        // {
        //     Handles.DrawLine(transform.position, transform.position + new Vector3(Mathf.Sin(oneAngle*i)*circleRadius,Mathf.Cos(oneAngle*i)*circleRadius, 0));
        // }

        Debug.DrawRay(transform.position, _clickDirection * 10, Color.yellow);

    }
#endif
}
