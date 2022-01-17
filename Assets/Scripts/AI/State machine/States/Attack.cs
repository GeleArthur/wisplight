using System;
using System.Collections;
using UnityEngine;


    public class Attack : State
    {
        public Attack(EnemyBehaviour enemyBehaviour) : base(enemyBehaviour) { }
        
        public override void EnterState()
        {
            enemyBehaviour.StartCoroutine(AttackBuildUp());
        }

        public override void Update()
        {
           enemyBehaviour.IsWebActive(false);
           Debug.DrawRay(enemyBehaviour.transform.position, Vector3.down * 2, Color.cyan);
           if (Physics.Raycast(enemyBehaviour.transform.position, Vector3.down * 2, out var hit, 2 ,enemyBehaviour.deactivateColliderLayers))
           {
               enemyBehaviour.playerAttackCollider.enabled = false;
           }
        }

        IEnumerator Drop()
        {
            enemyBehaviour.joint.maxDistance = float.PositiveInfinity;
            
            enemyBehaviour.rb.velocity = Vector3.zero;
            
            var dir = enemyBehaviour.player.position - enemyBehaviour.transform.position;
            enemyBehaviour.rb.velocity = dir.normalized * enemyBehaviour.toPlayerForce;
            
            AudioManager.instance.Play("Hit");
            yield return new WaitForSeconds(2f);
            enemyBehaviour.playerAttackCollider.enabled = false;
            enemyBehaviour.SwitchState(new Restart(enemyBehaviour));
        }

        IEnumerator AttackBuildUp()
        {
            Vector3 dir = enemyBehaviour.player.position - enemyBehaviour.transform.position;
            enemyBehaviour.rb.AddForce(dir.normalized * 1000);
            AudioManager.instance.Play("Whoos");
            yield return new WaitForSeconds(.5f);
            enemyBehaviour.StartCoroutine(Drop());
            yield break;
        }
       
        
    }
