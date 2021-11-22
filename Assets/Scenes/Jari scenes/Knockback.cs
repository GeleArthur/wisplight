using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class Knockback : MonoBehaviour
{
    public string wallTagName;
    
    private Camera cam;
    private Rigidbody rb;
    private Vector3 dir;

    public float explosionForce;

    public float upwardForce;
    public float explosionRadius;
    public float checkDistance;

    public LayerMask LayerMask;

    private IIsGrounded groundCheck;
    
    private void Awake()
    {
        groundCheck = GetComponent<IIsGrounded>();
        rb = GetComponent<Rigidbody>();

    }

    void Start()
    {
        cam = Camera.main;
    }

    private void Update()
    {
       
        KnockbackAction(WallCheck());
    }

    public Vector3 MouseDirection()
    {
        dir = Input.mousePosition - cam.WorldToScreenPoint(transform.position);
        dir.z = 0;
        return dir;
    }

    public RaycastHit WallCheck()
    {
        MouseDirection();
        Ray ray = new Ray(transform.position, dir);
        Physics.Raycast(ray,out RaycastHit hit, checkDistance, LayerMask);
        return hit;
    }

    public void KnockbackAction(RaycastHit check)
    {
        if(check.collider == null) return;
        if (Input.GetMouseButtonDown(0))
        {
            //rb.AddExplosionForce(explosionForce, check.point, explosionRadius, upwardForce);
            //rb.AddForce(dir.x * -explosionForce, (dir.y + upwardForce) * -explosionForce, 0);
            rb.velocity = new Vector3(dir.x * -explosionForce, (dir.y + upwardForce) * -explosionForce, 0);
            
        }
    }
    

    private void OnDrawGizmos()
    {
        Gizmos.DrawRay(transform.position, dir.normalized * checkDistance);
        if(cam == null) return;
            Gizmos.color = Color.red;
            Gizmos.DrawSphere(WallCheck().point, 0.1f);
            Handles.DrawWireDisc(WallCheck().point, Vector3.forward, explosionRadius);
    }
    
    
}
