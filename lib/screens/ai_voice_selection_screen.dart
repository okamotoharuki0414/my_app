import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/ai_voice.dart';

class AiVoiceSelectionScreen extends StatefulWidget {
  const AiVoiceSelectionScreen({super.key});

  @override
  State<AiVoiceSelectionScreen> createState() => _AiVoiceSelectionScreenState();
}

class _AiVoiceSelectionScreenState extends State<AiVoiceSelectionScreen> {
  String? _selectedVoiceId;
  VoiceType? _selectedType;
  bool _isPlaying = false;
  String? _playingVoiceId;
  late FlutterTts _flutterTts;

  @override
  void initState() {
    super.initState();
    print('AI音声選択画面が開かれました');
    _initTts();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  void _initTts() async {
    _flutterTts = FlutterTts();
    
    try {
      await _flutterTts.setLanguage("ja-JP");
      await _flutterTts.setVolume(1.0);
      print('AI音声選択画面のTTS初期化完了');
    } catch (e) {
      print('AI音声選択画面のTTS初期化エラー: $e');
    }
  }

  final List<VoiceType> _voiceTypes = [
    VoiceType.cute,
    VoiceType.funny,
    VoiceType.cool,
    VoiceType.mature,
    VoiceType.child,
    VoiceType.robot,
  ];

  String _getTypeDisplayName(VoiceType type) {
    switch (type) {
      case VoiceType.cute:
        return 'かわいい';
      case VoiceType.funny:
        return 'おもしろ';
      case VoiceType.cool:
        return 'クール';
      case VoiceType.mature:
        return '大人';
      case VoiceType.child:
        return '子供';
      case VoiceType.robot:
        return 'ロボット';
    }
  }

  Color _getTypeColor(VoiceType type) {
    switch (type) {
      case VoiceType.cute:
        return Colors.pink;
      case VoiceType.funny:
        return Colors.orange;
      case VoiceType.cool:
        return Colors.blue;
      case VoiceType.mature:
        return Colors.purple;
      case VoiceType.child:
        return Colors.green;
      case VoiceType.robot:
        return Colors.grey;
    }
  }

  List<AiVoice> get _filteredVoices {
    final allVoices = AiVoiceRepository.getAllVoices();
    if (_selectedType == null) {
      return allVoices;
    }
    return allVoices.where((voice) => voice.type == _selectedType).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTypeFilter(),
            Expanded(child: _buildVoiceList()),
            _buildSelectedVoicePreview(),
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
              'AI音声を選択',
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

  Widget _buildTypeFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _voiceTypes.length,
        itemBuilder: (context, index) {
          final type = _voiceTypes[index];
          final isSelected = _selectedType == type;
          
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedType = isSelected ? null : type;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? _getTypeColor(type) : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? _getTypeColor(type) : Colors.grey[600]!,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  _getTypeDisplayName(type),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[300],
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

  Widget _buildVoiceList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredVoices.length,
      itemBuilder: (context, index) {
        final voice = _filteredVoices[index];
        final isSelected = _selectedVoiceId == voice.id;
        final isPlaying = _playingVoiceId == voice.id && _isPlaying;

        return GestureDetector(
          onTap: () {
            print('AI音声がタップされました: ${voice.name} (ID: ${voice.id})');
            setState(() {
              _selectedVoiceId = voice.id;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withOpacity(0.15) : Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
              border: isSelected 
                ? Border.all(color: Colors.white, width: 2)
                : null,
            ),
            child: Row(
              children: [
                // キャラクターアイコン
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getTypeColor(voice.type).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: _getTypeColor(voice.type),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      voice.iconEmoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // 音声情報
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        voice.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        voice.character,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        voice.description,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // 再生ボタン
                GestureDetector(
                  onTap: () => _togglePlayback(voice.id),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedVoicePreview() {
    if (_selectedVoiceId == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Text(
          '音声を選択してください',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    final selectedVoice = AiVoiceRepository.getVoiceById(_selectedVoiceId!);
    if (selectedVoice == null) return Container();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                selectedVoice.iconEmoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedVoice.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      selectedVoice.character,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  print('AI音声選択ボタンが押されました: ${selectedVoice?.name}');
                  Navigator.pop(context, selectedVoice);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  '選択',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '「${selectedVoice.sampleText}」',
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _togglePlayback(String voiceId) async {
    setState(() {
      if (_playingVoiceId == voiceId && _isPlaying) {
        _isPlaying = false;
        _playingVoiceId = null;
      } else {
        _playingVoiceId = voiceId;
        _isPlaying = true;
      }
    });

    final voice = AiVoiceRepository.getVoiceById(voiceId);
    if (voice != null) {
      if (_isPlaying && _playingVoiceId == voiceId) {
        try {
          print('AI音声プレビュー再生開始: ${voice.name} - "${voice.sampleText}"');
          
          // 現在の再生を停止
          await _flutterTts.stop();
          
          // キャラクターに応じてTTS設定を調整
          await _configureVoiceTts(voice);
          
          // サンプルテキストを再生
          await _flutterTts.speak(voice.sampleText);
          
          // 再生完了後に状態をリセット
          await Future.delayed(Duration(seconds: 3));
          if (mounted && _playingVoiceId == voiceId) {
            setState(() {
              _isPlaying = false;
              _playingVoiceId = null;
            });
          }
        } catch (e) {
          print('AI音声プレビュー再生エラー: $e');
          setState(() {
            _isPlaying = false;
            _playingVoiceId = null;
          });
        }
      } else {
        print('AI音声プレビュー停止: ${voice.name}');
        await _flutterTts.stop();
      }
    }
  }

  Future<void> _configureVoiceTts(AiVoice voice) async {
    try {
      print('AI音声プレビュー設定: ${voice.name} (${voice.type})');
      
      await _flutterTts.setVolume(1.0);
      
      // TikTok風に大きく違いがある音声設定
      switch (voice.type) {
        case VoiceType.cute:
          await _flutterTts.setSpeechRate(0.3); // 極めてゆっくり
          await _flutterTts.setPitch(2.0); // 最高音程
          break;
        case VoiceType.funny:
          await _flutterTts.setSpeechRate(1.5); // とても速い
          await _flutterTts.setPitch(0.5); // とても低い
          break;
        case VoiceType.cool:
          await _flutterTts.setSpeechRate(0.6); // ゆっくり
          await _flutterTts.setPitch(0.3); // 極めて低い
          break;
        case VoiceType.mature:
          await _flutterTts.setSpeechRate(0.5); // ゆっくり
          await _flutterTts.setPitch(0.4); // とても低い
          break;
        case VoiceType.child:
          await _flutterTts.setSpeechRate(1.8); // 極めて速い
          await _flutterTts.setPitch(2.0); // 最高音程
          break;
        case VoiceType.robot:
          await _flutterTts.setSpeechRate(0.2); // 極めてゆっくり
          await _flutterTts.setPitch(1.0); // 普通
          break;
      }
      
      await Future.delayed(Duration(milliseconds: 500));
      print('AI音声プレビュー設定完了');
    } catch (e) {
      print('AI音声プレビュー設定エラー: $e');
    }
  }
}