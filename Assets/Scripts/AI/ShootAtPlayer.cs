using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class ShootAtPlayer : MonoBehaviour
{
    [SerializeField] private Transform player;
    [SerializeField] private float radius;

    private float dist;
    private bool inDist;

    private Vector3 dir;

    [SerializeField] private float shootingSpeed;
    private float timer;

    [SerializeField] private Bullet bulletPrefab;
    
    private void Awake()
    {
        player = GameObject.FindGameObjectWithTag("Player").GetComponent<Transform>();
    }

    void Update()
    {
        timer += shootingSpeed * Time.deltaTime;
        
        dir = player.position - transform.position;
        
        dist = Vector2.Distance(player.position, transform.position);
        inDist = dist < radius;
        
        if (inDist && timer >= 1f)
        {
            var foo = Instantiate(bulletPrefab, transform);
            foo.dir = dir;
            timer = 0;
        }
    }

#if UNITY_EDITOR
    private void OnDrawGizmos()
    {
        Gizmos.DrawRay(transform.position, dir.normalized * 50f);
        
        float dist = Vector2.Distance(player.position, transform.position);
        bool inside = dist < radius;

        Handles.color = inside ? Color.red : Color.white;
        Handles.DrawWireDisc(transform.position, Vector3.forward, radius);
    }
#endif

}
