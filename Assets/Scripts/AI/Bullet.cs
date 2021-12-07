using System;
using UnityEngine;

public class Bullet : MonoBehaviour, IKnockBack
{
    [SerializeField] private float speed;
    
    private Rigidbody rb;
    public Vector3 dir;
    
    private void Awake()
    {
        rb = GetComponent<Rigidbody>();
    }
    
    void FixedUpdate()
    {
        //the movement of the bullet
        rb.position += dir.normalized * speed;
    }

    private void OnTriggerEnter(Collider other)
    {
        //destroy it after 6 seconds. Otherwise it will fly forever in the scene.
        Destroy(gameObject, .05f);
        
        var otherHealth = other.GetComponent<Health>();
       
        //if this object collider, collides with another object that has the <Health> component on it
        //it will continue to run the code and do damage on the colliding object
        if(otherHealth == null) return;
        otherHealth.Hit();
        
        //the object will already be destroyed so we set the object to false.
        gameObject.SetActive(false);
    }

    public void Hit()
    {
        //if the player hits the bullet it will have to fly to the pointing direction
        var playerKnockback = GameObject.Find("Player").GetComponent<BroomMover>();
        dir = playerKnockback.broomPoint;
    }
}
