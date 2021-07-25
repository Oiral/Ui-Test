using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class RecyclableGridLayout : GridLayoutGroup
{
    #region Variables
    public ScrollRect scrollRect;

    [Tooltip("The prefab for the cells inside this Grid Layout")]
    public GameObject cellPrefab;

    [Tooltip("The object that has our data for the Grid Layout")]
    public IDataSource dataSource;

    RectTransform viewPort;

    //How our grid is madeup
    float heightPerCell;
    float widthPerCell;

    int cellsPerRow;
    int cellsPerCollumn;

    int cellIndex = 0;

    //How many extra cells should we put in for scrolling
    static int cellCollumnBuffer = 2;

    Vector2 prevScrollPos;

    //Filler Items
    List<RectTransform> pool;
    List<GameObject> fillerObjects = new List<GameObject>();

    #endregion

    #region Initialization
    protected override void OnEnable()
    {
        scrollRect.onValueChanged.AddListener(onContentMove);
        prevScrollPos = rectTransform.anchoredPosition;
        viewPort = scrollRect.viewport;
    }

    protected override void OnDisable()
    {
        scrollRect.onValueChanged.RemoveListener(onContentMove);
    }

    public void GenerateContent()
    {
        pool = new List<RectTransform>();

        //Calculate bounds/amount of content to generate

        widthPerCell = cellSize.x + spacing.x;
        heightPerCell = cellSize.y + spacing.y;

        cellsPerRow = (int)((scrollRect.viewport.rect.width - padding.left - padding.right) / widthPerCell);
        cellsPerCollumn = (int)((scrollRect.viewport.rect.height - padding.top - padding.bottom) / heightPerCell + cellCollumnBuffer);

        for (int i = 0; i < Mathf.Min(dataSource.GetItemCount(), cellsPerCollumn * cellsPerRow); i++)
        {
            GameObject cellObject = Instantiate(cellPrefab, rectTransform);

            pool.Add(cellObject.GetComponent<RectTransform>());
            ICell createdCell = cellObject.GetComponent<ICell>();
            dataSource.SetCell(createdCell, i);
            cellIndex++;
        }
    }
    #endregion
    void onContentMove(Vector2 scrollPos)
    {
        Vector2 scrollDir = rectTransform.anchoredPosition - prevScrollPos;
        prevScrollPos = rectTransform.anchoredPosition;

        if (scrollDir.y > 0)
        {
            if (GetYMin(pool[0]) > GetYMax(viewPort))
            {
                Debug.Log("Recycle Down", pool[0]);
                RecycleDown();
            }
        }
        else if (scrollDir.y < 0)
        {
            if (GetYMax(pool[pool.Count - 1]) < GetYMin(viewPort) - (heightPerCell * (cellCollumnBuffer - 1)))
            {
                Debug.Log("Recycle Up", pool[pool.Count - 1]);
                RecycleUp();
            }

        }
    }

    #region recyling
    void RecycleDown()
    {
        while (GetYMin(pool[0]) > GetYMax(viewPort) && cellIndex < dataSource.GetItemCount())
        {
            //Create an invisble game object to fill out the grid
            GameObject spaceFiller = new GameObject("Grid Space Filler", typeof(RectTransform));
            spaceFiller.transform.SetParent(transform);
            spaceFiller.transform.SetSiblingIndex(fillerObjects.Count);

            fillerObjects.Add(spaceFiller);

            pool[0].SetAsLastSibling();

            RectTransform tempTransform = pool[0];
            pool.RemoveAt(0);
            pool.Add(tempTransform);

            dataSource.SetCell(tempTransform.GetComponent<ICell>(), cellIndex);
            cellIndex++;
        }
    }

    void RecycleUp()
    {
        while(GetYMax(pool[pool.Count - 1]) < GetYMin(viewPort) - (heightPerCell * (cellCollumnBuffer - 1)) && fillerObjects.Count > 0)
        {
            RectTransform tempTransform = pool[pool.Count - 1];
            pool.Remove(tempTransform);
            pool.Insert(0, tempTransform);

            tempTransform.SetSiblingIndex(fillerObjects.Count);

            Destroy(fillerObjects[fillerObjects.Count - 1]);
            fillerObjects.RemoveAt(fillerObjects.Count - 1);
            
            cellIndex--;

            dataSource.SetCell(tempTransform.GetComponent<ICell>(), fillerObjects.Count);
        }
    }
    #endregion

    #region helpers
    //The world corners start bottom left and the go clockwise
    /// <summary>
    /// Get the Y minimum world point of the rect transform
    /// </summary>
    float GetYMin(RectTransform rectTransform)
    {
        Vector3[] corners = new Vector3[4];
        rectTransform.GetWorldCorners(corners);
        return corners[0].y;
    }

    /// <summary>
    /// Get the Y maximium world point of the rect transform
    /// </summary>
    float GetYMax(RectTransform rectTransform)
    {
        Vector3[] corners = new Vector3[4];
        rectTransform.GetWorldCorners(corners);
        return corners[1].y;
    }
    #endregion
}
