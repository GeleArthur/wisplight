using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CollectBroom : MonoBehaviour
{
    private void OnTriggerEnter(Collider other)
    {
        if(other.gameObject.GetComponent<BroomMover>())
        {
            other.gameObject.GetComponent<BroomMover>().ToggleBroom();
            Destroy(gameObject);
        }
    }
}
