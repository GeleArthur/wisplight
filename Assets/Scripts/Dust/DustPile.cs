using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DustPile : MonoBehaviour, IKnockBack
{
    private float amount = 0;

    public void Hit()
    {
        DustManager.Singleton.RemoveDust(amount);
        Destroy(gameObject);
    }

    public void SetAmount(float newAmount)
    {
        amount = newAmount;
    }
}
