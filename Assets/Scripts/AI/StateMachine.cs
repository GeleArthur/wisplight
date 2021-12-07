using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;
using Random = UnityEngine.Random;

public enum States { Idle, Shoot, JumpToPlayer, Web}; 


public class StateMachine : EnemyBehaviour
{
    

    private Transform player;

    [Header("Web settings")] 
    [SerializeField] private float rayLength;
    [SerializeField] private int checkAmount;
    private List<Vector3> hitLocations;

    [SerializeField] private LayerMask playerMask;
    
    [Header("circle check settings")]
    [SerializeField] private float circleRadius;
    [SerializeField] private Vector3 circleOffset;

    [Header("Box check settings")] 
    [SerializeField] private Vector3 boxRadius;
    [SerializeField] private Vector3 boxOffset;

    
    
    
    void Start()
    {
        //player = GameObject.Find("Player").GetComponent<Transform>();
    }

    void Update()
    {
        checkAmount = Mathf.Clamp(checkAmount, 1, int.MaxValue);
        Web(checkAmount);
        
        switch (state)
        {
            case States.Idle :
                break;
                
            case States.Shoot :
                break;
            
            case States.Web : 
                break;
            
            case States.JumpToPlayer : 
                
                break;
        }
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

    private void Web(int checkAmount)
    { 
        for (int i = 0 + 180 / checkAmount; i < 180; i += 180 / checkAmount)
        {
            float x = Mathf.Cos(i * Mathf.Deg2Rad) * rayLength;
            float y = Mathf.Sin(i * Mathf.Deg2Rad) * rayLength;
            
            Debug.DrawLine(transform.position, transform.position + new Vector3(x,y));
            Physics.Linecast(transform.position, transform.position + new Vector3(x, y), out RaycastHit hit);
            if (hit.collider != null)
            {
                Debug.DrawRay(hit.point, Vector3.down);
                if (hit.normal == Vector3.down)
                {
                    hitLocations.Add(hit.point);
                }
            }
        }

        //todo check if the hitLocations does have a location to go to and is not null
        
        int randomPoint = Random.Range(0, hitLocations.Count);
        

        state = States.Idle;
    }

    private void Idle()
    {
        
    }
    


    private void OnDrawGizmosSelected()
    {
       
    }
}

