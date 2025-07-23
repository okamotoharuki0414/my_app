function doGet() {
  // 正しいスプレッドシートIDを設定
  const SHEET_ID = '1ryld0XXkG02wC2-SpWwYLgvGGsNcJaYgpE_kGOS-aHw';
  const SHEET_NAME = 'Sheet1'; // シート名を確認してください
  
  try {
    console.log('スプレッドシートからデータを取得開始...');
    const sheet = SpreadsheetApp.openById(SHEET_ID).getSheetByName(SHEET_NAME);
    const data = sheet.getDataRange().getValues();
    
    console.log('取得したデータ行数:', data.length);
    
    if (data.length <= 1) {
      console.log('データが空か、ヘッダーのみです');
      return ContentService.createTextOutput(JSON.stringify([]))
        .setMimeType(ContentService.MimeType.JSON);
    }
    
    const headers = data[0];
    console.log('ヘッダー:', headers);
    const restaurants = [];
    
    for (let i = 1; i < data.length; i++) {
      const row = data[i];
      
      // 空の行をスキップ
      if (!row[0] || !row[1]) {
        console.log('空の行をスキップ:', i);
        continue;
      }
      
      const restaurant = {
        id: row[0] ? row[0].toString() : `rest_${i}`,
        name: row[1] ? row[1].toString() : '',
        category: row[2] ? row[2].toString() : '',
        address: row[3] ? row[3].toString() : '',
        latitude: row[4] ? parseFloat(row[4]) || 35.6762 : 35.6762,
        longitude: row[5] ? parseFloat(row[5]) || 139.6503 : 139.6503,
        rating: row[6] ? parseFloat(row[6]) || 0 : 0,
        priceRange: row[7] ? row[7].toString() : '¥',
        imageUrl: row[8] ? row[8].toString() : 'https://placehold.co/280x180',
        phoneNumber: row[9] ? row[9].toString() : '',
        openingHours: row[10] ? row[10].toString() : '',
        description: row[11] ? row[11].toString() : '',
        reviewCount: row[12] ? parseInt(row[12]) || 0 : 0,
        distance: 1.0 // 固定値または計算で設定
      };
      
      restaurants.push(restaurant);
      console.log('レストラン追加:', restaurant.name);
    }
    
    console.log('最終的なレストラン数:', restaurants.length);
    
    return ContentService.createTextOutput(JSON.stringify(restaurants))
      .setMimeType(ContentService.MimeType.JSON);
      
  } catch (error) {
    console.error('エラー発生:', error);
    return ContentService.createTextOutput(JSON.stringify({
      error: 'データの取得に失敗しました',
      details: error.toString(),
      message: 'スプレッドシートIDやシート名を確認してください'
    })).setMimeType(ContentService.MimeType.JSON);
  }
}