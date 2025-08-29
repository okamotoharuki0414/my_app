class Poll {
  final String id;
  final String question;
  final List<PollOption> options;
  final bool allowMultipleChoice;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final Map<String, List<int>> userVotes; // userId -> list of option indices
  final int totalVotes;

  Poll({
    required this.id,
    required this.question,
    required this.options,
    this.allowMultipleChoice = false,
    this.expiresAt,
    required this.createdAt,
    Map<String, List<int>>? userVotes,
    int? totalVotes,
  }) : userVotes = userVotes ?? {},
       totalVotes = totalVotes ?? 0;

  Poll copyWith({
    String? id,
    String? question,
    List<PollOption>? options,
    bool? allowMultipleChoice,
    DateTime? expiresAt,
    DateTime? createdAt,
    Map<String, List<int>>? userVotes,
    int? totalVotes,
  }) {
    return Poll(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      allowMultipleChoice: allowMultipleChoice ?? this.allowMultipleChoice,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      userVotes: userVotes ?? this.userVotes,
      totalVotes: totalVotes ?? this.totalVotes,
    );
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool hasUserVoted(String userId) {
    return userVotes.containsKey(userId);
  }

  List<int> getUserVotes(String userId) {
    return userVotes[userId] ?? [];
  }

  double getOptionPercentage(int optionIndex) {
    if (totalVotes == 0) return 0.0;
    return (options[optionIndex].voteCount / totalVotes) * 100;
  }
}

class PollOption {
  final String text;
  final int voteCount;
  final String? emoji;

  PollOption({
    required this.text,
    this.voteCount = 0,
    this.emoji,
  });

  PollOption copyWith({
    String? text,
    int? voteCount,
    String? emoji,
  }) {
    return PollOption(
      text: text ?? this.text,
      voteCount: voteCount ?? this.voteCount,
      emoji: emoji ?? this.emoji,
    );
  }
}

// アンケート作成用の入力クラス
class PollInput {
  String question;
  List<String> options;
  bool allowMultipleChoice;
  int? durationHours;

  PollInput({
    this.question = '',
    List<String>? options,
    this.allowMultipleChoice = false,
    this.durationHours,
  }) : options = options ?? ['', ''];

  bool get isValid {
    return question.trim().isNotEmpty &&
           options.length >= 2 &&
           options.every((option) => option.trim().isNotEmpty);
  }

  Poll toPoll(String id) {
    final now = DateTime.now();
    return Poll(
      id: id,
      question: question.trim(),
      options: options
          .where((option) => option.trim().isNotEmpty)
          .map((option) => PollOption(text: option.trim()))
          .toList(),
      allowMultipleChoice: allowMultipleChoice,
      expiresAt: durationHours != null 
          ? now.add(Duration(hours: durationHours!))
          : null,
      createdAt: now,
    );
  }
}