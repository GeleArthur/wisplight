using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DustPile : MonoBehaviour, DustCleanedInterface
{
    [SerializeField] private float amount = 0;
    [SerializeField] private float offset = 0.5f;

    private void Awake()
    {
        transform.position += transform.up * offset;
    }

    public void SetAmount(float newAmount)
    {
        amount = newAmount;
    }

    public void Cleaned()
    {
        DustManager.Singleton.RemoveDust(amount);
        Destroy(gameObject);
    }
}
