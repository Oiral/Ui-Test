using Cysharp.Threading.Tasks;

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Barracks : MonoBehaviour
{
    public Hero HeroPrefab;
    public Transform ContentRoot;
    public List<Sprite> ThumbnailSprites = new List<Sprite>();

    private void Start()
    {
        for (int i = 0; i < 100; i++)
        {
            var newHero = Instantiate(HeroPrefab, ContentRoot, false);
            newHero.PopulatAsyncVoid().Forget();
        }
    }
}
