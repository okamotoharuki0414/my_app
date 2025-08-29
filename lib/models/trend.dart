class Trend {
  final String tag;
  final String postsCount;
  final String category;
  final bool isPromoted;

  Trend({
    required this.tag,
    required this.postsCount,
    required this.category,
    this.isPromoted = false,
  });
}