using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Health : MonoBehaviour, IKnockBack
{
    public int health;
    [SerializeField] private int damageAmount;
        
    public void Hit()
    {
        AudioManager.instance.Play("Punch hit");
        health -= damageAmount;
        if (health <= 0) Die();
    }

    private void Die()
    {
        Destroy(gameObject);
    }
    
    
    
}
