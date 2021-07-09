using Cysharp.Threading.Tasks;

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Hero : MonoBehaviour
{
    public Image Thumbnail;
    public LoadingSprite Loading;

    public HeroData data;

    public async UniTaskVoid PopulatAsyncVoid()
    {
        Thumbnail.enabled = false;

        Loading.gameObject.SetActive(true);

        //Hero sprite is loading
        Thumbnail.sprite = await FindObjectOfType<ImageLoader>().LoadSpriteAsync();

        Loading.gameObject.SetActive(false);

        Thumbnail.enabled = true;
    }
}
