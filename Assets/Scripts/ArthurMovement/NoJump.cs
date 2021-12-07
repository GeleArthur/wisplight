using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NoJump : MonoBehaviour, IKnockBack
{
    public Vector3 Hit()
    {
        return Vector3.zero;
    }
}
