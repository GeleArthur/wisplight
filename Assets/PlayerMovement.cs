using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    private float XInput;
    private Rigidbody rb;
    private GroundCheck GC;
    public float walkSpeed = 750;
    [Range(0,1)]
    public float friction = 0.25f;

    public float jumpPower = 3;
    public float jumpMultiplier = 1;
    
    private void Start()
    {
        rb = GetComponent<Rigidbody>();
        rb.solverIterations *= 5;
        rb.solverVelocityIterations *= 5;
        GC = GetComponentInChildren<GroundCheck>();

        // -9.81
        // Physics.gravity = new Vector3(0, -40, 0);
    }

    void Update()
    {
        XInput = Input.GetAxisRaw("Horizontal");
        if (Input.GetKeyDown(KeyCode.Space) && GC.onGround) Jump();
    }

    private void FixedUpdate()
    {
        Vector3 movementDirection = new Vector3(XInput * walkSpeed * Time.deltaTime, rb.velocity.y, 0);

        rb.velocity = Vector3.Lerp(rb.velocity, movementDirection, friction);
    }

    private void Jump()
    {
        rb.velocity = new Vector3(rb.velocity.x, 0, rb.velocity.y);
        rb.AddForce(Vector3.up * jumpPower * jumpMultiplier);
    }
}
