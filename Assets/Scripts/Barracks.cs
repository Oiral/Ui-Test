using Cysharp.Threading.Tasks;

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Barracks : MonoBehaviour
{
    public Hero HeroPrefab;
    public Transform ContentRoot;
    public List<Sprite> ThumbnailSprites = new List<Sprite>();
    public int testQuantity = 100;

    private void Start()
    {
        for (int i = 0; i < testQuantity; i++)
        {
            var newHero = Instantiate(HeroPrefab, ContentRoot, false);
            newHero.PopulatAsyncVoid().Forget();
        }
    }
}
