using Cysharp.Threading.Tasks;

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Barracks : MonoBehaviour, IDataSource
{
    public Hero HeroPrefab;
    public Transform ContentRoot;
    public List<Sprite> ThumbnailSprites = new List<Sprite>();
    public int testQuantity = 100;

    public List<HeroData> data;

    public RecyclableGridLayout recyclableGridLayout;

    public int GetItemCount()
    {
        return data.Count;
    }

    public void SetCell(ICell cell, int index)
    {
        Hero hero = cell as Hero;
        hero.ConfigureCell(data[index], index, this);
        hero.transform.name = "Hero Clone | " + index;
    }

    private void Start()
    {
        data = new List<HeroData>();

        for (int i = 0; i < testQuantity; i++)
        {
            data.Add(new HeroData());

        }

        recyclableGridLayout.dataSource = (IDataSource)this;
        recyclableGridLayout.GenerateContent();
    }
}
