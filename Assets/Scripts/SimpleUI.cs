using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class SimpleUI : MonoBehaviour
{
    private Text text;
    public static SimpleUI instace;

    private void Awake()
    {
        instace = this;
        text = GetComponent<Text>();
    }

    public void SetOne(bool switchControll)
    {
        text.text = $"Controll: {(switchControll ? 'A' : 'P')}\nPress \"p\" to switch";
        
    }
}
