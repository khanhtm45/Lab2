class RecentSearchEntry {
  final String topic;
  final DateTime searchedAt;

  const RecentSearchEntry({
    required this.topic,
    required this.searchedAt,
  });

  String encode() => '$topic|${searchedAt.millisecondsSinceEpoch}';

  static RecentSearchEntry decode(String raw) {
    final separator = raw.lastIndexOf('|');
    if (separator > 0) {
      final topic = raw.substring(0, separator);
      final millis = int.tryParse(raw.substring(separator + 1));
      if (millis != null) {
        return RecentSearchEntry(
          topic: topic,
          searchedAt: DateTime.fromMillisecondsSinceEpoch(millis),
        );
      }
    }
    return RecentSearchEntry(topic: raw, searchedAt: DateTime.now());
  }

  String get relativeTimeLabel {
    final diff = DateTime.now().difference(searchedAt);
    if (diff.inMinutes < 60) {
      final minutes = diff.inMinutes.clamp(1, 59);
      return 'searched $minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    }
    if (diff.inHours < 24) {
      final hours = diff.inHours;
      return 'searched $hours ${hours == 1 ? 'hour' : 'hours'} ago';
    }
    if (diff.inDays == 1) return 'searched yesterday';
    if (diff.inDays < 7) {
      return 'searched ${diff.inDays} days ago';
    }
    final date = searchedAt;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return 'searched ${months[date.month - 1]} ${date.day}';
  }
}
