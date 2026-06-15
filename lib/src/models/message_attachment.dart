class MessageAttachment {
  const MessageAttachment({
    required this.url,
    this.name,
    this.size,
    this.mimeType,
  });

  final String url;
  final String? name;
  final int? size;
  final String? mimeType;

  factory MessageAttachment.fromJson(Map<String, dynamic> json) =>
      MessageAttachment(
        url: json['url'] as String? ?? json['fileUrl'] as String,
        name: json['name'] as String?,
        size: json['size'] as int?,
        mimeType: json['mimeType'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'url': url,
        'name': name,
        'size': size,
        'mimeType': mimeType,
      };
}
