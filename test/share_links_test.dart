import 'package:flutter_test/flutter_test.dart';
import 'package:spotfit/core/share_links.dart';

void main() {
  test('lê token de spotfit://playlist/{token}', () {
    expect(
      parseShareToken(Uri.parse('spotfit://playlist/abc123tokenvalue')),
      'abc123tokenvalue',
    );
  });

  test('ignora uri sem token', () {
    expect(parseShareToken(Uri.parse('spotfit://home')), isNull);
  });
}
