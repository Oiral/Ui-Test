using Cysharp.Threading.Tasks;

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Hero : MonoBehaviour
{
    public Image Thumbnail;
    public LoadingSprite Loading;

    public async UniTaskVoid PopulatAsyncVoid()
    {
        //Lets ensure that the thumbnail is not on
        //We don't want a white image while it is loading
        Thumbnail.enabled = false;

        //Hero sprite is loading
        Thumbnail.sprite = await FindObjectOfType<ImageLoader>().LoadSpriteAsync();

        //Remove the loading icon - Don't need it after were done loading
        Destroy(Loading);

        //Hero sprite is done loading
        Thumbnail.enabled = true;
    }
}
