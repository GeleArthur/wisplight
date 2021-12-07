using System;
using UnityEngine;


    public abstract class EnemyBehaviour : MonoBehaviour
    {
        public States state;
        public Rigidbody rb;
        
        private void Awake() => rb = GetComponent<Rigidbody>();

        private bool InsideCircleRadius(Vector3 origin, Vector3 circleOffset, float circleRadius, LayerMask layerMask)
        {
            bool inDist = Physics.CheckSphere(origin + circleOffset, circleRadius, layerMask);
            return inDist;
        }
        
        private bool InsideCircleRadius(Vector3 origin, Vector3 circleOffset, float circleRadius, LayerMask layerMask, States toState)
        {
            bool inDist = Physics.CheckSphere(origin + circleOffset, circleRadius, layerMask);
            state = toState;
            return inDist;
        }
        

        private bool InsideBoxRadius(Vector3 origin, Vector3 boxRadius, Vector3 boxOffset, LayerMask layerMask)
        {
            bool inDist = Physics.CheckBox(transform.position + boxOffset, boxRadius * 0.5f, Quaternion.identity, layerMask);
            return inDist;
        }
        
        private bool InsideBoxRadius(Vector3 origin, Vector3 boxRadius, Vector3 boxOffset, LayerMask layerMask, States toState)
        {
            bool inDist = Physics.CheckBox(transform.position + boxOffset, boxRadius * 0.5f, Quaternion.identity, layerMask);
            state = toState;
            return inDist;
        }

        private void JumpTowardsPlayer(Vector3 playerPos, float force, ForceMode forceMode)
        {
            Vector3 dir = playerPos - transform.position;
            rb.AddForce(dir.normalized * force, forceMode);
        }
    }
