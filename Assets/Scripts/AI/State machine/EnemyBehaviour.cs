﻿using System;
using System.Runtime.CompilerServices;
using UnityEngine;


    public class EnemyBehaviour : StateMachine
    {

        public SpringJoint joint;
        public Transform player;
        public Rigidbody rb;
        public float toPlayerForce;
        
        [Header("Box check settings")] 
        public Vector3 boxRadius;
        public Vector3 boxOffset;
        public LayerMask playerMask;


        private Idle _idle;
        private Attack _attack;
        private Restart _restart;

        public EnemyBehaviour()
        {
            _idle = new Idle(this);
            _attack = new Attack(this);
            _restart = new Restart(this);
        }

        private void Awake()
        {
            player = GameObject.Find("Player").GetComponent<Transform>();
            joint = GetComponent<SpringJoint>();
            rb = GetComponent<Rigidbody>();
        }

        private void Start()
        {
            currentState = _idle;
            
            currentState.EnterState();
        }

        private void Update()
        {
            currentState.Update();
        }


        private void OnDrawGizmosSelected()
        {
            Gizmos.DrawWireCube(boxOffset, boxRadius);
        }
    }


/*public States state;
        public Rigidbody rb;
        
        private void Awake() => rb = GetComponent<Rigidbody>();

        public bool InsideCircleRadius(Vector3 origin, Vector3 circleOffset, float circleRadius, LayerMask layerMask)
        {
            bool inDist = Physics.CheckSphere(origin + circleOffset, circleRadius, layerMask);
            return inDist;
        }
        
        public bool InsideCircleRadius(Vector3 origin, Vector3 circleOffset, float circleRadius, LayerMask layerMask, States toState)
        {
            bool inDist = Physics.CheckSphere(origin + circleOffset, circleRadius, layerMask);
            state = toState;
            return inDist;
        }


        protected bool InsideBoxRadius(Vector3 boxOffset, Vector3 boxRadius, LayerMask layerMask)
        {
            bool inDist = Physics.CheckBox(boxOffset, boxRadius * 0.5f, Quaternion.identity, layerMask);
            return inDist;
        }

        protected bool InsideBoxRadius(Vector3 boxOffset, Vector3 boxRadius, LayerMask layerMask, States toState)
        {
            var inDist = Physics.OverlapBox(boxOffset, boxRadius * 0.5f, Quaternion.identity, layerMask);
            for (int i = 0; i < inDist.Length; i++)
            {
                Debug.Log(inDist[i]);
            }
            state = toState;
            return inDist.Length == 0;
        }

        public void JumpTowardsPlayer(Vector3 playerPos, float force, ForceMode forceMode)
        {
            Vector3 dir = playerPos - transform.position;
            rb.AddForce(dir.normalized * force, forceMode);
        }*/