class SourceModel {
  final String? id;
  final String name;

  SourceModel({this.id, required this.name});

  factory SourceModel.fromJson(Map<String, dynamic> json) {
    return SourceModel(
      id: json['id'] as String?,
      name: json['name'] as String? ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class ArticleModel {
  final String? id;
  final SourceModel? source;
  final String? author;
  final String title;
  final String? description;
  final String url;
  final String? urlToImage;
  final String? publishedAt;
  final String? content;
  final DateTime? cachedAt;

  ArticleModel({
    this.id,
    this.source,
    this.author,
    required this.title,
    this.description,
    required this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
    this.cachedAt,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      source: json['source'] != null
          ? SourceModel.fromJson(json['source'] as Map<String, dynamic>)
          : null,
      author: json['author'] as String?,
      title: json['title'] as String? ?? 'No Title',
      description: json['description'] as String?,
      url: json['url'] as String? ?? '',
      urlToImage: json['urlToImage'] as String?,
      publishedAt: json['publishedAt'] as String?,
      content: json['content'] as String?,
    );
  }

  factory ArticleModel.fromMap(Map<String, dynamic> map) {
    return ArticleModel(
      id: map['id']?.toString(),
      source: map['sourceName'] != null
          ? SourceModel(
              id: map['sourceId'] as String?,
              name: map['sourceName'] as String,
            )
          : null,
      author: map['author'] as String?,
      title: map['title'] as String? ?? 'No Title',
      description: map['description'] as String?,
      url: map['url'] as String? ?? '',
      urlToImage: map['urlToImage'] as String?,
      publishedAt: map['publishedAt'] as String?,
      content: map['content'] as String?,
      cachedAt: map['cachedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['cachedAt'] as int)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sourceId': source?.id,
      'sourceName': source?.name,
      'author': author,
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt,
      'content': content,
      'cachedAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  bool get isExpired {
    if (cachedAt == null) return true;
    return DateTime.now().difference(cachedAt!).inHours >= 1;
  }

  @override
  String toString() => 'ArticleModel(title: $title, url: $url)';
}
