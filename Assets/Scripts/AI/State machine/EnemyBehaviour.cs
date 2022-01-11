using System;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using UnityEngine;
using Random = UnityEngine.Random;


public class EnemyBehaviour : StateMachine
    {
        public Transform webOrigin;
        [HideInInspector]public SpringJoint joint;
        [HideInInspector]public Transform player;
        [HideInInspector]public Rigidbody rb;
        public float toPlayerForce;

        [Header("check settings")] 
        public float playerCheckDistance;

        public float ceilingCheckDistance;

        public int checkAmount;
        
        [HideInInspector]public Vector3 boxRadius;
        [HideInInspector]public Vector3 boxOffset;
        public LayerMask playerMask;

        public float slopeCheck;

        private Idle _idle;
        private Attack _attack;
        private Restart _restart;

        private float x, y;

        [HideInInspector] public LineRenderer lineRenderer;
        
        List<Vector3> hitLocations = new List<Vector3>();
        
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
            lineRenderer = GetComponent<LineRenderer>();
        }

        private void Start()
        {
            currentState = _idle;
            
            currentState.EnterState();
        }

        private void Update()
        {
            //NewWebLocation(50);
            checkAmount = Mathf.Clamp(checkAmount, 1, 100);
            lineRenderer.SetPosition(1, transform.position);
            currentState.Update();
        }


        private void OnDrawGizmosSelected()
        {
            Gizmos.DrawWireCube(boxOffset, boxRadius);
        }

        public void IsWebActive(bool isActive)
        {
            if (isActive == true)
            {
                lineRenderer.SetPosition(0, webOrigin.position);
                lineRenderer.SetPosition(1, transform.position);
            }
            else
            {
                lineRenderer.SetPosition(0, transform.position);
                lineRenderer.SetPosition(1, transform.position);
            }
        }
        
        public void NewWebLocation(int checkAmount)
        {
            
            for (int i = 0 + 180 / checkAmount; i < 180; i += 180 / checkAmount)
            {
                x = Mathf.Cos(i * Mathf.Deg2Rad) ;
                y = Mathf.Sin(i * Mathf.Deg2Rad) ;
                
                Debug.DrawLine(transform.position, transform.position + new Vector3(x,y));
                Debug.DrawRay(transform.position ,new Vector3(x,y,0).normalized * ceilingCheckDistance);

                if (Physics.Raycast(transform.position, new Vector3(x, y, 0).normalized * ceilingCheckDistance,  out RaycastHit hit, ceilingCheckDistance))
                {
                    Debug.DrawRay(hit.point, Vector3.down);
                    if (Vector3.Dot(Vector3.down, hit.normal) >= slopeCheck)
                    {
                        hitLocations.Add(hit.point);
                    }
                }
            }

            int randomPoint = Random.Range(0, hitLocations.Count - 1);
            Vector3 hitPos = hitLocations[randomPoint];
            
            webOrigin.position = hitPos;
            
        }
        
        public bool PlayerInSight(int checkAmount)
        {
            for (int i = 90 + 360 / checkAmount; i < 360; i += checkAmount)
            {
                float x = Mathf.Cos(i * Mathf.Deg2Rad) * playerCheckDistance;
                float y = Mathf.Sin(i * Mathf.Deg2Rad) * playerCheckDistance;

                Debug.DrawLine(transform.position, transform.position + new Vector3(x,y));
                Physics.Linecast(transform.position, transform.position + new Vector3(x, y), out RaycastHit hit,playerMask);

                if (hit.collider != null)
                {
                    return true;
                }
            }
            return false;
        }

        private void OnDrawGizmos()
        {
            if(hitLocations.Count <= 0) return;
            foreach (var h in hitLocations)
            {
                Gizmos.DrawSphere(h, .2f);
            }
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