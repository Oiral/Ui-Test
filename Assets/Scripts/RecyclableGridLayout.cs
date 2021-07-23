using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class RecyclableGridLayout : GridLayoutGroup
{
    public ScrollRect scrollRect;

    protected override void OnEnable()
    {
        scrollRect.onValueChanged.AddListener(onContentMove);
    }

    protected override void OnDisable()
    {
        
    }

    void onContentMove(Vector2 scrollPos)
    {
        Debug.Log(scrollPos);
    }
}
