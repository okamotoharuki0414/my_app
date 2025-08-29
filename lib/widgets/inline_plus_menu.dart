import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../screens/bgm_selection_screen.dart';
import '../screens/event_creation_screen.dart';
import '../screens/ai_voice_selection_screen.dart';
import '../screens/poll_creation_screen.dart';
import '../models/bgm.dart';
import '../models/event.dart';
import '../models/ai_voice.dart';
import '../models/poll.dart';

class InlinePlusMenu extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback? onToggle;
  final Function(Bgm)? onBgmSelected;
  final Function(Event)? onEventCreated;
  final Function(AiVoice)? onAiVoiceSelected;
  final VoidCallback? onRecruitmentModeToggled;
  final Function(String)? onLocationSelected;
  final Function(Poll)? onPollCreated;
  final VoidCallback? onMentionTapped;

  const InlinePlusMenu({
    super.key,
    required this.isExpanded,
    this.onToggle,
    this.onBgmSelected,
    this.onEventCreated,
    this.onAiVoiceSelected,
    this.onRecruitmentModeToggled,
    this.onLocationSelected,
    this.onPollCreated,
    this.onMentionTapped,
  });

  @override
  State<InlinePlusMenu> createState() => _InlinePlusMenuState();
}

class _InlinePlusMenuState extends State<InlinePlusMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(InlinePlusMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4, // 画面の40%まで
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E5E5), width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMenuGrid(),
        ],
      ),
    );
  }

  Widget _buildMenuGrid() {
    final menuItems = [
      _MenuItem(
        icon: Icons.music_note,
        label: 'BGM',
        color: Colors.purple,
        onTap: () => _handleMenuTap('BGM'),
      ),
      _MenuItem(
        icon: Icons.alternate_email,
        label: 'メンション',
        color: Colors.blue,
        onTap: () => _handleMenuTap('メンション'),
      ),
      _MenuItem(
        icon: Icons.mic,
        label: 'AI音声',
        color: Colors.orange,
        onTap: () => _handleMenuTap('AI音声'),
      ),
      _MenuItem(
        icon: Icons.location_on,
        label: '位置情報',
        color: Colors.red,
        onTap: () => _handleMenuTap('位置情報'),
      ),
      _MenuItem(
        icon: Icons.quiz,
        label: 'アンケート',
        color: Colors.green,
        onTap: () => _handleMenuTap('アンケート'),
      ),
      _MenuItem(
        icon: Icons.how_to_vote,
        label: '投票',
        color: Colors.teal,
        onTap: () => _handleMenuTap('投票'),
      ),
      _MenuItem(
        icon: Icons.event_available,
        label: 'イベント',
        color: Colors.indigo,
        onTap: () => _handleMenuTap('イベント'),
      ),
      _MenuItem(
        icon: Icons.group_add,
        label: '募集',
        color: Colors.deepOrange,
        onTap: () => _handleMenuTap('募集'),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
        crossAxisSpacing: 10,
        mainAxisSpacing: 15,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return _buildMenuItem(item);
      },
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              item.icon,
              color: item.color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleMenuTap(String menuType) async {
    print('$menuType tapped');
    
    if (menuType == 'BGM') {
      // BGM選択画面へ遷移
      final selectedBgm = await Navigator.push<Bgm>(
        context,
        MaterialPageRoute(
          builder: (context) => const BgmSelectionScreen(),
        ),
      );
      
      if (selectedBgm != null && widget.onBgmSelected != null) {
        widget.onBgmSelected!(selectedBgm);
        // BGM選択後はメニューを閉じずに投稿作成を続行
        return;
      }
    } else if (menuType == 'AI音声') {
      print('AI音声 button tapped - starting navigation');
      try {
        // AI音声選択画面へ遷移
        final selectedVoice = await Navigator.push<AiVoice>(
          context,
          MaterialPageRoute(
            builder: (context) => const AiVoiceSelectionScreen(),
          ),
        );
        
        print('AI音声選択画面から戻ってきました: $selectedVoice');
        
        if (selectedVoice != null && widget.onAiVoiceSelected != null) {
          print('AI音声を選択しました: ${selectedVoice.name}');
          widget.onAiVoiceSelected!(selectedVoice);
          // AI音声選択後はメニューを閉じずに投稿作成を続行
          return;
        } else {
          print('AI音声が選択されませんでした or コールバックがnull');
        }
      } catch (e) {
        print('AI音声選択でエラーが発生: $e');
      }
      // AI音声処理が完了したら、他の処理をスキップ
      return;
    } else if (menuType == '位置情報') {
      print('位置情報 button tapped - getting current location');
      try {
        // 位置情報を取得して住所に変換
        await _getCurrentLocationAndAddress();
        return;
      } catch (e) {
        print('位置情報取得でエラーが発生: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('位置情報の取得に失敗しました: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    } else if (menuType == '募集') {
      // 募集マークを投稿文の最初に挿入
      if (widget.onRecruitmentModeToggled != null) {
        widget.onRecruitmentModeToggled!();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('投稿文に #募集 が追加されました'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    } else if (menuType == 'メンション') {
      // メンション機能を有効化
      if (widget.onMentionTapped != null) {
        widget.onMentionTapped!();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('@でユーザーをメンションできます'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    } else if (menuType == 'アンケート') {
      // アンケート作成画面へ遷移
      final createdPoll = await Navigator.push<Poll>(
        context,
        MaterialPageRoute(
          builder: (context) => const PollCreationScreen(),
        ),
      );
      
      if (createdPoll != null && widget.onPollCreated != null) {
        print('InlinePlusMenu: Poll created successfully: ${createdPoll.question}');
        widget.onPollCreated!(createdPoll);
        // アンケート作成後はメニューを閉じない（投稿を続行できるように）
        return;
      } else {
        print('InlinePlusMenu: Poll creation cancelled or callback is null');
      }
    } else if (menuType == 'イベント') {
      // イベント作成画面へ遷移
      final createdEvent = await Navigator.push<Event>(
        context,
        MaterialPageRoute(
          builder: (context) => const EventCreationScreen(),
        ),
      );
      
      if (createdEvent != null && widget.onEventCreated != null) {
        widget.onEventCreated!(createdEvent);
      }
    }
    
    // メニューを自動的に閉じる
    if (widget.onToggle != null) {
      widget.onToggle!();
    }
  }

  void _showRecruitmentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.group_add,
                color: Colors.deepOrange,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text('人数募集'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('一緒に食事やイベントに参加したい人を募集しましょう！'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.orange[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '例: "今度新しいイタリアンレストランに一緒に行きませんか？2-3人募集中！"',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                // 募集投稿作成画面へ遷移する処理をここに追加
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('募集投稿を作成しました！'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.group_add, size: 18),
              label: const Text('募集する'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _getCurrentLocationAndAddress() async {
    try {
      print('位置情報の許可を確認中...');
      
      // 位置サービスが有効かチェック
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('位置サービスが無効です。設定で有効にしてください。');
      }

      // 位置情報の許可をチェック
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('位置情報の許可が拒否されました。');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('位置情報の許可が永続的に拒否されています。設定で許可してください。');
      }

      print('現在地を取得中...');
      
      // 現在位置を取得
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      print('位置取得完了: ${position.latitude}, ${position.longitude}');
      print('住所を取得中...');

      // 座標から住所を取得
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, 
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        print('住所取得完了: $place');

        // 日本の住所形式に整形
        String address = _formatJapaneseAddress(place);
        print('整形された住所: $address');

        // コールバックで住所を投稿文入力欄に設定
        if (widget.onLocationSelected != null && address.isNotEmpty) {
          widget.onLocationSelected!(address);
          
          // 成功メッセージ
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('現在地を取得しました: $address'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          throw Exception('住所の取得に失敗しました。');
        }
      } else {
        throw Exception('住所が見つかりませんでした。');
      }
    } catch (e) {
      print('位置情報取得エラー: $e');
      rethrow;
    }
  }

  String _formatJapaneseAddress(Placemark place) {
    List<String> addressParts = [];
    
    // 日本の住所形式: 都道府県 + 市区町村 + 町域 + 番地
    if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
      addressParts.add(place.administrativeArea!); // 都道府県
    }
    
    if (place.locality != null && place.locality!.isNotEmpty) {
      addressParts.add(place.locality!); // 市区町村
    }
    
    if (place.subLocality != null && place.subLocality!.isNotEmpty) {
      addressParts.add(place.subLocality!); // 町域
    }
    
    if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
      addressParts.add(place.thoroughfare!); // 通り名・番地
    }
    
    // アドレスが空の場合、代替情報を使用
    if (addressParts.isEmpty) {
      if (place.name != null && place.name!.isNotEmpty) {
        addressParts.add(place.name!);
      } else if (place.street != null && place.street!.isNotEmpty) {
        addressParts.add(place.street!);
      } else {
        return '現在地';
      }
    }
    
    return addressParts.join('');
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}