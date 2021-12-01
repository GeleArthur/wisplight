using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent (typeof (MeshCollider))]
public class OneWayPlatform : MonoBehaviour
{
    public float maxAngle = 45.0f;
    
    // Thanks https://stackoverflow.com/questions/25395231/how-to-detect-collisions-only-one-way
    void Start ()
    {
        float cos = Mathf.Cos(maxAngle);
        MeshCollider meshCollider = GetComponent<MeshCollider>();
        if (meshCollider == null)
        {
            Debug.LogError("PlatformCollision needs a MeshCollider");
            return;
        }
        Mesh genMeshCollider = new Mesh();
        Vector3[] verts = meshCollider.sharedMesh.vertices;
        List<int> triangles = new List<int>(meshCollider.sharedMesh.triangles);
        for (int i = triangles.Count-1; i >=0 ; i -= 3)
        {
            Vector3 P1 = transform.TransformPoint(verts[triangles[i-2]]);
            Vector3 P2 = transform.TransformPoint(verts[triangles[i-1]]);
            Vector3 P3 = transform.TransformPoint(verts[triangles[i  ]]);
            Vector3 faceNormal = Vector3.Cross(P3-P2,P1-P2).normalized;
            if ( (Vector3.Dot(faceNormal, Vector3.up) <= cos))
                 // (!topCollision && Vector3.Dot(faceNormal, -Vector3.up) <= cos) )
            {
                triangles.RemoveAt(i);
                triangles.RemoveAt(i-1);
                triangles.RemoveAt(i-2);
            }
        }
        genMeshCollider.vertices = verts;
        genMeshCollider.triangles = triangles.ToArray();
        meshCollider.sharedMesh = genMeshCollider;
    }
}
