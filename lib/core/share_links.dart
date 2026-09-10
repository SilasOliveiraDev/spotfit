/// Links no formato spotfit://playlist/{token} (Android e iOS).
String? parseShareToken(Uri uri) {
  if (uri.scheme == 'spotfit') {
    if (uri.host == 'playlist' || uri.host == 'p') {
      if (uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.last.trim();
      }
    }
    if (uri.pathSegments.length >= 2 && uri.pathSegments.first == 'playlist') {
      return uri.pathSegments[1].trim();
    }
  }
  if (uri.pathSegments.length >= 2 && uri.pathSegments.first == 'p') {
    final token = uri.pathSegments[1].trim();
    if (token.isNotEmpty) return token;
  }
  return null;
}
