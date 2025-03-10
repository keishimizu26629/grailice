using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// サイコロの面を表現するクラス
/// </summary>
public class DiceFace : MonoBehaviour
{
    [SerializeField] private int faceValue; // 面の値（1〜6）

    /// <summary>
    /// 面の値を取得
    /// </summary>
    /// <returns>面の値</returns>
    public int GetFaceValue()
    {
        return faceValue;
    }

    /// <summary>
    /// 面の値を設定
    /// </summary>
    /// <param name="value">面の値</param>
    public void SetFaceValue(int value)
    {
        faceValue = Mathf.Clamp(value, 1, 6);
    }
}
