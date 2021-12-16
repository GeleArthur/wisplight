using System;
using System.Collections;
using System.Collections.Generic;
using Cinemachine;
using UnityEngine;

public class CamZone : MonoBehaviour
{
    [SerializeField] private CinemachineVirtualCamera virtualCamera;
    [SerializeField] private Bounds bounds;
    private Transform _player;

    void Start()
    {
        if (virtualCamera == null) virtualCamera = GetComponent<CinemachineVirtualCamera>();
        virtualCamera.enabled = false;
        _player = FindObjectOfType<PlayerMovement>().transform;
    }

    private void Update()
    {
        if (bounds.Contains(_player.position))
        {
            if (virtualCamera.enabled == false)
            {
                virtualCamera.enabled = true;
            }
        }
        else
        {
            if (virtualCamera.enabled == true)
            {
                virtualCamera.enabled = false;
            }
        }
    }

    // private void OnDrawGizmos()
    // {
    //     Gizmos.DrawWireCube(bounds.center, bounds.size);
    // }
}