# Noto Sans JP フォントファイルのダウンロード手順

## 必要なフォントファイル

以下のNoto Sans JPフォントファイルをダウンロードして、このfontsディレクトリに配置してください：

1. **NotoSansJP-Regular.ttf** (ウェイト: 400)
2. **NotoSansJP-Medium.ttf** (ウェイト: 500) 
3. **NotoSansJP-Bold.ttf** (ウェイト: 700)

## ダウンロード方法

### 方法1: Google Fonts（推奨）
1. [Google Fonts - Noto Sans JP](https://fonts.google.com/noto/specimen/Noto+Sans+JP) にアクセス
2. 「Download family」ボタンをクリック
3. ダウンロードしたZIPファイルを解凍
4. 必要なウェイトのTTFファイルを選択してこのディレクトリにコピー

### 方法2: GitHub（最新版）
1. [Noto Fonts GitHub](https://github.com/googlefonts/noto-fonts/tree/main/hinted/ttf/NotoSansJP) にアクセス
2. 各ウェイトのTTFファイルをダウンロード
3. このディレクトリに配置

## ファイル配置後の確認

フォントファイルを配置後、以下のコマンドで依存関係を更新してください：

```bash
cd /Users/otakereina/my_app
flutter pub get
```

## 使用するウェイト設定

| 用途 | ウェイト | ファイル |
|------|----------|----------|
| 本文・ラベル | 400 (Regular) | NotoSansJP-Regular.ttf |
| 小見出し | 500 (Medium) | NotoSansJP-Medium.ttf |
| 見出し・強調 | 700 (Bold) | NotoSansJP-Bold.ttf |

## 注意事項

- ファイル名は正確に合わせてください（大文字小文字含む）
- TTFファイルのみを使用してください
- OTFファイルは使用しないでください（Flutterでの互換性問題を避けるため）