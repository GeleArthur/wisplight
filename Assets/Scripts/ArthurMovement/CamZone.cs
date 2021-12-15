using System;
using System.Collections;
using System.Collections.Generic;
using Cinemachine;
using UnityEngine;

public class CamZone : MonoBehaviour
{
    [SerializeField] private CinemachineVirtualCamera virtualCamera;
    
    
    void Start()
    {
        virtualCamera.enabled = false;
    }

    private void OnTriggerEnter(Collider other)
    {
        // if(other.gameObject.layer == )
    }

    private void OnTriggerExit(Collider other)
    {
        
    }
}
