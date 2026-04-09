class CachePolicy {
  const CachePolicy({
    required this.catalogTtl,
    required this.progressTtl,
  });

  final Duration catalogTtl;
  final Duration progressTtl;

  bool isFresh({
    required DateTime fetchedAt,
    required Duration ttl,
    DateTime? now,
  }) {
    final t = now ?? DateTime.now();
    return t.difference(fetchedAt) <= ttl;
  }

  static const CachePolicy defaultPolicy = CachePolicy(
    catalogTtl: Duration(hours: 24),
    progressTtl: Duration(seconds: 60),
  );
}

