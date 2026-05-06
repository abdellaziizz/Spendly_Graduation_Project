class Message {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  // Enhanced reply state
  final bool isEnhanced; // true when this message is an enhanced AI reply
  final bool isEnhancedLoading; // true when waiting for enhanced reply
  final bool isRetryable; // true when user can retry enhanced generation

  Message({
    String? id,
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.isEnhanced = false,
    this.isEnhancedLoading = false,
    this.isRetryable = false,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp = timestamp ?? DateTime.now();
}
