using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEngine.UIElements;

[CustomEditor(typeof(MonoBehaviour), true)]
public class InterfaceInspector : Editor
{
    bool showInterfaces = false;

    public override void OnInspectorGUI()
    {
        if (GUILayout.Button(showInterfaces ? "Hide interfaces" : "Show interfaces"))
            showInterfaces = !showInterfaces;

        if (showInterfaces)
        {
            if (target is IKnockBack myTarget)
            {
                EditorGUILayout.LabelField("IKnockBack");
                if (GUILayout.Button("Hit"))
                    myTarget.Hit();
            }
        }
        else base.OnInspectorGUI();
    }
}