using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TriggerOneWayAnimation : MonoBehaviour
{
    [SerializeField] private Transform meshRotation;
    private Rigidbody _playerRb;
    [SerializeField] private bool backWay;
    
    private void Awake()
    {
        _playerRb = FindObjectOfType<PlayerMovement>().GetComponent<Rigidbody>();
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            if ((!backWay && _playerRb.velocity.y > 12) || (backWay && _playerRb.velocity.y < 0))
            {
                bool flag = transform.position.x < _playerRb.position.x;
                
                StopAllCoroutines();
                StartCoroutine(rotate(flag));
            }
        }
    }

    private IEnumerator rotate(bool leftSide)
    {
        float rotation = 0;
        float goal = 0;

        if (backWay)
        {
            goal = leftSide ? -180 : 180;
            AudioManager.instance.Play("BackWay");
        }
        else
        {
            goal = leftSide ? 180 : -180;
            AudioManager.instance.Play("OneWay");
        }
        

        while (true)
        {
            rotation += Time.deltaTime/0.2f;
            meshRotation.rotation = Quaternion.Euler(0,0, rotation*goal);
            
            if (rotation > 1)
            {
                meshRotation.rotation = Quaternion.Euler(0,0, goal);
                yield break;
            }
            
            yield return new WaitForEndOfFrame();
        }
    }
}
