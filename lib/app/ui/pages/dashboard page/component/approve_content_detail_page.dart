import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/ui/pages/manage%20video%20page/component/AutoScrollingPosters.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../domain/entities/content.dart';
import '../../../../core/constant/image_constant.dart';
import '../../../../provider/videoProvider.dart';
import '../../manage video page/component/DisplayTrailer.dart';
import '../../manage video page/component/StarRatingWidget.dart';

class ApproveContentDetailsPage extends StatelessWidget {
  final Content content;

  const ApproveContentDetailsPage({Key? key, required this.content})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: true).getTheme;

    return Scaffold(
      backgroundColor: selectedThemeData.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: ResponsiveWidget.isDesktop(context)
            ? const SizedBox()
            : Text(
          content.title ?? 'Movie Details',
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              tooltip: 'Delete Content',
              onPressed: () => _showDeleteDialog(context, selectedThemeData),
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
         // _buildBackgroundImage(),
        //  _buildBackgroundOverlay(),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                _buildTitle(),
                const SizedBox(height: 10),
                _buildTags(),
                const SizedBox(height: 20),
                _buildRatingRow(),
                const SizedBox(height: 10),
                _buildPosterRow(),
                const SizedBox(height: 16),
                _buildDescription(),
                const SizedBox(height: 16),
                _buildContentDetails(context, selectedThemeData),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Image.network(
      content.posterUrlList?.isNotEmpty == true
          ? content.posterUrlList!.first
          : 'https://via.placeholder.com/300x400?text=No+Image',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.grey),
    );
  }

  Widget _buildBackgroundOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.black.withOpacity(0.9),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      content.title ?? 'Unknown Title',
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTags() {
    return Row(
      children: [
        if (content.genreList != null && content.genreList!.isNotEmpty)
          _buildTagChip(content.genreList!.first, Colors.blue),
        const SizedBox(width: 10),
        _buildTagChip(content.ageRating ?? 'N/A', Colors.orange),
      ],
    );
  }

  Widget _buildTagChip(String label, Color color) {
    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }

  Widget _buildRatingRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StarRatingWidget(
          rating: content.ratings ?? 0,
          starSize: 20,
          textSize: 16,
        ),
        const SizedBox(width: 4),
        Text(
          '(${content.ratingCount ?? '0'} reviews)',
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
        const Spacer(),
        _ageRating(content.ageRating),
      ],
    );
  }

  Widget _ageRating(String? ageRating) {
    return ageRating != null && ageRating.isNotEmpty
        ? Tooltip(
      message: ageRating == 'U'
          ? 'Universal Age'
          : ageRating == 'U/A'
          ? 'Parental Guidance'
          : 'Adults Only',
      child: Image.asset(
        ageRating == 'U'
            ? ImageConstant.ageUniversal
            : ageRating == 'U/A'
            ? ImageConstant.ageParentalGuidance
            : ImageConstant.ageAdultsOnly,
        height: 40,
        width: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
        const ColoredBox(color: Colors.grey),
      ),
    )
        : const SizedBox();
  }

  Widget _buildPosterRow() {
    return SizedBox(
      width: 300,
      child: AutoScrollingPosters(
        imageUrls: [
          if (content.posterUrlList != null && content.posterUrlList!.isNotEmpty)
            content.posterUrlList!.length > 0 ? content.posterUrlList![0] : "",
          if (content.posterUrlList!.length > 1)
            content.posterUrlList![1],
          if (content.posterUrlList!.length > 2)
            content.posterUrlList![2],
        ],
        height: 300,
        aspectRatio: 2 / 3,
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      content.description ?? 'N/A',
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildContentDetails(BuildContext context, ThemeData selectedThemeData) {
    return Column(
      children: [
        _buildActionButtons(context, selectedThemeData),
        const SizedBox(height: 20),
        ..._buildDetailCards(context),
      ],
    );
  }

  Widget _buildActionButtons(
      BuildContext context, ThemeData selectedThemeData) {
    return Consumer<VideoProvider>(
      builder: (context, provider, child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCustomButton(
                label: 'Watch Trailer',
                icon: Icons.play_circle_fill,
                color: selectedThemeData.primaryColor,
                onPressed: () => _navigateToPage(
                  context,
                  TrailerPage(trailerUrl: content.trailerUrl ?? ''),
                ),
              ),
              SizedBox(width: 16),
              _buildCustomButton(
                label: 'Watch Movie',
                icon: Icons.movie,
                color: selectedThemeData.primaryColor,
                onPressed: () => _navigateToPage(
                  context,
                  TrailerPage(trailerUrl: content.contentUrl ?? ''),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            //  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCustomButton(
                label: content.approvalStatus!='Approved'.toUpperCase()?"Approve":content.approvalStatus!,
                icon: Icons.check_circle,
                color: Colors.green,
                onPressed: () => _handleApproval(context, 'Content Approved',provider),
              ),
              SizedBox(width: 16),
              _buildCustomButton(
                label: 'Reject',
                icon: Icons.cancel,
                color: Colors.red,
                onPressed: () => _showRejectionDialog(context,provider),
              ),
              SizedBox(width: 16),
              _buildCustomButton(
                label: 'Request Edit',
                icon: Icons.edit,
                color: Colors.orange,
                onPressed: () => _showEditRequestDialog(context,provider,content),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 5,
      ),
    );
  }

  List<Widget> _buildDetailCards(BuildContext context) {
    return [
      // Additional Details
      content.approvalStatus!.toLowerCase() == 'rejected'
          ? Text(
        "Reason For Rejection: ${content.reason},",
        style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16
        ),
        textAlign: TextAlign.center,
      )
          : SizedBox(),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          'Edit Request Reason :  ${content.reason??"N/A"}',
          style:
          TextStyle(color:Colors.red, fontWeight: FontWeight.bold,fontSize: 16),
        ),
      ),
      _buildDetailCard('Description', content.description),
      _buildDetailCard('Release Date', content.releaseDate.toString()),
      _buildDetailCard('Runtime', content.runtime?.toString()),
      _buildDetailCard('Uploaded By', content.mediaHouseName),
      _buildDetailCard('Languages', _formatList(content.languageList)),
      _buildDetailCard('Genres', _formatList(content.genreList)),
      _buildDetailCard('Cast', _formatList(content.castList)),
      _buildDetailCard('Director', _formatList(content.directorList)),
      _buildDetailCard('Platform Percentage', (content.adminIncentivePecentage.toString())),
      _buildDetailCard('Media House Percentage', (content.mediaHouseIncentivePecentage.toString())),
    ];
  }

  Widget _buildDetailCard(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.all(9.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Expanded(
            child: Text(value ?? 'N/A', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatList(List<dynamic>? items) {
    if(items != null && items.isNotEmpty){
      return items.join(', ');
    }else{
      return 'N/A';
    }
    // return (items?.isNotEmpty == true) ? items!.join(', ') : 'N/A';
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void _handleApproval(BuildContext context, String message, VideoProvider provider) {
    provider.changeContentStatus(context,"APPROVED", content.id!);
  }

  // Show dialog for rejecting content
  void _showRejectionDialog(BuildContext context,VideoProvider provider) {
    TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reject Content'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              hintText: 'Enter reason for rejection',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                provider.changeContentStatus(context,"REJECTED", content.id!);

                Navigator.of(context).pop();
              },
              child: const Text('Reject'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }


  void _showEditRequestDialog(BuildContext context,VideoProvider provider, Content movie) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Request Edit'),
          content: TextField(
            controller: provider.reasonController,
            decoration: const InputDecoration(
              hintText: 'Enter details of requested edits',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await provider.editContent(context, movie);
                Navigator.pop(context);
              },
              child: const Text('Request Edit'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, ThemeData themeData) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            backgroundColor: themeData.cardColor,
            title: Text(
              'Do you want to delete ${content.title}?',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: themeData.cardColor,
                  foregroundColor: themeData.canvasColor,
                ),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Provider.of<VideoProvider>(context, listen: false)
                      .deleteVideo(content.id!, context);
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  backgroundColor: themeData.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}