using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DustPile : MonoBehaviour
{
    [SerializeField] private float amount = 0;
    [SerializeField] private float offset = 0.5f;

    private void Awake()
    {
        transform.position += transform.up * offset;
    }

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
