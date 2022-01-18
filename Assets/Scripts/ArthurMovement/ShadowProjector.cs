using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShadowProjector : MonoBehaviour
{
    public Transform player;
    public LayerMask layers;
    public float offset;
    
    public MeshRenderer shadowMesh;

    private Vector3 castPos1;
    private Vector3 castPos2;

    // Start is called before the first frame update
    void Start()
    {
        shadowMesh = GetComponent<MeshRenderer>();
        if(player == null)
            player = transform.parent;
    }

    // Update is called once per frame
    void Update()
    {
        Bounds bounds = player.GetComponent<PlayerMovement>().characterModel.GetComponent<Renderer>().bounds;

        castPos1 = player.position + new Vector3(bounds.size.x / 2f, -bounds.size.y / 2f + 0.3f, 0);
        bool cast1 = Physics.Raycast(castPos1, Vector3.down, out RaycastHit hitInfo1, 10, layers);

        castPos2 = player.position + new Vector3(-bounds.size.x / 2f, -bounds.size.y / 2f + 0.3f, 0);
        bool cast2 = Physics.Raycast(castPos2, Vector3.down, out RaycastHit hitInfo2, 10, layers);
        
        if (!cast1 && !cast2)
        {
            transform.localScale = new Vector3(transform.localScale.x, transform.localScale.y, 0);
            shadowMesh.enabled = false;
            return;
        }
        
        shadowMesh.enabled = true;

        float startY;
        float endY;
        
        if(Mathf.Approximately(hitInfo1.point.y, hitInfo2.point.y))
        {
            startY = player.position.y - (bounds.size.y / 2f) + 0.1f;
            endY = hitInfo1.point.y - 0.1f;
        }
        else
        {
            startY = Mathf.Max(hitInfo1.point.y, hitInfo2.point.y)+offset;
            endY = Mathf.Min(hitInfo1.point.y, hitInfo2.point.y)-offset;
        }

        transform.localScale = new Vector3(transform.localScale.x, transform.localScale.y, startY-endY);
        transform.position = new Vector3(player.position.x, (startY+endY)/2, player.position.z);
        // transform.position = player.position - new Vector3(0, bounds.size.y / 2f, 0) - new Vector3(0, shadowLength / 2-offset, 0);

        // if (Physics.Raycast(player.position, Vector3.down, out var hitInfo, Single.MaxValue, layers))
        // {
        //     transform.position = hitInfo.point - new Vector3(0, 4, 0);
        // }
    }

#if UNITY_EDITOR
    private void OnDrawGizmos()
    {
        if(player == null)
            player = transform.parent;
    }
#endif
}