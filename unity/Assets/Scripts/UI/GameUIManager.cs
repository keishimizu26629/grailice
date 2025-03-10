using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

/// <summary>
/// ゲームのUIを管理するクラス
/// </summary>
public class GameUIManager : MonoBehaviour
{
    [Header("UI要素")]
    [SerializeField] private TextMeshProUGUI resultText; // 結果表示テキスト
    [SerializeField] private TextMeshProUGUI statusText; // 状態表示テキスト
    [SerializeField] private Button rollButton; // サイコロを振るボタン
    [SerializeField] private GameObject loadingIndicator; // ローディングインジケーター

    [Header("参照")]
    [SerializeField] private DiceController diceController; // サイコロコントローラー
    [SerializeField] private BowlController bowlController; // どんぶりコントローラー

    // Start is called before the first frame update
    void Start()
    {
        // 初期状態の設定
        UpdateUI();

        // ボタンのクリックイベントを設定
        if (rollButton != null)
        {
            rollButton.onClick.AddListener(OnRollButtonClick);
        }
    }

    // Update is called once per frame
    void Update()
    {
        // UIを更新
        UpdateUI();
    }

    /// <summary>
    /// UIを更新
    /// </summary>
    private void UpdateUI()
    {
        if (diceController == null) return;

        // サイコロの状態に応じてUIを更新
        if (diceController.IsRolling())
        {
            // サイコロを振っている状態
            SetStatus("サイコロを振っています...");
            ShowLoading(true);
            EnableRollButton(false);
        }
        else if (diceController.IsDetectionComplete())
        {
            // サイコロの目の検出が完了した状態
            int[] values = diceController.GetDiceValues();
            int total = diceController.GetDiceTotal();
            SetResult($"{values[0]} + {values[1]} = {total}");
            SetStatus("サイコロの目が確定しました");
            ShowLoading(false);
            EnableRollButton(true);
        }
        else
        {
            // 初期状態
            SetResult("");
            SetStatus("サイコロを振ってください");
            ShowLoading(false);
            EnableRollButton(true);
        }

        // どんぶりの状態に応じてUIを更新
        if (bowlController != null && bowlController.IsShaking())
        {
            EnableRollButton(false);
        }
    }

    /// <summary>
    /// サイコロを振るボタンがクリックされたときの処理
    /// </summary>
    private void OnRollButtonClick()
    {
        if (diceController == null) return;

        // サイコロを振る
        diceController.RollDice();

        // どんぶりを揺らす
        if (bowlController != null)
        {
            bowlController.ShakeBowl();
        }
    }

    /// <summary>
    /// 結果テキストを設定
    /// </summary>
    /// <param name="text">表示するテキスト</param>
    private void SetResult(string text)
    {
        if (resultText != null)
        {
            resultText.text = text;
        }
    }

    /// <summary>
    /// 状態テキストを設定
    /// </summary>
    /// <param name="text">表示するテキスト</param>
    private void SetStatus(string text)
    {
        if (statusText != null)
        {
            statusText.text = text;
        }
    }

    /// <summary>
    /// ローディングインジケーターの表示/非表示を切り替え
    /// </summary>
    /// <param name="show">表示する場合はtrue</param>
    private void ShowLoading(bool show)
    {
        if (loadingIndicator != null)
        {
            loadingIndicator.SetActive(show);
        }
    }

    /// <summary>
    /// サイコロを振るボタンの有効/無効を切り替え
    /// </summary>
    /// <param name="enable">有効にする場合はtrue</param>
    private void EnableRollButton(bool enable)
    {
        if (rollButton != null)
        {
            rollButton.interactable = enable;
        }
    }
}
