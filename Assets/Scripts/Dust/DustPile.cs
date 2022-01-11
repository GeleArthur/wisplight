using System.Collections;
using System.Collections.Generic;
using UnityEditor.UIElements;
using UnityEngine;

public class DustPile : MonoBehaviour, DustCleanedInterface
{
    [SerializeField] private float amount = 0;
    [SerializeField] private GameObject[] models = new GameObject[] { };
    [SerializeField] private float maxDust = 50f;
    [SerializeField] private float cleanAnimationTime = 5f;

    [SerializeField] private AnimationCurve curve;

    private float lifeLeft = 0f;
    private bool cleaned = false;

    private Material dustMat = null;

    public void Update()
    {
        if (cleaned)
        {
            lifeLeft -= Time.deltaTime;
            Debug.Log(lifeLeft / cleanAnimationTime);
            dustMat.SetFloat("_Materialised", curve.Evaluate(lifeLeft / cleanAnimationTime));
            if (lifeLeft <= 0f)
                Destroy(gameObject);
        }
    }

    public void SetAmount(float newAmount)
    {
        amount = newAmount;
        for (int i = 0; i < models.Length; i++)
            models[i].SetActive(false);

        float dustPerModel = maxDust / models.Length;
        int thing = Mathf.FloorToInt(amount / dustPerModel);
        models[thing].SetActive(true);
        dustMat = models[thing].GetComponent<Renderer>().material;
    }

    public void Cleaned()
    {
        if (!cleaned)
        {
            DustManager.Singleton.RemoveDust(amount);
            GetComponent<BoxCollider>().enabled = false;
            cleaned = true;
            lifeLeft = cleanAnimationTime;
        }
    }
}
