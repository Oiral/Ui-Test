using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(RectTransform))]
public class LoadingSprite : MonoBehaviour
{
    private RectTransform rectTransform;
    public float rotateSpeed = 10f;

    private void Start()
    {
        rectTransform = GetComponent<RectTransform>();
    }

    private void Update()
    {
        //The negative is to make the variable rotate speed more intuitive to input
        //Rotate clockwise when rotateSpeed is a positive
        rectTransform.Rotate(0, 0, - rotateSpeed * Time.deltaTime);
    }
}
