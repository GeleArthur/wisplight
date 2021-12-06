using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Health : MonoBehaviour, IKnockBack
{
    public int health;
    [SerializeField] private int damageAmount;
        
    public Vector3 Hit()
    {
        health -= damageAmount;
        if (health <= 0) Die();
        return Vector3.zero;
    }

    private void Die()
    {
        Destroy(gameObject);
    }
    
    
    
}
