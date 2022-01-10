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
        virtualCamera.enabled = bounds.Contains(_player.position);
    }
}