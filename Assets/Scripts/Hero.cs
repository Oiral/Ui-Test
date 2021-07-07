using Cysharp.Threading.Tasks;

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Hero : MonoBehaviour
{
    public Image Thumbnail;

    public async UniTaskVoid PopulatAsyncVoid()
    {
        Thumbnail.sprite = await FindObjectOfType<ImageLoader>().LoadSpriteAsync();
    }
}
