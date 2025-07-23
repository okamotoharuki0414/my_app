# Google Apps Script 設定ガイド

## 1. Googleスプレッドシート準備

### スプレッドシートの列構成
以下の順序で列を作成してください：

| A列 | B列 | C列 | D列 | E列 | F列 | G列 | H列 | I列 |
|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| id | name | category | address | latitude | longitude | rating | priceRange | imageUrl |

### データ例
```
id          name                category    address                 latitude    longitude   rating  priceRange  imageUrl
rest_001    銀座 鮨匠           寿司        東京都中央区銀座5-6-7    35.6719     139.7655    4.8     ¥¥¥¥        https://...
rest_002    カフェ ブルー       カフェ      東京都新宿区新宿3-4-5    35.6896     139.7006    4.2     ¥¥          https://...
```

## 2. Google Apps Script作成

1. スプレッドシートで「拡張機能」→「Apps Script」を開く
2. 以下のコードを貼り付け：

```javascript
function doGet() {
  // スプレッドシートIDを設定（URLから取得）
  const SHEET_ID = 'YOUR_SPREADSHEET_ID_HERE';
  const SHEET_NAME = 'Sheet1'; // シート名を確認して設定
  
  try {
    const sheet = SpreadsheetApp.openById(SHEET_ID).getSheetByName(SHEET_NAME);
    const data = sheet.getDataRange().getValues();
    
    if (data.length <= 1) {
      return ContentService.createTextOutput(JSON.stringify([]))
        .setMimeType(ContentService.MimeType.JSON);
    }
    
    const headers = data[0];
    const restaurants = [];
    
    for (let i = 1; i < data.length; i++) {
      const row = data[i];
      
      // 空の行をスキップ
      if (!row[0] || !row[1]) continue;
      
      restaurants.push({
        id: row[0] ? row[0].toString() : '',
        name: row[1] ? row[1].toString() : '',
        category: row[2] ? row[2].toString() : '',
        address: row[3] ? row[3].toString() : '',
        latitude: row[4] ? parseFloat(row[4]) || 0 : 0,
        longitude: row[5] ? parseFloat(row[5]) || 0 : 0,
        rating: row[6] ? parseFloat(row[6]) || 0 : 0,
        priceRange: row[7] ? row[7].toString() : '¥',
        imageUrl: row[8] ? row[8].toString() : '',
        phoneNumber: '', // 必要に応じて列を追加
        openingHours: '', // 必要に応じて列を追加
        description: '', // 必要に応じて列を追加
        reviewCount: 0, // 必要に応じて列を追加
        distance: 0 // 計算で設定
      });
    }
    
    return ContentService.createTextOutput(JSON.stringify(restaurants))
      .setMimeType(ContentService.MimeType.JSON);
      
  } catch (error) {
    console.error('Error:', error);
    return ContentService.createTextOutput(JSON.stringify({
      error: 'データの取得に失敗しました',
      details: error.toString()
    })).setMimeType(ContentService.MimeType.JSON);
  }
}
```

3. 「デプロイ」→「新しいデプロイ」
4. 種類：「ウェブアプリ」
5. アクセス許可：「全員」
6. デプロイを実行してWebアプリURLを取得

## 3. Flutter設定

1. `lib/services/restaurant_service.dart`の`_gasApiUrl`に取得したURLを設定：

```dart
static const String _gasApiUrl = 'https://script.google.com/macros/s/YOUR_SCRIPT_ID/exec';
```

## 4. テスト方法

1. WebブラウザでGASのURLに直接アクセスしてJSONが返されるか確認
2. Flutterアプリを起動してデータが正しく表示されるか確認

## 5. トラブルシューティング

- **権限エラー**: GASの実行権限を「全員」に設定してください
- **CORSエラー**: ウェブアプリとしてデプロイされているか確認
- **データが空**: スプレッドシートのシート名とIDが正しいか確認
- **フォーマットエラー**: 緯度・経度が数値形式になっているか確認
