using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;


[RequireComponent(typeof(Health))]
public class ShootAtPlayer : MonoBehaviour
{
    
    enum CheckState
    {
        BoxCheck,
        CircleCheck
    };
    
    [SerializeField] private Bullet bulletPrefab;
    [SerializeField] private bool enableGizmos;
    
    [Header("Colors")] 
    [SerializeField] private Color inDistanceColor;
    private Color defaultColor;
    
    [Header("Check method")]
    [SerializeField] private CheckState checkState = CheckState.CircleCheck;
    
    [Header("circle check settings")]
    [SerializeField] private float circleRadius;
    [SerializeField] private Vector3 circleOffset;

    [Header("Box check settings")] 
    [SerializeField] private Vector3 boxRadius;
    [SerializeField] private Vector3 boxOffset;

    [Header("Shooting settings")] 
    [SerializeField] private LayerMask playerMask;
    [SerializeField] private float spawnDist;
    [SerializeField] private float shootingSpeed;
    [SerializeField] private bool resetTimerOutsideRadius = true;
    [SerializeField] private bool continueToShootOutsideRadius;
    
    //
    private bool con;

    private Vector3 dir;
    private float timer;

    [SerializeField]private float scale;
    private Vector3 defaultScale;

    [Space]
    [SerializeField] private Transform player;

    
    private Renderer r;
    
    private void Awake()
    {
        r = GetComponent<Renderer>();
        
        player = GameObject.Find("Player").GetComponent<Transform>();
    }

    private void Start()
    {
        defaultColor = r.material.color;
        defaultScale = transform.localScale;
    }

    void Update()
    {
        timer += shootingSpeed * Time.deltaTime;
        dir = player.position - transform.position;

        switch (checkState)
        {
            case CheckState.BoxCheck: 
                Check(InsideBoxRadius());
                break;
            case CheckState.CircleCheck:
                Check(InsideCircleRadius());
                break;
        }
    }

    #region Check Methods
    
    private void Check(bool checkMethod)
    {
        r.material.color = checkMethod ? inDistanceColor : defaultColor;

        //Debug.Log(checkMethod);
        //IncreaseSize(checkMethod);
        
        if (IncreaseSize(checkMethod, timer))
        {
            if (continueToShootOutsideRadius) con = true;
            else con = false;
            
            if (timer >= 1f)
            {
                Shoot();
                timer = 0f;
            }
        }
        else if (con && IncreaseSize(!checkMethod, timer) && timer >= 1f)
        {
            Shoot();
            timer = 0f;
            con = false;
        }
        else if(resetTimerOutsideRadius)
        {
            timer = 0;
        }
    }

    public bool IncreaseSize(bool check, float timer)
    {
        
        //todo fix deze shit
        if (check)
        {
            Debug.Log(timer);
            transform.localScale *= timer;            
            return true;
        }
        return false;
    }
    

    private bool InsideCircleRadius()
    {
        float dist = Vector2.Distance(player.position, transform.position + circleOffset);
        bool inDist = dist < circleRadius;
        return inDist;
    }

    private bool InsideBoxRadius()
    {
        bool inDist = Physics.CheckBox(transform.position + boxOffset, boxRadius * 0.5f, Quaternion.identity, playerMask);
        return inDist;
    }
    #endregion

    #region Shoot Fuctions

    private void Shoot()
    {
        var foo = Instantiate(bulletPrefab, SpawnDistance() , Quaternion.identity);
        foo.dir = dir;
    }

    public Vector3 SpawnDistance()
    {
        return transform.position + dir.normalized * spawnDist;
    }

    #endregion
   
    

#if UNITY_EDITOR
    private void OnDrawGizmosSelected()
    {
        if(r == null) r = GetComponent<Renderer>();

        if (enableGizmos)
        {
            switch (checkState)
            {
                case CheckState.BoxCheck:
                    Gizmos.DrawWireCube(transform.position + boxOffset, boxRadius);
                    if(player == null) return; 
                    Handles.color = InsideBoxRadius() ? Color.red : Color.white;
                    break;
                case CheckState.CircleCheck:
                    Handles.DrawWireDisc(transform.position + circleOffset, Vector3.forward, circleRadius);
                    if(player == null) return;        
                    Handles.color = InsideCircleRadius() ? Color.red : Color.white;
                    break;
            }
            Gizmos.DrawRay(transform.position, dir.normalized * 50f);
            Gizmos.DrawSphere(SpawnDistance(), .2f);
        }
       

      


       
    }
#endif

   
}
