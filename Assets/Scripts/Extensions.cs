using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class Extensions
{
    public static float GetRandom(this Vector2 a)
    {
        return Random.Range(a.x, a.y);
    }

    public static float GetRandom(this Vector2Int a)
    {
        return Random.Range(a.x, a.y);
    }
}
