using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using Random = UnityEngine.Random;

[DisallowMultipleComponent]
public class DustManager : MonoBehaviour
{
    private static DustManager singleton;
    public static DustManager Singleton
    {
        get
        {
            return singleton;
        }

        private set
        {
            if (singleton)
            {
                Destroy(value);
                Debug.LogError("We have more than one DustManager!!!");
                return;
            }

            if (value.gameObject.CompareTag("ManagerObject"))
                singleton = value;
            else Debug.LogError("New DustManager is not on a managerobject!!!");
        }
    }

    [Tooltip("In percentages")]
    [SerializeField] private Vector2 amountOfDustInPile = new Vector2(1f, 5f);
    [SerializeField] private float maxAmountOfDust = 1000f;

    private float totalDust = 0f;
    private float currentDust = 0f;

    public float LevelCleaned => currentDust / totalDust;

    private List<DustRegion> dustRegions = new List<DustRegion>();

    private void Awake()
    {
        Singleton = this;
    }

    // Start is called before the first frame update
    void Start()
    {
        AddDust(maxAmountOfDust);
    }

    private void AddDust(float amount)
    {
        if (dustRegions.Count == 0)
            return;

        //make sure the amount of dust is always within the max amount
        amount = Mathf.Min(currentDust + amount, maxAmountOfDust) - currentDust;
        //create dustpiles till there is no dust left to add
        while (amount > 0)
        {
            //get the amount of dust in the next pile
            float dustPileAmount = Mathf.Min(amountOfDustInPile.GetRandom(), amount);
            //add it to a random region
            RandomDustRegion().AddDustPile(dustPileAmount);
            //and change these variables
            amount -= dustPileAmount;
            currentDust += dustPileAmount;
            totalDust += dustPileAmount;
        }
    }

    public void RemoveDust(float amount)
    {
        currentDust -= amount;
        if (Mathf.Floor(currentDust) <= 0)
        {
            if (PlayerPrefs.GetInt("level")+1 > SceneManager.GetActiveScene().buildIndex)
            {
                PlayerPrefs.SetInt("level", SceneManager.GetActiveScene().buildIndex+1);
            }
            PlayerPrefs.Save();
            SceneManager.LoadScene(0);
        }
    }

    /// <summary>
    /// Get a random DustRegion
    /// </summary>
    /// <returns>random DustRegion</returns>
    public DustRegion RandomDustRegion()
    {
        return dustRegions[Random.Range(0, dustRegions.Count)];
    }

    /// <summary>
    /// Add a DustRegion to the list
    /// </summary>
    /// <param name="dustRegion"></param>
    /// <param name="weight"></param>
    public void AddDustRegion(DustRegion dustRegion, int weight = 1)
    {
        weight = Mathf.Max(weight, 1);
        for (int i = 0; i < weight; i++)
        {
            dustRegions.Add(dustRegion);
        }
    }
}
