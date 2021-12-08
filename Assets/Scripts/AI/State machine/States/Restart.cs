using System.Collections;
using UnityEngine;


    public class Restart : State
    {
        public Restart(EnemyBehaviour enemyBehaviour) : base(enemyBehaviour) { }

        public override void EnterState()
        {
            Debug.Log(3);
            enemyBehaviour.rb.AddForce(Vector3.up);
            enemyBehaviour.joint.maxDistance = 0;
            enemyBehaviour.joint.anchor = new Vector3(0, enemyBehaviour.anchorDefault, 0);
            enemyBehaviour.NewWebLocation(50);
            enemyBehaviour.StartCoroutine(ToIdle());
        }

        public override void Update()
        {
            enemyBehaviour.IsWebActive(true);
        }

        private IEnumerator ToIdle()
        {
            yield return new WaitForSeconds(4f);
            enemyBehaviour.SwitchState(new Idle(enemyBehaviour));
        }
    }
