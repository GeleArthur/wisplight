using System;
using UnityEditor;
using UnityEngine;


[CustomEditor(typeof(CamZone))]
public class CamZoneInspector : Editor
{
    private CamZone _camZone;
    private bool _enabled = false;
    private bool _needRePaint = false;

    private Vector3 _pointOnZeroPlane = Vector3.zero;
    private bool _clicked = false;
    private Vector3 _startedClicked;
    
    private void OnEnable()
    {
        _camZone = (CamZone) target;
    }

    private void OnDisable()
    {
        Tools.hidden = false;
        _enabled = false;
        _clicked = false;
        _pointOnZeroPlane = Vector3.zero;
        _startedClicked = Vector3.zero;
    }

    public override void OnInspectorGUI()
    {
        if (GUILayout.Button("Set Bounds", GUILayout.Width(120f)))
        {
            _enabled = !_enabled;
            Tools.hidden = _enabled;
            _needRePaint = true;
        }
        
        DrawDefaultInspector();
    }

    private void OnSceneGUI()
    {
        Event guiEvent = Event.current;

        if (guiEvent.type == EventType.Repaint) 
            Draw();
        else if (guiEvent.type == EventType.Layout)
        {
            if (_enabled)
                // Disable clicking on other objects
                HandleUtility.AddDefaultControl(GUIUtility.GetControlID(FocusType.Passive));
        }
        else 
            HandleInput(guiEvent);
        

        if (_needRePaint)
        {
            HandleUtility.Repaint();
            _needRePaint = false;
        }
    }

    private void Draw()
    {
        var bounds = serializedObject.FindProperty("bounds").boundsValue;
        Handles.DrawWireCube(bounds.center, bounds.size);

        if (_enabled)
        {
            Handles.color = Color.red;
            Handles.DrawSolidDisc(_pointOnZeroPlane, new Vector3(0, 0, 1), 1);
            Handles.DrawSolidDisc(_startedClicked, new Vector3(0, 0, 1), 1);
        }

    }

    private void HandleInput(Event guiEvent)
    {
        if(!_enabled) return;
        Ray mouseRay = HandleUtility.GUIPointToWorldRay(guiEvent.mousePosition);

        float dist = (0 - mouseRay.origin.z) / mouseRay.direction.z;
        _pointOnZeroPlane = mouseRay.GetPoint(dist);

        if (guiEvent.type == EventType.MouseDown && guiEvent.button == 0)
        {
            _startedClicked = _pointOnZeroPlane;
            _clicked = true;
        }
        if (guiEvent.type == EventType.MouseUp && guiEvent.button == 0)
        {
            _clicked = false;
        }

        if (_clicked)
        {
            var bounds = serializedObject.FindProperty("bounds").boundsValue;
            bounds.center = _pointOnZeroPlane+(_startedClicked - _pointOnZeroPlane)/2;
            bounds.size = (bounds.center - _pointOnZeroPlane)*2;
            bounds.size = new Vector3(Math.Abs(bounds.size.x), Math.Abs(bounds.size.y), Math.Abs(bounds.size.z));

            serializedObject.FindProperty("bounds").boundsValue = bounds;
            serializedObject.ApplyModifiedProperties();
        }
        
        _needRePaint = true;
    }
}
