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
        if (_broomMover.broomEnabled && Input.GetMouseButtonDown(0))
        {
            if (Physics.SphereCast(transform.position, 0.1f, _broomMover.broomPoint, out var hitInfo, _broomMover.circleRadius, _broomMover.hitLayerMask))
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
