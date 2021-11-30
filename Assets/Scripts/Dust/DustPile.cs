using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DustPile : MonoBehaviour
{
    [SerializeField] private float amount = 0;

    public void Clean()
    {
        DustManager.Singleton.RemoveDust(amount);
        Destroy(gameObject);
    }

    public void SetAmount(float newAmount)
    {
        amount = newAmount;
    }
}
