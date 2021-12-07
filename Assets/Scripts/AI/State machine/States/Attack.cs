using System;
using System.Collections;
using UnityEngine;


    public class Attack : State
    {
        public Attack(EnemyBehaviour enemyBehaviour) : base(enemyBehaviour) { }
        
        public override void EnterState()
        {
            Debug.Log(2);
            enemyBehaviour.StartCoroutine(Drop());
        }

        public override void Update()
        {
           
        }

        IEnumerator Drop()
        {
            enemyBehaviour.joint.maxDistance = float.PositiveInfinity;
            
            enemyBehaviour.rb.velocity = Vector3.zero;
            
            var dir = enemyBehaviour.player.position - enemyBehaviour.transform.position;
            enemyBehaviour.rb.velocity = dir * enemyBehaviour.toPlayerForce;
            
            yield return new WaitForSeconds(2f);
            enemyBehaviour.SwitchState(new Restart(enemyBehaviour));
        }

       
    }
