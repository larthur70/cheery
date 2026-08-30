/// Heuristic: PostgREST / dart:io / browser fetch failures while offline.
bool isLikelyNetworkError(Object error) {
  final text = error.toString().toLowerCase();
  return text.contains('socket') ||
      text.contains('network') ||
      text.contains('failed host') ||
      text.contains('connection') ||
      text.contains('offline') ||
      text.contains('clientexception') ||
      text.contains('xmlhttprequest') ||
      text.contains('failed to fetch') ||
      text.contains('os error');
}

/// Expired / revoked JWT — the only case we should drop the local session.
bool isInvalidSessionError(Object error) {
  final text = error.toString().toLowerCase();
  return text.contains('jwt expired') ||
      text.contains('invalid jwt') ||
      text.contains('invalid claim') ||
      text.contains('session not found') ||
      text.contains('refresh_token') && text.contains('not found');
}
