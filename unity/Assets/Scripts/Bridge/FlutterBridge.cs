using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// Flutter-Unity連携のためのブリッジクラス
/// Flutterからのメッセージを受け取り、Unityの機能を呼び出す
/// </summary>
public class FlutterBridge : MonoBehaviour
{
    // シングルトンインスタンス
    private static FlutterBridge _instance;
    public static FlutterBridge Instance
    {
        get
        {
            if (_instance == null)
            {
                var obj = new GameObject("FlutterBridge");
                _instance = obj.AddComponent<FlutterBridge>();
                DontDestroyOnLoad(obj);
            }
            return _instance;
        }
    }

    // UnityMessageManagerのインスタンス
    private UnityMessageManager _messageManager;

    // DiceControllerへの参照
    private DiceController _diceController;

    private void Awake()
    {
        if (_instance == null)
        {
            _instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else if (_instance != this)
        {
            Destroy(gameObject);
            return;
        }

        // UnityMessageManagerを取得
        _messageManager = GetComponent<UnityMessageManager>();
        if (_messageManager == null)
        {
            _messageManager = gameObject.AddComponent<UnityMessageManager>();
        }
    }

    /// <summary>
    /// DiceControllerを設定
    /// </summary>
    /// <param name="diceController">DiceControllerのインスタンス</param>
    public void SetDiceController(DiceController diceController)
    {
        _diceController = diceController;
    }

    /// <summary>
    /// サイコロを振る
    /// Flutterから呼び出される
    /// </summary>
    public void RollDice()
    {
        if (_diceController != null)
        {
            _diceController.RollDice();
        }
        else
        {
            Debug.LogError("DiceController is not set");
        }
    }

    /// <summary>
    /// サイコロの結果をFlutterに送信
    /// </summary>
    /// <param name="dice1">1つ目のサイコロの目</param>
    /// <param name="dice2">2つ目のサイコロの目</param>
    public void SendDiceResult(int dice1, int dice2)
    {
        if (_messageManager != null)
        {
            // JSONデータを作成
            string json = JsonUtility.ToJson(new DiceResult { dice1 = dice1, dice2 = dice2 });

            // Flutterにメッセージを送信
            _messageManager.SendMessageToFlutter(json);
        }
    }

    /// <summary>
    /// サイコロの結果を表すクラス
    /// </summary>
    [Serializable]
    private class DiceResult
    {
        public int dice1;
        public int dice2;
    }
}
