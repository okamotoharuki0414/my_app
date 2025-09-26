import 'package:flutter/material.dart';
import '../models/poll.dart';

class PollWidget extends StatefulWidget {
  final Poll poll;
  final Function(Poll, List<int>) onVote;
  final String currentUserId;

  const PollWidget({
    super.key,
    required this.poll,
    required this.onVote,
    required this.currentUserId,
  });

  @override
  State<PollWidget> createState() => _PollWidgetState();
}

class _PollWidgetState extends State<PollWidget> {
  List<int> _selectedOptions = [];
  bool _hasVoted = false;

  @override
  void initState() {
    super.initState();
    _hasVoted = widget.poll.hasUserVoted(widget.currentUserId);
    if (_hasVoted) {
      _selectedOptions = widget.poll.getUserVotes(widget.currentUserId);
    }
  }

  void _toggleOption(int index) {
    if (_hasVoted || widget.poll.isExpired) return;

    setState(() {
      if (widget.poll.allowMultipleChoice) {
        // 複数選択モード
        if (_selectedOptions.contains(index)) {
          _selectedOptions.remove(index);
        } else {
          _selectedOptions.add(index);
        }
      } else {
        // 単一選択モード
        if (_selectedOptions.contains(index)) {
          _selectedOptions.clear();
        } else {
          _selectedOptions = [index];
        }
      }
    });
  }

  void _submitVote() {
    if (_selectedOptions.isNotEmpty && !_hasVoted && !widget.poll.isExpired) {
      widget.onVote(widget.poll, _selectedOptions);
      setState(() {
        _hasVoted = true;
      });
    }
  }

  String _formatTimeRemaining() {
    if (widget.poll.expiresAt == null) return '';
    
    final now = DateTime.now();
    final remaining = widget.poll.expiresAt!.difference(now);
    
    if (remaining.isNegative) return '終了';
    
    if (remaining.inDays > 0) {
      return '${remaining.inDays}日後に終了';
    } else if (remaining.inHours > 0) {
      return '${remaining.inHours}時間後に終了';
    } else if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes}分後に終了';
    } else {
      return 'まもなく終了';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.poll, size: 14, color: Colors.blue[600]),
                    const SizedBox(width: 4),
                    Text(
                      'アンケート',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (widget.poll.expiresAt != null)
                Text(
                  _formatTimeRemaining(),
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.poll.isExpired ? Colors.red : Colors.grey[600],
                    fontWeight: widget.poll.isExpired ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 質問
          Text(
            widget.poll.question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 選択肢
          ...widget.poll.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = _selectedOptions.contains(index);
            final percentage = widget.poll.getOptionPercentage(index);
            final showResults = _hasVoted || widget.poll.isExpired;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => _toggleOption(index),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: showResults
                        ? (isSelected ? Colors.blue[50] : Colors.grey[50])
                        : (isSelected ? Colors.blue[50] : Colors.white),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // 結果のプログレスバー
                      if (showResults)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: percentage / 100,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? Colors.blue.withOpacity(0.2)
                                      : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        ),
                      
                      // 内容
                      Row(
                        children: [
                          // 選択アイコン
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: widget.poll.allowMultipleChoice 
                                  ? BoxShape.rectangle 
                                  : BoxShape.circle,
                              color: isSelected ? Colors.blue : Colors.transparent,
                              border: Border.all(
                                color: isSelected ? Colors.blue : Colors.grey[400]!,
                                width: 2,
                              ),
                              borderRadius: widget.poll.allowMultipleChoice 
                                  ? BorderRadius.circular(3) 
                                  : null,
                            ),
                            child: isSelected
                                ? Icon(
                                    widget.poll.allowMultipleChoice 
                                        ? Icons.check 
                                        : Icons.circle,
                                    size: widget.poll.allowMultipleChoice ? 14 : 8,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          
                          const SizedBox(width: 12),
                          
                          // 選択肢テキスト
                          Expanded(
                            child: Text(
                              option.text,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          
                          // 結果パーセンテージ
                          if (showResults)
                            Text(
                              '${percentage.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.blue : Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
          
          const SizedBox(height: 16),
          
          // 投票ボタンと総投票数
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.poll.totalVotes}票',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              
              if (!_hasVoted && !widget.poll.isExpired && _selectedOptions.isNotEmpty)
                ElevatedButton(
                  onPressed: _submitVote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    '投票',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          
          // 複数選択の説明
          if (widget.poll.allowMultipleChoice && !_hasVoted && !widget.poll.isExpired)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '複数選択できます',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}