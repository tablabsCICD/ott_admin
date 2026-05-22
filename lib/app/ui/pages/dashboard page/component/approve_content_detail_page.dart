import 'package:admin_ott/domain/entities/content.dart';
import 'package:flutter/material.dart';

import '../../manage content page/component/movie_details_page.dart';

class ApproveContentDetailsPage extends StatelessWidget {
  final Content content;

  const ApproveContentDetailsPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return MovieDetailsPage(
      content: content,
      popOnStatusChange: true,
    );
  }
}
