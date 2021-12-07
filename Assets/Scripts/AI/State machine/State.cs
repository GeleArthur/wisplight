using System.Collections;
using UnityEngine;


    public abstract class State
    {
        protected EnemyBehaviour enemyBehaviour;

        public State(EnemyBehaviour enemyBehaviour)
        {
            this.enemyBehaviour = enemyBehaviour;
        }
        
        public abstract void EnterState();

        public abstract void Update();
        
        

    }
