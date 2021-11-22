using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(CharacterController))]
public class PlayerController : MonoBehaviour
{

    [SerializeField] float speed = 10f;
    [SerializeField] float acceration = 10f;
    [SerializeField] float jumpForce = 15f;
    [SerializeField] float gravity = 9.8f;
    [SerializeField] float sensativity = 0.75f;
    [Range(0f, 1f)]
    [SerializeField] float drag = 0.1f;

    CharacterController characterController;
    private Vector2 velocity = new Vector2();
    private Vector2 mouseDir = Vector2.down;

    private void Awake()
    {
        characterController = GetComponent<CharacterController>();
        Cursor.lockState = CursorLockMode.Locked;
        // Cursor.visible = true;
    }

    private void Start()
    {
    }

    private void Update()
    {
        mouseDir += new Vector2(Input.GetAxisRaw("Mouse X"), Input.GetAxisRaw("Mouse Y")) * sensativity;
        mouseDir.Normalize();
        if (Input.GetMouseButtonUp(0))
        {
            velocity += -mouseDir * jumpForce;
        }
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        if (Physics.Raycast(transform.position + Vector3.down * characterController.bounds.extents.y, Vector3.down, 0.1f))
        {
            if (Mathf.Abs(Input.GetAxisRaw("Horizontal")) == 0f)
                velocity.x *= 1f - drag;

            if (velocity.y < 0f)
                velocity.y = 0f;
        }
        else
        {
            velocity.y -= gravity * Time.deltaTime;
        }

        if (Mathf.Abs(Input.GetAxisRaw("Horizontal")) > 0f)
            velocity.x = Mathf.MoveTowards(velocity.x, Input.GetAxisRaw("Horizontal") * speed, acceration * Time.deltaTime);

        characterController.Move(velocity * Time.deltaTime);
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawRay(transform.position, mouseDir * 10F);
    }
}
