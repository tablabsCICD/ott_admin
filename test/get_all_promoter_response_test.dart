import 'package:admin_ott/data/models/response/getAllPromoterResponse.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses legacy Promoters list', () {
    final response = GetAllPromoterResponse.fromJson({
      'success': true,
      'data': {
        'Promoters': [
          {'id': 1, 'promoterName': 'Legacy'}
        ]
      }
    });

    expect(response.data?.promoters, hasLength(1));
    expect(response.data?.promoters?.first.promoterName, 'Legacy');
  });

  test('parses paginated lowercase promoters response', () {
    final response = GetAllPromoterResponse.fromJson({
      'success': true,
      'data': {
        'promoters': {
          'content': [
            {'id': 2, 'promoterName': 'Paged'}
          ]
        }
      }
    });

    expect(response.data?.promoters, hasLength(1));
    expect(response.data?.promoters?.first.promoterName, 'Paged');
  });
}
