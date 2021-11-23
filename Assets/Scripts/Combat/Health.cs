using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Health : MonoBehaviour, IKnockBack
{
    public int health;
    
    public void Hit()
    {
        health -= 1;
        if (health <= 0) Die();
    }

    private void Die()
    {
        Destroy(gameObject);
    }
    
    
    
}
