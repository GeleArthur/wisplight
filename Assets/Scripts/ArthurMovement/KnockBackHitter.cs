using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class KnockBackHitter : MonoBehaviour
{
    private BroomMover _broomMover;
    private Vector3 _clickDirection;
    private Rigidbody _rigidbody;
    private long _timeUntilClick;
    public GameObject circlePointGm;
    public GameObject circleStrokeGm;
    
    public int hitAngles = 16;
    public float forceMultiplayer;
    public int waitTimeMilliseconds;

    void Start()
    {
        _rigidbody = GetComponent<Rigidbody>();
        _broomMover = GetComponent<BroomMover>();
        Cursor.lockState = CursorLockMode.Locked;
    }

    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            _broomMover.BroomHit();
            _timeUntilClick = DateTime.Now.Ticks + waitTimeMilliseconds * TimeSpan.TicksPerMillisecond;
        }

        if (_timeUntilClick > DateTime.Now.Ticks)
        {
            _clickDirection = GetClickDirection();
            
            if (Physics.Raycast(transform.position, _clickDirection, out RaycastHit hitInfo, _broomMover.circleRadius))
            {
                _timeUntilClick = 0;
                
                IKnockBack specialHit = hitInfo.transform.GetComponent<IKnockBack>();
                if (specialHit != null)
                {
                    // specialHit.Hit();
                    return;
                }

                Vector3 force = -_clickDirection * forceMultiplayer;

                // Add velocity of player if it doesn't want to change direction
                float x = 0;
                if (_rigidbody.velocity.x > 0 && force.x > 0 ||
                    _rigidbody.velocity.x < 0 && force.x < 0 ||
                    Mathf.Abs(force.x) < 0.001f
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
        float anglePoint = Mathf.Atan2(_broomMover.broomPoint.x, _broomMover.broomPoint.y);
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
        circlePointGm.transform.localPosition = _broomMover.broomPoint;
        Vector3 clickDirectionGiz = GetClickDirection();
        if (Physics.Raycast(transform.position, clickDirectionGiz, out RaycastHit hitInfo, _broomMover.circleRadius))
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

#if UNITY_EDITOR
    private void OnDrawGizmos()
    {
        if(_broomMover == null) _broomMover = GetComponent<BroomMover>();

        var clickDirectionGiz = GetClickDirection();
        if (Physics.Raycast(transform.position, clickDirectionGiz, out RaycastHit hitInfo, _broomMover.circleRadius))
        {
            Handles.color = Input.GetMouseButton(0) ? Color.red : Color.green;
        }

        Handles.DrawSolidDisc(transform.position + _broomMover.broomPoint, Vector3.back, _broomMover.circleRadius / 10);
        Handles.DrawWireDisc(transform.position, Vector3.back, _broomMover.circleRadius, 3f);

        Debug.DrawRay(transform.position, _clickDirection * 10, Color.yellow);

    }
#endif
}
