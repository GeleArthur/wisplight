using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class Extensions
{
    /// <summary>
    /// Return a random float between x and y
    /// </summary>
    /// <param name="a"></param>
    /// <returns>Random float</returns>
    public static float GetRandom(this Vector2 a)
    {
        return Random.Range(a.x, a.y);
    }

    /// <summary>
    /// Return a random interger between x and y
    /// </summary>
    /// <param name="a"></param>
    /// <param name="maxInclusive">Should y be incluisve?</param>
    /// <returns>Random interger</returns>
    public static int GetRandom(this Vector2Int a, bool maxInclusive = false)
    {
        return Random.Range(a.x, maxInclusive ? (a.y + 1) : a.y);
    }

    /// <summary>
    /// Get a random point inside bounds
    /// </summary>
    /// <param name="bounds"></param>
    /// <returns>Random Point</returns>
    public static Vector3 GetRandomPoint(this Bounds bounds)
    {
        return bounds.center + new Vector3(
            Random.Range(-bounds.extents.x, bounds.extents.x),
            Random.Range(-bounds.extents.y, bounds.extents.y),
            Random.Range(-bounds.extents.z, bounds.extents.z)
            );
    }
}
