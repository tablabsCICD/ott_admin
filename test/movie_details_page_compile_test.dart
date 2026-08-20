import 'package:admin_ott/app/ui/pages/manage%20content%20page/component/add_video.dart';
import 'package:admin_ott/app/ui/pages/manage%20content%20page/component/movie_card.dart';
import 'package:admin_ott/app/ui/pages/manage%20content%20page/component/movie_details_page.dart';
import 'package:admin_ott/domain/entities/content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('movie detail page accepts content with total purchases', () {
    final content = Content.fromJson({'id': 1, 'totalPurchase': 125});
    final page = MovieDetailsPage(
      content: content,
    );

    expect(page.content.totalPurchase, 125);
    expect(AddDataWidget(editingContent: content).editingContent?.id, 1);
    expect(MovieCard(movie: content).movie.id, 1);
  });
}
