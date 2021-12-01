﻿using UnityEngine;


public class BroomMover : MonoBehaviour
{
    public float _broomReduced = 0;
    public float timerSUTFF;
    
    public Vector3 broomPoint = Vector3.zero;
    public float circleRadius = 2.44f;
    public GameObject broomModel;
    
    void Update()
    {
        broomPoint = PatrickDirection() * circleRadius;
        _broomReduced = Mathf.MoveTowards(_broomReduced, 0, timerSUTFF * Time.deltaTime);
        SetBroom();
    }

    private Vector3 PatrickDirection()
    {
        Vector2 dir = new Vector2(Input.GetAxis("Mouse X"), Input.GetAxis("Mouse Y"));
        if (Application.platform == RuntimePlatform.WebGLPlayer) dir *= 0.1f;

        float speed = dir.magnitude;
        dir.Normalize();
        float tAngle = Vector2.SignedAngle(Vector2.up, dir);
        float cAngle = Vector2.SignedAngle(Vector2.up, broomPoint.normalized);
        float rAngle = Mathf.MoveTowardsAngle(cAngle, tAngle, speed * 10f);
        return Quaternion.Euler(0f, 0f, rAngle) * Vector3.up;
    }

    private void SetBroom()
    {
        Vector3 broomLocalPos;
        if (Physics.Raycast(transform.position, broomPoint, out var hitInfo, circleRadius))
        {
            broomLocalPos = transform.InverseTransformPoint(new Vector3(hitInfo.point.x, hitInfo.point.y, -0.5f));
        }
        else
        {
            broomLocalPos = broomPoint;
        }

        broomLocalPos = broomLocalPos.normalized * (broomLocalPos.magnitude + _broomReduced);
        
        broomModel.transform.localPosition = broomLocalPos;
        broomModel.transform.rotation = Quaternion.Euler(0,0, 180-Mathf.Atan2(broomPoint.x, broomPoint.y)*Mathf.Rad2Deg);
    }

    public void BroomHit()
    {
        _broomReduced = 1;
    }
}