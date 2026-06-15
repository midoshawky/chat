class PaginatedResult<T> {
  const PaginatedResult({
    required this.data,
    required this.total,
    required this.page,
    required this.perPage,
    required this.lastPage,
    required this.hasNext,
  });

  final List<T> data;
  final int total;
  final int page;
  final int perPage;
  final int lastPage;
  final bool hasNext;

  factory PaginatedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItem,
  ) {
    final meta = json['meta'] as Map<String, dynamic>? ?? {};
    return PaginatedResult<T>(
      data: (json['data'] as List<dynamic>)
          .map((e) => fromItem(e as Map<String, dynamic>))
          .toList(),
      total: meta['total'] as int? ?? 0,
      page: meta['page'] as int? ?? 1,
      perPage: meta['per_page'] as int? ?? 10,
      lastPage: meta['last_page'] as int? ?? 1,
      hasNext: meta['hasNext'] as bool? ?? false,
    );
  }
}
