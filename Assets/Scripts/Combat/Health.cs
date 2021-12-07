using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Health : MonoBehaviour, IKnockBack
{
    public int health;
    [SerializeField] private int damageAmount;
        
    public void Hit()
    {
        health -= damageAmount;
        if (health <= 0) Die();
    }

    private void Die()
    {
        Destroy(gameObject);
    }
    
    
    
}
