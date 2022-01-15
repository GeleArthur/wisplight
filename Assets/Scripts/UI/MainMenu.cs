using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class MainMenu : MonoBehaviour
{
    public List<LockedAndUnLocked> menuObjects;

    private void Awake()
    {
        Cursor.visible = true;
        Cursor.lockState = CursorLockMode.None;
        
        int atLevel = PlayerPrefs.GetInt("level", 1);
        PlayerPrefs.SetInt("level", atLevel);
        PlayerPrefs.Save();

        for (int i = 0; i < menuObjects.Count; i++)
        {
            int menuIndex = i;
            menuObjects[i].unlocked.GetComponent<Button>().onClick.AddListener(() =>
            {
                SceneManager.LoadScene(1 + menuIndex);
            });

            if (atLevel > i)
            {
                menuObjects[i].locked.SetActive(false);
            }

        }
    }
}

[Serializable]
public class LockedAndUnLocked
{
    public GameObject unlocked;
    public GameObject locked;
}
