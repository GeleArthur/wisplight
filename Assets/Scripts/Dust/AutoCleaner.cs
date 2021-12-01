using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AutoCleaner : MonoBehaviour
{
    [SerializeField] private float range = 2.5f;
    [SerializeField] private float noAngleRange = 1f;
    [SerializeField] private float maxAngle = 90f;
    private BroomMover knockBackHitter = null;

    private void Awake()
    {
        knockBackHitter = GetComponent<BroomMover>();
    }

    private void FixedUpdate()
    {
        Collider[] dustPiles = Physics.OverlapSphere(transform.position, range, 1 << 8, QueryTriggerInteraction.UseGlobal);
        for (int i = 0; i < dustPiles.Length; i++)
        {
            if(Vector2.Distance(dustPiles[i].transform.position, transform.position) <= noAngleRange)
            {
                dustPiles[i].GetComponent<DustCleanedInterface>().Cleaned();
                continue;
            }

            Vector3 dirToDust = (dustPiles[i].transform.position - transform.position).normalized;
            float angle = Vector2.Angle(knockBackHitter.broomPoint, dirToDust);

            if(angle <= maxAngle / 2f)
                dustPiles[i].GetComponent<DustCleanedInterface>().Cleaned();

        }
    }

    private void OnDrawGizmosSelected()
    {
        Gizmos.color = new Color(1f, 1f, 1f, 0.5f);
        Gizmos.DrawSphere(transform.position, range);
    }
}
