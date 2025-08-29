import 'package:flutter/material.dart';
import '../models/poll.dart';

class PollCreationScreen extends StatefulWidget {
  const PollCreationScreen({super.key});

  @override
  State<PollCreationScreen> createState() => _PollCreationScreenState();
}

class _PollCreationScreenState extends State<PollCreationScreen> {
  final PollInput _pollInput = PollInput();
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 選択肢配列のサイズをコントローラー数に合わせる
    while (_pollInput.options.length < _optionControllers.length) {
      _pollInput.options.add('');
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _addOption() {
    if (_optionControllers.length < 6) {
      setState(() {
        _optionControllers.add(TextEditingController());
        _pollInput.options.add('');
      });
      
      // 新しい選択肢にスクロール
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _removeOption(int index) {
    if (_optionControllers.length > 2) {
      setState(() {
        _optionControllers[index].dispose();
        _optionControllers.removeAt(index);
        _pollInput.options.removeAt(index);
      });
    }
  }

  void _createPoll() {
    print('PollCreation: Attempting to create poll');
    print('PollCreation: Question: "${_pollInput.question}"');
    print('PollCreation: Options: ${_pollInput.options}');
    print('PollCreation: Is valid: ${_pollInput.isValid}');
    
    // 質問が空の場合
    if (_pollInput.question.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('質問を入力してください'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // 選択肢が2個未満または空の場合
    final validOptions = _pollInput.options.where((option) => option.trim().isNotEmpty).toList();
    if (validOptions.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('選択肢を2つ以上入力してください'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_pollInput.isValid) {
      final poll = _pollInput.toPoll(DateTime.now().millisecondsSinceEpoch.toString());
      print('PollCreation: Poll created successfully: ${poll.question}');
      Navigator.of(context).pop(poll);
    } else {
      print('PollCreation: Poll validation failed');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('アンケートの作成に失敗しました'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'アンケート作成',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _createPoll,
            child: Text(
              '作成',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // アンケートプレビュー
            _buildPollPreview(),
            const SizedBox(height: 24),
            
            // 質問入力
            _buildQuestionInput(),
            const SizedBox(height: 24),
            
            // 選択肢入力
            _buildOptionsInput(),
            const SizedBox(height: 24),
            
            // 設定オプション
            _buildSettings(),
            const SizedBox(height: 80), // 下部の余白
          ],
        ),
      ),
    );
  }

  Widget _buildPollPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.poll, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              const Text(
                'プレビュー',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _pollInput.question.isEmpty ? '質問を入力してください' : _pollInput.question,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _pollInput.question.isEmpty ? Colors.grey : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          ..._pollInput.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            if (option.trim().isEmpty) return const SizedBox.shrink();
            
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey[400]!, width: 2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                    Text(
                      '0%',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildQuestionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '質問',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _questionController,
          maxLines: 3,
          maxLength: 200,
          style: const TextStyle(
            fontFamily: 'NotoSansJP',
            fontSize: 16,
            color: Colors.black87,
          ),
          onChanged: (value) {
            setState(() {
              _pollInput.question = value;
            });
          },
          decoration: InputDecoration(
            hintText: '例: 今度のランチはどこにしますか？',
            hintStyle: const TextStyle(
              fontFamily: 'NotoSansJP',
              color: Colors.grey,
              fontSize: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '選択肢',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (_optionControllers.length < 6)
              TextButton.icon(
                onPressed: _addOption,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('追加'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ..._optionControllers.asMap().entries.map((entry) {
          final index = entry.key;
          final controller = entry.value;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(
                      fontFamily: 'NotoSansJP',
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (index < _pollInput.options.length) {
                          _pollInput.options[index] = value;
                        }
                      });
                    },
                    decoration: InputDecoration(
                      hintText: '選択肢 ${index + 1}',
                      hintStyle: const TextStyle(
                        fontFamily: 'NotoSansJP',
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                if (_optionControllers.length > 2)
                  IconButton(
                    onPressed: () => _removeOption(index),
                    icon: Icon(Icons.remove_circle_outline, color: Colors.red[400]),
                    padding: const EdgeInsets.all(8),
                  ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '設定',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        
        // 複数選択許可
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '複数選択を許可',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '回答者が複数の選択肢を選べます',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: _pollInput.allowMultipleChoice,
                    onChanged: (value) {
                      setState(() {
                        _pollInput.allowMultipleChoice = value;
                      });
                    },
                    activeColor: Colors.blue,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              
              // 期限設定
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'アンケート期限',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _pollInput.durationHours == null 
                            ? '期限なし' 
                            : '${_pollInput.durationHours}時間後に終了',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  DropdownButton<int?>(
                    value: _pollInput.durationHours,
                    onChanged: (value) {
                      setState(() {
                        _pollInput.durationHours = value;
                      });
                    },
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('期限なし'),
                      ),
                      const DropdownMenuItem<int?>(
                        value: 1,
                        child: Text('1時間'),
                      ),
                      const DropdownMenuItem<int?>(
                        value: 6,
                        child: Text('6時間'),
                      ),
                      const DropdownMenuItem<int?>(
                        value: 24,
                        child: Text('1日'),
                      ),
                      const DropdownMenuItem<int?>(
                        value: 168,
                        child: Text('1週間'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}