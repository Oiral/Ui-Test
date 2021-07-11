using Cysharp.Threading.Tasks;

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using PolyAndCode.UI;

public class Barracks : MonoBehaviour, IRecyclableScrollRectDataSource
{
    public List<Sprite> ThumbnailSprites = new List<Sprite>();
    public int testQuantity = 100;

    public RecyclableScrollRect recyclableScroll;

    public List<HeroData> heroData;

    private void Start()
    {
        if (recyclableScroll == null)
        {
            Debug.Log("Missing recyclableScrollRect for display"); 
            return;
        }

        heroData = new List<HeroData>();

        for (int i = 0; i < testQuantity; i++)
        {
            heroData.Add(new HeroData());
        }

        recyclableScroll.Initialize(this);
    }


    #region DATA-SOURCE

    /// <summary>
    /// Data source method. return the list length.
    /// </summary>
    public int GetItemCount()
    {
        return heroData.Count;
    }

    /// <summary>
    /// Data source method. Called for a cell every time it is recycled.
    /// Implement this method to do the necessary cell configuration.
    /// </summary>
    public void SetCell(ICell cell, int index)
    {
        //Casting to the implemented Cell
        var item = cell as Hero;
        item.ConfigureCell(heroData[index], index, this);
    }

    #endregion
}
