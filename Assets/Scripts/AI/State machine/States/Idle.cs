﻿using System.Collections;
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
            if (enemyBehaviour.InsideBoxRadius(enemyBehaviour.boxOffset, enemyBehaviour.boxRadius, enemyBehaviour.playerMask))
            {
                enemyBehaviour.SwitchState(new Attack(enemyBehaviour));
            }
        }

       
    }
