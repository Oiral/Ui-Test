using Cysharp.Threading.Tasks;

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ImageLoader : MonoBehaviour
{
    public List<Sprite> ThumbnailSprites = new List<Sprite>();

    public async UniTask<Sprite> LoadSpriteAsync()
    {
        // faking the idea of streaming down the thumbnail images so we don't know when it will 
        await UniTask.Delay(Random.Range(0, 6) * 1000);
        return ThumbnailSprites[Random.Range(0, ThumbnailSprites.Count)];
    }
}
