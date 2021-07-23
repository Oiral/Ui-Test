using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;


[CustomEditor(typeof(RecyclableGridLayout))]
[CanEditMultipleObjects]
public class RecyclableGridLayoutEditor : Editor
{

    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        serializedObject.Update();
    }
}
