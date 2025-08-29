import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/bgm.dart';

class BgmSelectionScreen extends StatefulWidget {
  const BgmSelectionScreen({super.key});

  @override
  State<BgmSelectionScreen> createState() => _BgmSelectionScreenState();
}

class _BgmSelectionScreenState extends State<BgmSelectionScreen> {
  String _searchQuery = '';
  String? _selectedBgmId;
  bool _isPlaying = false;
  String? _playingBgmId;

  // サンプルBGMデータ（実際のアプリでは外部APIやローカルファイルから取得）
  final List<Bgm> _bgmList = [
    Bgm(
      id: '1',
      title: 'Happy Vibes',
      artist: 'DJ Sunny',
      duration: '0:30',
      genre: 'Pop',
      imageUrl: 'https://placehold.co/60x60',
    ),
    Bgm(
      id: '2',
      title: 'Chill Beats',
      artist: 'Lofi Master',
      duration: '0:45',
      genre: 'Lofi',
      imageUrl: 'https://placehold.co/60x60',
    ),
    Bgm(
      id: '3',
      title: 'Urban Flow',
      artist: 'Beat Maker',
      duration: '0:35',
      genre: 'Hip Hop',
      imageUrl: 'https://placehold.co/60x60',
    ),
    Bgm(
      id: '4',
      title: 'Acoustic Dreams',
      artist: 'Guitar Hero',
      duration: '0:40',
      genre: 'Acoustic',
      imageUrl: 'https://placehold.co/60x60',
    ),
    Bgm(
      id: '5',
      title: 'Electronic Pulse',
      artist: 'Synth Wave',
      duration: '0:50',
      genre: 'Electronic',
      imageUrl: 'https://placehold.co/60x60',
    ),
    Bgm(
      id: '6',
      title: 'Jazz Night',
      artist: 'Smooth Sounds',
      duration: '0:55',
      genre: 'Jazz',
      imageUrl: 'https://placehold.co/60x60',
    ),
  ];

  List<Bgm> get _filteredBgmList {
    if (_searchQuery.isEmpty) {
      return _bgmList;
    }
    return _bgmList
        .where((bgm) =>
            bgm.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            bgm.artist.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            bgm.genre.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildGenreFilter(),
            Expanded(child: _buildBgmList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.close,
              color: Colors.white,
              size: 24,
            ),
          ),
          const Expanded(
            child: Text(
              'BGMを選択',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 48), // Balance the close button
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: const TextStyle(
          fontFamily: 'NotoSansJP',
          color: Colors.white,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: '曲やアーティストを検索',
          hintStyle: const TextStyle(
            fontFamily: 'NotoSansJP',
            color: Colors.grey,
            fontSize: 16,
          ),
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildGenreFilter() {
    final genres = ['おすすめ', 'ポップ', 'チル', 'ヒップホップ', 'アコースティック', 'エレクトロ', 'ジャズ'];
    
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: genres.length,
        itemBuilder: (context, index) {
          final genre = genres[index];
          final isSelected = index == 0; // 「おすすめ」を選択状態に
          
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                // ジャンルフィルタ機能
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.grey[600]!,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  genre,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBgmList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredBgmList.length,
      itemBuilder: (context, index) {
        final bgm = _filteredBgmList[index];
        final isSelected = _selectedBgmId == bgm.id;
        final isPlaying = _playingBgmId == bgm.id && _isPlaying;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedBgmId = bgm.id;
            });
            // Instagram風にタップで即座に選択して戻る
            Navigator.pop(context, bgm);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withOpacity(0.15) : Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
              border: isSelected 
                ? Border.all(color: Colors.white, width: 2)
                : null,
            ),
            child: Row(
              children: [
                // アルバムアート
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        bgm.imageUrl,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 56,
                          height: 56,
                          color: Colors.grey[700],
                          child: const Icon(Icons.music_note, color: Colors.white, size: 28),
                        ),
                      ),
                    ),
                    // 再生ボタンオーバーレイ
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              _togglePlayback(bgm.id);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // BGM情報
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bgm.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bgm.artist,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              bgm.genre,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            bgm.duration,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 選択インジケーター
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.black,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }


  void _togglePlayback(String bgmId) {
    setState(() {
      if (_playingBgmId == bgmId && _isPlaying) {
        _isPlaying = false;
      } else {
        _playingBgmId = bgmId;
        _isPlaying = true;
      }
    });

    // 実際のアプリでは、ここで音楽の再生/停止を行う
    print('${_isPlaying ? "Playing" : "Paused"} BGM: $bgmId');
  }
}