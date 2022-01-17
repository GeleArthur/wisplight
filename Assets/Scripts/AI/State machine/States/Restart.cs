﻿using System.Collections;
using UnityEngine;


    public class Restart : State
    {
        public Restart(EnemyBehaviour enemyBehaviour) : base(enemyBehaviour) { }

        public override void EnterState()
        {
            enemyBehaviour.rb.AddForce(Vector3.up);
            enemyBehaviour.joint.maxDistance = 0;
            enemyBehaviour.NewWebLocation(50);
            enemyBehaviour.StartCoroutine(ToIdle());
        }

        public override void Update()
        {
            enemyBehaviour.IsWebActive(true);
            if (enemyBehaviour.CheckConnection())
            {
                enemyBehaviour.NewWebLocation(50);
            }
        }

        private IEnumerator ToIdle()
        {
            yield return new WaitForSeconds(4f);
            enemyBehaviour.playerAttackCollider.enabled = true;
            enemyBehaviour.SwitchState(new Idle(enemyBehaviour));
        }
    }
