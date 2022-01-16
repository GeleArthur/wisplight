using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class PlayerMovement : MonoBehaviour
{
    private float _xInput;
    private Rigidbody _rigidbody;
    private GroundCheck _groundCheck;
    private Vector3 _airDirection;
    
    public float walkSpeed = 750;
    [Range(0,1)]
    public float friction = 0.25f;
    public float jumpPower = 3;
    public float jumpMultiplier = 1;
    public float airAcceleration = 6000;
    public GameObject characterModel;

    private Vector3 _startPoint;


    private void Start()
    {
        _rigidbody = GetComponent<Rigidbody>();
        _rigidbody.solverIterations *= 5;
        _rigidbody.solverVelocityIterations *= 5;
        _groundCheck = GetComponentInChildren<GroundCheck>();

        _startPoint = transform.position;
        
        // -9.81
        Physics.gravity = new Vector3(0, -40, 0);
    }

    void Update()
    {
        _xInput = Input.GetAxisRaw("Horizontal");
        // if (Input.GetKeyDown(KeyCode.Space) && _groundCheck.onGround) Jump();

        if(characterModel == null) return;
        if (Mathf.Abs(_rigidbody.velocity.x) < 0.01f)
        {
            characterModel.transform.rotation = Quaternion.Euler(0, 180, 0);
        }
        else if(_rigidbody.velocity.x > 0)
        {
            characterModel.transform.rotation = Quaternion.Euler(0, 90, 0);
        }
        else
        {
            characterModel.transform.rotation = Quaternion.Euler(0, -90, 0);
        }
        
       
    }

    
    
    private void FixedUpdate()
    {
        Vector3 movementDirection = new Vector3(_xInput * walkSpeed * Time.deltaTime, _rigidbody.velocity.y, 0);

        // If we are not moving we don't slide on slope. WHY? turn this off and go on a slope
        if (movementDirection.x == 0 && _groundCheck.onGround && _rigidbody.velocity.y < 0.00001)
            _rigidbody.useGravity = false;
        else
            _rigidbody.useGravity = true;

        if (_groundCheck.onGround)
        {
            _rigidbody.velocity = Vector3.Lerp(_rigidbody.velocity, movementDirection, friction);
        }
        else if(!_groundCheck.onGround)
        {
            // Prevent from going faster then possible
            _airDirection.x =
                (movementDirection.x > 0f && this._rigidbody.velocity.x < movementDirection.x) ||
                (movementDirection.x < 0f && this._rigidbody.velocity.x > movementDirection.x)
                    ? movementDirection.x
                    : 0f;
            _rigidbody.AddForce(_airDirection.normalized * airAcceleration);
        }

        if (transform.position.y <= -10)
            transform.position = _startPoint;
    }

    private void Jump()
    {
        _rigidbody.velocity = new Vector3(_rigidbody.velocity.x, 0, _rigidbody.velocity.y);
        _rigidbody.AddForce(Vector3.up * jumpPower * jumpMultiplier);
    }
}
