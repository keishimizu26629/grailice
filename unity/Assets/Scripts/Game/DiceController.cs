using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Random = UnityEngine.Random;

/// <summary>
/// サイコロの物理挙動と制御を行うクラス
/// </summary>
public class DiceController : MonoBehaviour
{
    [Header("サイコロ設定")]
    [SerializeField] private GameObject dice1Prefab; // 1つ目のサイコロのプレハブ
    [SerializeField] private GameObject dice2Prefab; // 2つ目のサイコロのプレハブ
    [SerializeField] private Transform diceSpawnPoint; // サイコロの生成位置
    [SerializeField] private float throwForce = 5f; // サイコロを投げる力
    [SerializeField] private float torqueForce = 10f; // サイコロの回転力
    [SerializeField] private float detectionDelay = 2f; // サイコロの目を検出するまでの遅延時間

    // サイコロのGameObject
    private GameObject _dice1;
    private GameObject _dice2;

    // サイコロのRigidbody
    private Rigidbody _dice1Rigidbody;
    private Rigidbody _dice2Rigidbody;

    // サイコロの目
    private int _dice1Value;
    private int _dice2Value;

    // サイコロが振られているかどうか
    private bool _isRolling = false;

    // サイコロの目の検出が完了したかどうか
    private bool _detectionComplete = false;

    // Start is called before the first frame update
    void Start()
    {
        // FlutterBridgeにDiceControllerを設定
        FlutterBridge.Instance.SetDiceController(this);

        // サイコロを初期化
        InitializeDice();
    }

    /// <summary>
    /// サイコロを初期化
    /// </summary>
    private void InitializeDice()
    {
        // 既存のサイコロを削除
        if (_dice1 != null) Destroy(_dice1);
        if (_dice2 != null) Destroy(_dice2);

        // サイコロを生成
        _dice1 = Instantiate(dice1Prefab, diceSpawnPoint.position, Quaternion.identity);
        _dice2 = Instantiate(dice2Prefab, diceSpawnPoint.position + new Vector3(0.5f, 0, 0), Quaternion.identity);

        // Rigidbodyを取得
        _dice1Rigidbody = _dice1.GetComponent<Rigidbody>();
        _dice2Rigidbody = _dice2.GetComponent<Rigidbody>();

        // 物理挙動を無効化
        _dice1Rigidbody.isKinematic = true;
        _dice2Rigidbody.isKinematic = true;

        // サイコロの目をリセット
        _dice1Value = 0;
        _dice2Value = 0;

        // 状態をリセット
        _isRolling = false;
        _detectionComplete = false;
    }

    /// <summary>
    /// サイコロを振る
    /// </summary>
    public void RollDice()
    {
        // 既に振っている場合は何もしない
        if (_isRolling) return;

        // サイコロを初期化
        InitializeDice();

        // 物理挙動を有効化
        _dice1Rigidbody.isKinematic = false;
        _dice2Rigidbody.isKinematic = false;

        // ランダムな力と回転を適用
        ApplyRandomForceAndTorque(_dice1Rigidbody);
        ApplyRandomForceAndTorque(_dice2Rigidbody);

        // 状態を更新
        _isRolling = true;
        _detectionComplete = false;

        // サイコロの目を検出するコルーチンを開始
        StartCoroutine(DetectDiceValueAfterDelay());
    }

    /// <summary>
    /// ランダムな力と回転をRigidbodyに適用
    /// </summary>
    /// <param name="rb">対象のRigidbody</param>
    private void ApplyRandomForceAndTorque(Rigidbody rb)
    {
        // ランダムな方向に力を加える
        Vector3 force = new Vector3(
            Random.Range(-0.5f, 0.5f),
            1,
            Random.Range(-0.5f, 0.5f)
        ).normalized * throwForce;

        // ランダムな回転を加える
        Vector3 torque = new Vector3(
            Random.Range(-1f, 1f),
            Random.Range(-1f, 1f),
            Random.Range(-1f, 1f)
        ).normalized * torqueForce;

        // 力と回転を適用
        rb.AddForce(force, ForceMode.Impulse);
        rb.AddTorque(torque, ForceMode.Impulse);
    }

    /// <summary>
    /// 遅延後にサイコロの目を検出するコルーチン
    /// </summary>
    private IEnumerator DetectDiceValueAfterDelay()
    {
        // 指定した時間待機
        yield return new WaitForSeconds(detectionDelay);

        // サイコロが静止するまで待機
        yield return new WaitUntil(() => IsDiceStopped());

        // サイコロの目を検出
        _dice1Value = DetectDiceValue(_dice1);
        _dice2Value = DetectDiceValue(_dice2);

        // 検出完了
        _detectionComplete = true;
        _isRolling = false;

        // 結果をFlutterに送信
        FlutterBridge.Instance.SendDiceResult(_dice1Value, _dice2Value);

        Debug.Log($"Dice Result: {_dice1Value}, {_dice2Value}");
    }

    /// <summary>
    /// サイコロが静止しているかどうかを判定
    /// </summary>
    /// <returns>静止している場合はtrue</returns>
    private bool IsDiceStopped()
    {
        // 速度と角速度が十分小さければ静止していると判定
        bool dice1Stopped = _dice1Rigidbody.velocity.magnitude < 0.01f && _dice1Rigidbody.angularVelocity.magnitude < 0.01f;
        bool dice2Stopped = _dice2Rigidbody.velocity.magnitude < 0.01f && _dice2Rigidbody.angularVelocity.magnitude < 0.01f;
        return dice1Stopped && dice2Stopped;
    }

    /// <summary>
    /// サイコロの目を検出
    /// </summary>
    /// <param name="dice">対象のサイコロ</param>
    /// <returns>サイコロの目（1〜6）</returns>
    private int DetectDiceValue(GameObject dice)
    {
        // サイコロの各面の法線ベクトル
        Vector3[] faceNormals = new Vector3[6]
        {
            Vector3.up,    // 1の面
            Vector3.right, // 2の面
            Vector3.forward, // 3の面
            Vector3.back,  // 4の面
            Vector3.left,  // 5の面
            Vector3.down   // 6の面
        };

        // 各面の対応する目の値
        int[] faceValues = new int[6] { 1, 2, 3, 4, 5, 6 };

        // 最も上を向いている面を探す
        int topFaceIndex = 0;
        float maxDotProduct = float.MinValue;

        for (int i = 0; i < 6; i++)
        {
            // サイコロのローカル座標系での法線ベクトルをワールド座標系に変換
            Vector3 worldNormal = dice.transform.TransformDirection(faceNormals[i]);

            // 上方向とのドット積を計算（値が大きいほど上を向いている）
            float dotProduct = Vector3.Dot(worldNormal, Vector3.up);

            if (dotProduct > maxDotProduct)
            {
                maxDotProduct = dotProduct;
                topFaceIndex = i;
            }
        }

        // 対応する目の値を返す
        return faceValues[topFaceIndex];
    }

    /// <summary>
    /// サイコロの目を取得
    /// </summary>
    /// <returns>サイコロの目の配列（[0]が1つ目、[1]が2つ目）</returns>
    public int[] GetDiceValues()
    {
        return new int[] { _dice1Value, _dice2Value };
    }

    /// <summary>
    /// サイコロの目の合計を取得
    /// </summary>
    /// <returns>サイコロの目の合計</returns>
    public int GetDiceTotal()
    {
        return _dice1Value + _dice2Value;
    }

    /// <summary>
    /// サイコロが振られているかどうかを取得
    /// </summary>
    /// <returns>振られている場合はtrue</returns>
    public bool IsRolling()
    {
        return _isRolling;
    }

    /// <summary>
    /// サイコロの目の検出が完了したかどうかを取得
    /// </summary>
    /// <returns>検出完了した場合はtrue</returns>
    public bool IsDetectionComplete()
    {
        return _detectionComplete;
    }
}
