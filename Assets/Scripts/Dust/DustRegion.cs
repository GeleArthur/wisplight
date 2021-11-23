using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[DisallowMultipleComponent]
public class DustRegion : MonoBehaviour
{
    [SerializeField] private GameObject dustPrefab = null;
    [Space]
    [SerializeField] private int weight = 1;
    [Space]
    [SerializeField] private Bounds bounds = new Bounds();

    private void Awake()
    {
        DustManager.Singleton.AddDustRegion(this, weight);
    }

    public void AddDustPile(float amount)
    {
        Instantiate(dustPrefab, transform.position + bounds.GetRandomPoint(), Quaternion.identity, transform).GetComponent<DustPile>().SetAmount(amount);
    }

    public void OnDrawGizmos()
    {
        Gizmos.color = Color.white;
        Gizmos.DrawWireCube(transform.position + bounds.center, bounds.size);
    }
}
