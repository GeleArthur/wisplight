using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TriggerOneWayAnimation : MonoBehaviour
{
    private Animator animator;
    private string currentState;
    
    private const string ROTATE = "RotateBalk";
    private const string IDLE = "Idle";
    

    private void Awake()
    {
        animator = GetComponent<Animator>();
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            Debug.Log("Bruh2");
            ChangeAnimationState(ROTATE);
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            ChangeAnimationState(IDLE);
        }
    }

    void ChangeAnimationState(string newState)
    {
        if(currentState == newState) return;
        
        animator.Play(newState);

        currentState = newState;
    }
}
