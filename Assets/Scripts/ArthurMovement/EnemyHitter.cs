using System;
using UnityEngine;


public class EnemyHitter : MonoBehaviour
{
    private BroomMover _broomMover;

    private void Start()
    {
        _broomMover = GetComponent<BroomMover>();
    }

    private void Update()
    {
        if (Input.GetMouseButton(0))
        {
            if (Physics.SphereCast(transform.position, 1f, _broomMover.broomPoint, out var hitInfo, _broomMover.circleRadius))
            {
                var knockHit = hitInfo.transform.GetComponent<IKnockBack>();

                if (knockHit != null)
                {
                    knockHit.Hit();
                }
            }
        }
    }
}
