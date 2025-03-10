using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// Flutter-Unity間のメッセージングを管理するクラス
/// </summary>
public class UnityMessageManager : MonoBehaviour
{
    // シングルトンインスタンス
    private static UnityMessageManager _instance;
    public static UnityMessageManager Instance
    {
        get
        {
            if (_instance == null)
            {
                var obj = new GameObject("UnityMessageManager");
                _instance = obj.AddComponent<UnityMessageManager>();
                DontDestroyOnLoad(obj);
            }
            return _instance;
        }
    }

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
        }
    }

    /// <summary>
    /// Flutterにメッセージを送信
    /// </summary>
    /// <param name="message">送信するメッセージ</param>
    public void SendMessageToFlutter(string message)
    {
#if UNITY_ANDROID && !UNITY_EDITOR
        using (AndroidJavaClass unityPlayer = new AndroidJavaClass("com.unity3d.player.UnityPlayer"))
        using (AndroidJavaObject activity = unityPlayer.GetStatic<AndroidJavaObject>("currentActivity"))
        using (AndroidJavaObject unityBridge = new AndroidJavaObject("com.xraph.plugin.flutter_unity_widget.UnityPlayerUtils"))
        {
            unityBridge.CallStatic("onUnityMessage", activity, message);
        }
#elif UNITY_IOS && !UNITY_EDITOR
        OnUnityMessage(message);
#else
        Debug.Log($"[UnityMessageManager] SendMessageToFlutter: {message}");
#endif
    }

    /// <summary>
    /// シーンがロードされたことをFlutterに通知
    /// </summary>
    /// <param name="sceneName">ロードされたシーン名</param>
    /// <param name="buildIndex">ビルドインデックス</param>
    public void SendSceneLoadedMessageToFlutter(string sceneName, int buildIndex)
    {
        SceneLoadedMessage message = new SceneLoadedMessage
        {
            name = sceneName,
            buildIndex = buildIndex
        };
        string json = JsonUtility.ToJson(message);
        SendMessageToFlutter(json);
    }

    /// <summary>
    /// iOS用のネイティブメソッド（プラグインから呼び出される）
    /// </summary>
    /// <param name="message">メッセージ</param>
    private void OnUnityMessage(string message)
    {
#if UNITY_IOS && !UNITY_EDITOR
        NativeAPI.OnUnityMessage(message);
#endif
    }

    /// <summary>
    /// シーンロードメッセージを表すクラス
    /// </summary>
    [Serializable]
    private class SceneLoadedMessage
    {
        public string name;
        public int buildIndex;
    }
}

#if UNITY_IOS && !UNITY_EDITOR
/// <summary>
/// iOS用のネイティブAPI
/// </summary>
internal static class NativeAPI
{
    [System.Runtime.InteropServices.DllImport("__Internal")]
    internal static extern void OnUnityMessage(string message);
}
#endif
