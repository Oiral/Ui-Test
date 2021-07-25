using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IDataSource
{
    int GetItemCount();
    void SetCell(ICell cell, int index);
}
