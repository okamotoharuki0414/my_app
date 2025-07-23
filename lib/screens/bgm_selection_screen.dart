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
            if (_selectedBgmId != null) _buildBottomControls(),
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
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'BGMを検索',
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildGenreFilter() {
    final genres = ['すべて', 'Pop', 'Lofi', 'Hip Hop', 'Acoustic', 'Electronic', 'Jazz'];
    
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: genres.length,
        itemBuilder: (context, index) {
          final genre = genres[index];
          final isSelected = index == 0; // 仮で「すべて」を選択状態に
          
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                genre,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontSize: 14,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                // ジャンルフィルタ機能は後で実装
              },
              backgroundColor: Colors.grey[800],
              selectedColor: Colors.white,
              checkmarkColor: Colors.black,
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

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    bgm.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[800],
                      child: const Icon(Icons.music_note, color: Colors.white),
                    ),
                  ),
                ),
                if (isPlaying)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.pause,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(
              bgm.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bgm.artist,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        bgm.genre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      bgm.duration,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    _togglePlayback(bgm.id);
                  },
                  icon: Icon(
                    isPlaying ? Icons.pause_circle : Icons.play_circle,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                Radio<String>(
                  value: bgm.id,
                  groupValue: _selectedBgmId,
                  onChanged: (value) {
                    setState(() {
                      _selectedBgmId = value;
                    });
                  },
                  activeColor: Colors.white,
                ),
              ],
            ),
            onTap: () {
              setState(() {
                _selectedBgmId = bgm.id;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildBottomControls() {
    final selectedBgm = _bgmList.firstWhere((bgm) => bgm.id == _selectedBgmId);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(
          top: BorderSide(color: Colors.grey[800]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              selectedBgm.imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 50,
                height: 50,
                color: Colors.grey[800],
                child: const Icon(Icons.music_note, color: Colors.white, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedBgm.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  selectedBgm.artist,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // 選択したBGMを返す
              Navigator.pop(context, selectedBgm);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              '完了',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
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