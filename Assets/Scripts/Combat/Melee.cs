using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class Melee : MonoBehaviour
{
    
    [Header("Hit detection position")]
    [SerializeField] private Transform point;
    [SerializeField] private Vector3 size;
    [SerializeField] private Vector3 pointOffset;

    [Header("Other")]
    [SerializeField] private LayerMask hitLayers;

    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            Attack();
        }
    }

    // ReSharper disable Unity.PerformanceAnalysis
    private void Attack()
    {
        //var hits = Physics.CapsuleCastAll(transform.position, );
        foreach (var hit in hits)
        {
          var foo =  hit.collider.GetComponent<IKnockBack>();
          foo.Hit();
        }
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.green;
        if(point == null) return;
        Gizmos.DrawWireCube(point.position + pointOffset, size);
    }
    
    
    /*foreach (var hit in foo)
        {
            Debug.Log("Hit: " + hit.name);
            
        }*/
    // foo = Physics.OverlapBox(point.position + pointOffset, size * 0.5f, point.rotation, hitLayers);
}
