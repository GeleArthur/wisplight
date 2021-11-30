using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class UIManager : MonoBehaviour
{
   private bool isPaused;

   [SerializeField] private GameObject pausePanel;
   
   private void Start()
   {
      isPaused = true;
      Pause();
      Time.timeScale = 1f;
   }

   private void Update()
   {
      if (Input.GetKeyDown(KeyCode.Escape))
      {
         Pause();
      }
   }
   
   public void Pause()
   {
      isPaused = !isPaused;
      pausePanel.SetActive(isPaused);

      if (isPaused == true)
      {
         Time.timeScale = 0f;
         Cursor.lockState = CursorLockMode.None;
      }
      else
      {
         Time.timeScale = 1f;
         Cursor.lockState = CursorLockMode.Locked;
      }
   }

   public void Quit()
   {
      Application.Quit();   
   }

   public void ToScene(string sceneName)
   {
      SceneManager.LoadScene(sceneName);
   }
   
}
