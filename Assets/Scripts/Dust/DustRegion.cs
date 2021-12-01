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
    TryAgain:
        Vector3 randomPosition = transform.position + bounds.GetRandomPoint();
        float distance = randomPosition.y - (transform.position.y + bounds.center.y - bounds.extents.y);
        RaycastHit hit;
        if (Physics.Raycast(randomPosition, Vector3.down, out hit, distance, ~(1 << 8), QueryTriggerInteraction.UseGlobal))
        {
            Quaternion rot = Quaternion.LookRotation(Vector3.forward, hit.normal);
            BoxCollider boxCollider = dustPrefab.GetComponent<BoxCollider>();
            if (Physics.OverlapBox(hit.point + boxCollider.center, boxCollider.size / 2f, rot, ~(1 << 8)).Length == 0)
                Instantiate(dustPrefab, hit.point, rot, transform).GetComponent<DustPile>().SetAmount(amount);
            else goto TryAgain;

        }
        else goto TryAgain;
        //Instantiate(dustPrefab, transform.position + bounds.GetRandomPoint(), Quaternion.identity, transform).GetComponent<DustPile>().SetAmount(amount);
    }

    public void OnDrawGizmos()
    {
        Gizmos.color = Color.white;
        Gizmos.DrawWireCube(transform.position + bounds.center, bounds.size);
    }
}
