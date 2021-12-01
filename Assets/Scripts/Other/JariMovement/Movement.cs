using System;
using System.Collections;
using System.Collections.Generic;
using System.Numerics;
using UnityEngine;
using Vector3 = UnityEngine.Vector3;

public class  Movement : MonoBehaviour
{
    [SerializeField] private ForceMode forceMode;

    private IIsGrounded groundCheck;

    private Rigidbody rb;

    public float xInput;
    public float speed;

    public Vector3 acceleration;

    public float maxVelocity;
    public float maxAcceleration;

    public float jumpForce;
    public float airControlSpeed;
    
    private void Awake()
    {
        groundCheck = GetComponent<IIsGrounded>();
        rb = GetComponent<Rigidbody>();
    }

    private void Start()
    {
        
    }

    void Update()
    {
        xInput = Input.GetAxisRaw("Horizontal") * Time.deltaTime * speed;
        if(Input.GetKeyDown(KeyCode.Space) && groundCheck.IsGrounded) Jump();
    }

    private void FixedUpdate()
    {
        if (groundCheck.IsGrounded == true && Input.GetKeyDown(KeyCode.Space) == false)
        {
           GroundMovement();
        }
        else
        {
            rb.AddForce(Vector3.right * xInput * airControlSpeed);
        }
    }

    public void GroundMovement()
    {
        acceleration = new Vector3(xInput, 0);
        
        acceleration = Vector3.ClampMagnitude(acceleration, maxAcceleration);
        acceleration /= rb.mass;
         
        rb.velocity = Vector3.ClampMagnitude(rb.velocity + acceleration, maxVelocity);
        rb.position += rb.velocity * Time.fixedDeltaTime;

        rb.position = transform.position;
    }
    
    
    void Jump()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            rb.velocity = new Vector3(rb.velocity.x, 0, rb.velocity.y);
            rb.AddForce(Vector3.up * jumpForce, forceMode);
        }
    }

   
}
