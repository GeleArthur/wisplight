using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

[RequireComponent(typeof(BoxCollider))]
public class ToScene : MonoBehaviour
{
    [SerializeField] private int sceneIndex;
    
    private void OnTriggerEnter(Collider other)
    {
        SceneManager.LoadScene(sceneIndex);
    }
}
