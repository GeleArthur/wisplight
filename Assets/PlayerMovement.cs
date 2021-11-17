using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    private float XInput;
    private Rigidbody rb;
    public float walkSpeed = 750;
    public float friction = 0.25f;
    
    private void Start()
    {
        rb = GetComponent<Rigidbody>();
    }

    void Update()
    {
        XInput = Input.GetAxisRaw("Horizontal");
    }

    private void FixedUpdate()
    {
        Vector3 movementDirection = new Vector3(XInput * walkSpeed * Time.deltaTime, 0, 0);

        rb.velocity = Vector3.Lerp(rb.velocity, movementDirection, friction);
    }
}
