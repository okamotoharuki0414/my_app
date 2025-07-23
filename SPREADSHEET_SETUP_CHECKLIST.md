# スプレッドシート設定チェックリスト

## 現在の設定情報
- **スプレッドシートID**: `1ryld0XXkG02wC2-SpWwYLgvGGsNcJaYgpE_kGOS-aHw`
- **Google Apps Script URL**: `https://script.google.com/macros/s/AKfycbxiCIFF-e3X-lyu0LfcuJpnPPX9sguVhy1zyw3OfUaliKOPii-N3nUwA-RZp79Jht-EbQ/exec`
- **CSV URL**: `https://docs.google.com/spreadsheets/d/1ryld0XXkG02wC2-SpWwYLgvGGsNcJaYgpE_kGOS-aHw/export?format=csv`

## 必要な設定手順

### 1. スプレッドシートの共有設定
1. スプレッドシートを開く
2. 右上の「共有」ボタンをクリック
3. 「一般的なアクセス」を「リンクを知っている全員」に変更
4. 権限を「閲覧者」に設定

### 2. データ形式の確認
スプレッドシートの1行目（ヘッダー）は以下の順序になっている必要があります：

| A列 | B列 | C列 | D列 | E列 | F列 | G列 | H列 | I列 | J列 | K列 | L列 | M列 |
|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| id | name | category | address | latitude | longitude | rating | priceRange | imageUrl | phoneNumber | openingHours | description | reviewCount |

### 3. データ例
```
id,name,category,address,latitude,longitude,rating,priceRange,imageUrl,phoneNumber,openingHours,description,reviewCount
rest_001,銀座 鮨匠,寿司,東京都中央区銀座5-6-7,35.6719,139.7655,4.8,¥¥¥¥,https://example.com/image1.jpg,03-1234-5678,17:00-23:00,伝統的な江戸前鮨,95
rest_002,カフェ ブルー,カフェ,東京都新宿区新宿3-4-5,35.6896,139.7006,4.2,¥¥,https://example.com/image2.jpg,03-2345-6789,07:00-21:00,リラックスできる空間,203
```

### 4. Google Apps Scriptの設定（追加で必要な場合）
1. スプレッドシート内で「拡張機能」→「Apps Script」
2. `UPDATED_GAS_CODE.js`のコードを使用
3. 「デプロイ」→「新しいデプロイ」
4. 種類：「ウェブアプリ」
5. アクセス権限：「全員」
6. デプロイ後にURLを取得

## テスト方法

### 1. CSV形式のテスト
ブラウザで以下のURLに直接アクセス：
```
https://docs.google.com/spreadsheets/d/1ryld0XXkG02wC2-SpWwYLgvGGsNcJaYgpE_kGOS-aHw/export?format=csv
```

### 2. Google Apps Scriptのテスト
ブラウザで以下のURLに直接アクセス：
```
https://script.google.com/macros/s/AKfycbxiCIFF-e3X-lyu0LfcuJpnPPX9sguVhy1zyw3OfUaliKOPii-N3nUwA-RZp79Jht-EbQ/exec
```

## アプリの動作
1. **第1段階**: Google Apps Script APIを試行
2. **第2段階**: 失敗時はCSV形式で再試行
3. **第3段階**: どちらも失敗時はデフォルトデータを表示

## トラブルシューティング
- **権限エラー**: スプレッドシートの共有設定を確認
- **データが空**: ヘッダー行が正しく設定されているか確認
- **フォーマットエラー**: 数値データ（緯度、経度、評価）が正しい形式か確認