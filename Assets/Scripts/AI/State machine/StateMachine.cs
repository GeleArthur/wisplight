using System;
using System.Collections;
using System.Collections.Generic;
using Unity.Mathematics;
using UnityEngine;
using UnityEngine.Serialization;
using Random = UnityEngine.Random;

public class StateMachine : MonoBehaviour
{
    public State currentState;

    public void SwitchState(State state)
    {
        currentState = state;
        state.EnterState();
    }
    
    public bool InsideBoxRadius(Vector3 boxOffset, Vector3 boxRadius, LayerMask layerMask)
    {
        bool inDist = Physics.CheckBox(boxOffset, boxRadius * 0.5f, Quaternion.identity, layerMask);
        return inDist;
    }

   
    
    
    
}

 /*private Transform player;
    

    [Header("Web settings")] 
    [SerializeField] private float rayLength;
    [SerializeField] private int checkAmount;
    [SerializeField] private Transform webLoc;
    private SpringJoint joint;
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
        state = States.Idle;
        hitLocations = new List<Vector3>();
        joint = GetComponent<SpringJoint>();
        player = GameObject.Find("Player").GetComponent<Transform>();
    }

    void Update()
    {
        checkAmount = Mathf.Clamp(checkAmount, 1, int.MaxValue);
        switch (state)
        {
            case States.Idle :
                Debug.Log(1);
                Idle();
                break;
            case States.Attack :
                Debug.Log(2);
                StartCoroutine(Drop());
                break;    
            case States.InProgress:
                Debug.Log(3);
                StartCoroutine(InProgress());    
                break;
        }
    }
    
    private void Idle()
    {
        joint.maxDistance = 0;
        if (InsideBoxRadius(boxOffset, boxRadius, playerMask))
        {
            state = States.Attack;
        }
    }

    private IEnumerator Drop()
    {
        joint.maxDistance = float.PositiveInfinity;
        Vector3 dir = player.transform.position - transform.position;
        rb.AddForce(dir * 5);
        yield return new WaitForSeconds(2f);
        rb.AddForce(Vector3.up);
        joint.maxDistance = 0;
        state = States.InProgress;
    }

    private IEnumerator InProgress()
    {
        yield return new WaitForSeconds(10f);
        state = States.Idle;
    }


    private void OnDrawGizmosSelected()
    {
       Gizmos.DrawWireCube(boxOffset, boxRadius);
    }*/

/*private void Web(int checkAmount)
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
       
       int randomPoint = Random.Range(0, hitLocations.Count);
       Vector3 hitPos = hitLocations[randomPoint];

       webLoc.position = hitPos;
       
       state = States.Idle;
   }*/
