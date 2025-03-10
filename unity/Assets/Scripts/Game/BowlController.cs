using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 酒どんぶりの制御を行うクラス
/// </summary>
public class BowlController : MonoBehaviour
{
    [Header("どんぶり設定")]
    [SerializeField] private float rotationSpeed = 10f; // どんぶりの回転速度
    [SerializeField] private float rotationAmount = 5f; // どんぶりの回転量
    [SerializeField] private float shakeDuration = 0.5f; // どんぶりの揺れ持続時間
    [SerializeField] private AudioClip shakeSound; // どんぶりを揺らす音
    [SerializeField] private AudioClip collisionSound; // サイコロとの衝突音

    // コンポーネント
    private AudioSource _audioSource;
    private Rigidbody _rigidbody;

    // どんぶりが揺れているかどうか
    private bool _isShaking = false;

    // Start is called before the first frame update
    void Start()
    {
        // コンポーネントを取得
        _audioSource = GetComponent<AudioSource>();
        _rigidbody = GetComponent<Rigidbody>();

        // Rigidbodyの設定
        if (_rigidbody != null)
        {
            _rigidbody.isKinematic = true; // 物理挙動を無効化（位置は手動で制御）
        }
    }

    /// <summary>
    /// どんぶりを揺らす
    /// </summary>
    public void ShakeBowl()
    {
        // 既に揺れている場合は何もしない
        if (_isShaking) return;

        // 揺れるコルーチンを開始
        StartCoroutine(ShakeBowlCoroutine());
    }

    /// <summary>
    /// どんぶりを揺らすコルーチン
    /// </summary>
    private IEnumerator ShakeBowlCoroutine()
    {
        _isShaking = true;

        // 揺れる音を再生
        if (_audioSource != null && shakeSound != null)
        {
            _audioSource.PlayOneShot(shakeSound);
        }

        // 開始時の回転を保存
        Quaternion originalRotation = transform.rotation;

        // 揺れの時間
        float elapsed = 0f;

        while (elapsed < shakeDuration)
        {
            // 経過時間を更新
            elapsed += Time.deltaTime;
            float t = elapsed / shakeDuration;

            // サインカーブで揺れを表現
            float xAngle = Mathf.Sin(t * Mathf.PI * 8) * rotationAmount * (1 - t);
            float zAngle = Mathf.Cos(t * Mathf.PI * 6) * rotationAmount * (1 - t);

            // 回転を適用
            transform.rotation = originalRotation * Quaternion.Euler(xAngle, 0, zAngle);

            yield return null;
        }

        // 元の回転に戻す
        transform.rotation = originalRotation;

        _isShaking = false;
    }

    /// <summary>
    /// サイコロとの衝突時に呼ばれる
    /// </summary>
    /// <param name="collision">衝突情報</param>
    private void OnCollisionEnter(Collision collision)
    {
        // サイコロとの衝突を検出
        if (collision.gameObject.CompareTag("Dice"))
        {
            // 衝突音を再生
            if (_audioSource != null && collisionSound != null)
            {
                // 衝突の強さに応じて音量を調整
                float volume = Mathf.Clamp01(collision.relativeVelocity.magnitude / 10f);
                _audioSource.PlayOneShot(collisionSound, volume);
            }
        }
    }

    /// <summary>
    /// どんぶりが揺れているかどうかを取得
    /// </summary>
    /// <returns>揺れている場合はtrue</returns>
    public bool IsShaking()
    {
        return _isShaking;
    }
}
