using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BarracksModel : MonoBehaviour
{
    public GameObject Barracks;

    private void OnMouseUp()
    {
        Barracks.SetActive(true);
    }
}
