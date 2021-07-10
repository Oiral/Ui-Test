using Cysharp.Threading.Tasks;

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using PolyAndCode.UI;

/// <summary>
/// Where we store our hero data
/// e.g. level, image, name etc
/// </summary>
[System.Serializable]
public struct HeroData
{
    public bool loaded;
    public Sprite thumbnail;
}

public class Hero : MonoBehaviour, ICell
{
    //UI
    public Image Thumbnail;
    public LoadingSprite Loading;

    //Data
    HeroData data;
    int displayIndex;

    Barracks parentBarracks;
    public async UniTaskVoid PopulatAsyncVoid()
    {
        if (!data.loaded)
        {
            Thumbnail.enabled = false;

            Loading.gameObject.SetActive(true);

            data.loaded = true;

            //We need to create a temp display index incase of fast scrolling
            int tempDisplayIndex = displayIndex;

            //If the data has not been loaded before - Lets load it now
            //For the sake of this test - We are just loading the image, but this is where I would get the data from a server or local storage
            data.thumbnail = await FindObjectOfType<ImageLoader>().LoadSpriteAsync();

            //Go back and save this data to the barracks data structure
            parentBarracks.heroData[tempDisplayIndex] = data;

            if (tempDisplayIndex != displayIndex)
            {
                //This is to catch if the user is scrolling faster than the data can be loaded
                return;
            }
        }

        Loading.gameObject.SetActive(false);

        Thumbnail.enabled = true;

        Thumbnail.sprite = data.thumbnail;
    }

    public void ConfigureCell(HeroData newData, int newDisplayIndex, Barracks myBarracks)
    {

        data = newData;
        displayIndex = newDisplayIndex;
        parentBarracks = myBarracks;

        this.PopulatAsyncVoid().Forget();
    }

}
