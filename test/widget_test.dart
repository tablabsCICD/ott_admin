import 'package:flutter_test/flutter_test.dart';
import 'package:admin_ott/domain/entities/content.dart';

void main() {
  test('App entity smoke test', () {
    final content = Content(id: 1, title: 'OTT Admin');
    expect(content.id, 1);
    expect(content.title, 'OTT Admin');
  });
}
