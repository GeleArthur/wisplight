using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(CharacterController))]
public class PlayerController : MonoBehaviour
{

    [SerializeField] float speed = 10f;
    [SerializeField] float acceration = 10f;
    [SerializeField] float gravity = 9.8f;
    [SerializeField] float sensativity = 10f;

    CharacterController characterController;
    private Vector2 velocity = new Vector2();
    private Vector2 mouseDir = Vector2.up;
    private Vector2 lastMousePos = new Vector2();

    private void Awake()
    {
        characterController = GetComponent<CharacterController>();
        Cursor.lockState = CursorLockMode.Locked;
       // Cursor.visible = true;
    }

    private void Start()
    {
        lastMousePos = Input.mousePosition;
    }

    private void Update()
    {
        Vector2 currentMousePos = Input.mousePosition;
        if ((currentMousePos - lastMousePos).magnitude >= sensativity)
        {
            mouseDir = (currentMousePos - lastMousePos).normalized;
            lastMousePos = Input.mousePosition;
        }
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        if (Physics.Raycast(transform.position + Vector3.down * characterController.bounds.extents.y, Vector3.down, 0.1f))
        {
            velocity.x = Mathf.MoveTowards(velocity.x, Input.GetAxisRaw("Horizontal") * speed, acceration * Time.deltaTime);
            if (velocity.y < 0f)
                velocity.y = 0f;
        }
        else
        {
            velocity.y -= gravity * Time.deltaTime;
        }
        characterController.Move(velocity * Time.deltaTime);
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawRay(transform.position, mouseDir * 10F);
    }
}
