using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    private float XInput;
    private Rigidbody rb;

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
        rb.AddForce(new Vector3(XInput,0,0),ForceMode.Acceleration);
    }
}
