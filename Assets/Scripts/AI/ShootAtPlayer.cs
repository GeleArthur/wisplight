using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[RequireComponent(typeof(Health))]
public class ShootAtPlayer : MonoBehaviour
{
    [SerializeField] private bool resetTimerOutsideRadius = true;
    [SerializeField] private Transform player;
    [SerializeField] private float radius;

    private float dist;
    private Vector3 dir;

    [SerializeField] private float spawnDist;
    [SerializeField] private float shootingSpeed;
    private float timer;

    [SerializeField] private Bullet bulletPrefab;

    [Header("Colors")] 
    [SerializeField] private Color inDistanceColor;
    private Color defaultColor;
    
    private Renderer r;
    
    private void Awake()
    {
        r = GetComponent<Renderer>();
        defaultColor = r.material.color;
        
        player = GameObject.FindGameObjectWithTag("Player").GetComponent<Transform>();
    }

    void Update()
    {
        timer += shootingSpeed * Time.deltaTime;
        dir = player.position - transform.position;

        if (InsideRadius())
        {
            if (timer >= 1f)
            {
                Shoot();
                timer = 0;
            }
        }
        else if(resetTimerOutsideRadius)
        {
            timer = 0;
        }
        
    }

    private bool InsideRadius()
    {
        dist = Vector2.Distance(player.position, transform.position);
        bool inDist = dist < radius;

        r.material.color = inDist ? inDistanceColor : defaultColor;

        return inDist;
    }

    private void Shoot()
    {
        var foo = Instantiate(bulletPrefab, SpawnDistance() , Quaternion.identity);
        foo.dir = dir;
    }

    public Vector3 SpawnDistance()
    {
        return transform.position + dir.normalized * spawnDist;
    }
    

#if UNITY_EDITOR
    private void OnDrawGizmos()
    {
        Gizmos.DrawRay(transform.position, dir.normalized * 50f);
        Gizmos.DrawSphere(SpawnDistance(), .2f);
        
        Handles.DrawWireDisc(transform.position, Vector3.forward, radius);

        if(player == null) return;        
        float dist = Vector2.Distance(player.position, transform.position);
        bool inside = dist < radius;
        Handles.color = inside ? Color.red : Color.white;
    }
#endif

   
}
