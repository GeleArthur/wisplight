using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DamagePlayer : MonoBehaviour
{
   
   private void OnTriggerEnter(Collider other)
   {
      if (other.CompareTag("Player"))
      { 
         AudioManager.instance.Play("Ded");
         other.transform.position = other.GetComponent<PlayerMovement>()._startPoint;
      }
   }
}
