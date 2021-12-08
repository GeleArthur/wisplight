using System.Collections;
using UnityEngine;


    public class Idle : State
    {
        public Idle(EnemyBehaviour enemyBehaviour) : base(enemyBehaviour) { }

        public override void EnterState()
        {
            Debug.Log(1);

        }

        public override void Update()
        {
            enemyBehaviour.IsWebActive(true);
            if (enemyBehaviour.PlayerInSight(enemyBehaviour.checkAmount))
            {
                enemyBehaviour.SwitchState(new Attack(enemyBehaviour));
            }
        }

       
    }
