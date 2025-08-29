class AiVoice {
  final String id;
  final String name;
  final String character;
  final String description;
  final String iconEmoji;
  final String sampleText;
  final VoiceType type;
  final String? audioUrl; // 実際のアプリでは音声ファイルのURL

  AiVoice({
    required this.id,
    required this.name,
    required this.character,
    required this.description,
    required this.iconEmoji,
    required this.sampleText,
    required this.type,
    this.audioUrl,
  });

  AiVoice copyWith({
    String? id,
    String? name,
    String? character,
    String? description,
    String? iconEmoji,
    String? sampleText,
    VoiceType? type,
    String? audioUrl,
  }) {
    return AiVoice(
      id: id ?? this.id,
      name: name ?? this.name,
      character: character ?? this.character,
      description: description ?? this.description,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      sampleText: sampleText ?? this.sampleText,
      type: type ?? this.type,
      audioUrl: audioUrl ?? this.audioUrl,
    );
  }
}

enum VoiceType {
  cute,      // かわいい系
  cool,      // かっこいい系
  funny,     // 面白い系
  mature,    // 大人っぽい系
  child,     // 子供っぽい系
  robot,     // ロボット系
}

// AI音声データリポジトリ
class AiVoiceRepository {
  static List<AiVoice> getAllVoices() {
    return [
      // かわいい系
      AiVoice(
        id: 'cute_girl',
        name: 'あいちゃん',
        character: 'かわいい女の子',
        description: 'キュートで明るい女の子の声',
        iconEmoji: '🎀',
        sampleText: 'きゃー！これめっちゃかわいいー！みんな見て見てー♡',
        type: VoiceType.cute,
      ),
      AiVoice(
        id: 'sweet_lady',
        name: 'みおり',
        character: '優しいお姉さん',
        description: '癒し系のやわらかい声',
        iconEmoji: '🌸',
        sampleText: 'あらあら〜とってもかわいいわね〜お疲れさま♪',
        type: VoiceType.cute,
      ),
      
      // 面白い系
      AiVoice(
        id: 'funny_uncle',
        name: 'おじさん',
        character: '関西弁のおじさん',
        description: 'ノリの良い関西弁のおじさん',
        iconEmoji: '👨‍🦲',
        sampleText: 'なんやなんや〜！これワイのもんやでー！ガハハハ！',
        type: VoiceType.funny,
      ),
      AiVoice(
        id: 'energetic_boy',
        name: 'たくや',
        character: '元気な少年',
        description: '活発で明るい少年の声',
        iconEmoji: '⚽',
        sampleText: 'わーい！すっげー！ぼくも一緒にやりたーい！',
        type: VoiceType.child,
      ),
      AiVoice(
        id: 'sleepy_guy',
        name: 'ねむねむ',
        character: '眠そうな人',
        description: 'いつも眠そうでゆる〜い声',
        iconEmoji: '😴',
        sampleText: 'うーん...眠いけど...これは...ちょっと面白いかも...',
        type: VoiceType.funny,
      ),
      
      // かっこいい系
      AiVoice(
        id: 'cool_guy',
        name: 'りょう',
        character: 'クールな男性',
        description: '低音でかっこいい男性の声',
        iconEmoji: '😎',
        sampleText: 'フン...まあまあだな。俺にはまだまだ及ばないが。',
        type: VoiceType.cool,
      ),
      AiVoice(
        id: 'mature_lady',
        name: 'エレガント',
        character: '大人の女性',
        description: '上品で落ち着いた女性の声',
        iconEmoji: '👩‍💼',
        sampleText: 'うふふ...なかなかお上手ですこと。私も負けてはいられませんわ。',
        type: VoiceType.mature,
      ),
      
      // ロボット・特殊系
      AiVoice(
        id: 'robot_voice',
        name: 'ロボ太',
        character: 'ロボット',
        description: '機械的なロボットの声',
        iconEmoji: '🤖',
        sampleText: 'カクカク...解析中...デス...面白イ...データ...デス...',
        type: VoiceType.robot,
      ),
      AiVoice(
        id: 'mysterious_voice',
        name: 'ミステリー',
        character: '謎の声',
        description: '神秘的でエコーのかかった声',
        iconEmoji: '🔮',
        sampleText: 'ほほう...興味深い...この運命を変えることができるのか...',
        type: VoiceType.cool,
      ),
      AiVoice(
        id: 'happy_grandma',
        name: 'おばあちゃん',
        character: '優しいおばあちゃん',
        description: 'あたたかいおばあちゃんの声',
        iconEmoji: '👵',
        sampleText: 'あらあら〜いい子ねぇ〜おばあちゃんはとっても嬉しいよ〜',
        type: VoiceType.mature,
      ),
      AiVoice(
        id: 'ninja_voice',
        name: '忍者',
        character: '忍者',
        description: 'こっそり話す忍者の声',
        iconEmoji: '🥷',
        sampleText: 'ニンニン...これは秘密の術でござる...誰にも言ってはならぬ...',
        type: VoiceType.funny,
      ),
      AiVoice(
        id: 'pirate_voice',
        name: '海賊',
        character: '海賊',
        description: '豪快な海賊の声',
        iconEmoji: '🏴‍☠️',
        sampleText: 'ガハハハ！これぞ海の男の宝物だー！お前らもかかってこい！',
        type: VoiceType.funny,
      ),
    ];
  }

  static AiVoice? getVoiceById(String voiceId) {
    try {
      return getAllVoices().firstWhere((voice) => voice.id == voiceId);
    } catch (e) {
      return null;
    }
  }

  static List<AiVoice> getVoicesByType(VoiceType type) {
    return getAllVoices().where((voice) => voice.type == type).toList();
  }
}