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
        virtualCamera.enabled = false;
        _player = FindObjectOfType<PlayerMovement>().transform;
    }

    private void Update()
    {
        var boundsPlusPos = new Bounds(bounds.center, bounds.size);
        boundsPlusPos.center += transform.position;
        if (boundsPlusPos.Contains(_player.position))
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

    private void OnDrawGizmos()
    {
        Gizmos.DrawWireCube(transform.position + bounds.center, bounds.size);
    }
}