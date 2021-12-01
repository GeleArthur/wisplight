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
                dustPiles[i].GetComponent<DustPile>().Clean();
                continue;
            }

            Vector3 dirToDust = (dustPiles[i].transform.position - transform.position).normalized;
            float angle = Vector2.Angle(knockBackHitter.broomPoint, dirToDust);

            if(angle <= maxAngle / 2f)
                dustPiles[i].GetComponent<DustPile>().Clean();
            /*RaycastHit[] hits = Physics.RaycastAll(transform.position, (dustPiles[i].transform.position - transform.position).normalized, Vector3.Distance(transform.position, dustPiles[i].transform.position), (1 << 8 | 1 << 0));
            Debug.Log(hits.Length);
            for (int j = 0; j < hits.Length; j++)
            {
                if (hits[j].collider == dustPiles[i])
                {
                    dustPiles[i].GetComponent<DustPile>().Clean();
                    break;
                }

                //if it is another dust pile co to the next in line
                if (hits[j].transform.gameObject.layer == 8)
                    continue;

                break;
            }*/

        }
    }

    private void OnDrawGizmosSelected()
    {
        Gizmos.color = new Color(1f, 1f, 1f, 0.5f);
        Gizmos.DrawSphere(transform.position, range);
    }
}
