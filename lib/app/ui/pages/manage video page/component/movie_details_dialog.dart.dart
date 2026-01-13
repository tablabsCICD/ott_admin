import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/ui/pages/manage%20media%20house%20page/component/movie_sales_chart.dart';
import 'package:admin_ott/app/ui/pages/manage%20video%20page/component/DisplayTrailer.dart';
import 'package:admin_ott/data/models/movie_model.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../domain/entities/content.dart';
import '../../../../provider/videoProvider.dart';
import 'AutoScrollingPosters.dart';
import 'StarRatingWidget.dart';

void showMovieDetailsDialog(BuildContext context, Content movie) {
  var selectedThemeData =
      Provider.of<ThemeProvider>(context, listen: false).getTheme;
  var provider =
  Provider.of<VideoProvider>(context, listen: false);
  provider.contentRevenueGraph(0,movie.id!,'','');
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  (movie.posterUrlList != null && movie.posterUrlList!.isNotEmpty)
                      ? movie.posterUrlList!.first
                      : 'https://via.placeholder.com/300x400?text=No+Image',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.black,
                    child: const Center(
                      child: Icon(Icons.error, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            // Background Overlay
            Container(
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
            ),
            // Dialog Content
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          // Close Button
                          Align(
                            alignment: Alignment.topLeft,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () => Navigator.of(context).pop(),
                            ),

                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteMovie(context,movie,selectedThemeData),
                            ),
                          ),
                          // Category and Age Rating Chips
                          Row(
                            children: [
                              if (movie.genreList != null &&
                                  movie.genreList!.isNotEmpty)
                                _buildTagChip(movie.genreList!.first,
                                    selectedThemeData.primaryColor),
                              const SizedBox(width: 10),
                              _buildTagChip(movie.ageRating ?? '-', Colors.blue),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Title Section
                          Text(
                            movie.title ?? 'Unknown Title',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Description Section
                          Text(
                            movie.description ?? 'No description available.',
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              StarRatingWidget(
                                rating: movie.ratings??0,
                                starSize: 20,
                                textSize: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${movie.ratingCount ?? '0'} reviews)',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),

                            ],
                          ),
                          SizedBox(height: 10),
                          (movie.posterUrlList != null && movie.posterUrlList!.isNotEmpty)
                              ? Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  width: 300,
                                  child: AutoScrollingPosters(
                                    imageUrls: [
                                      if (movie.posterUrlList != null && movie.posterUrlList!.isNotEmpty)
                                        movie.posterUrlList!.length > 0 ? movie.posterUrlList![0] : "",
                                      if (movie.posterUrlList!.length > 1)
                                        movie.posterUrlList![1],
                                      if (movie.posterUrlList!.length > 2)
                                        movie.posterUrlList![2],
                                    ],
                                    height: 300,
                                    aspectRatio: 2 / 3,
                                  ),
                                ),
                              ),
                            ],
                          )
                              : SizedBox.shrink(),
                          const SizedBox(height: 16),
                          const SizedBox(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            //  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildCustomButton(
                                label: movie.approvalStatus!='Approved'.toUpperCase()?"Approve":movie.approvalStatus!,
                                icon: Icons.check_circle,
                                color: Colors.green,
                                onPressed: () => _handleApproval(context, 'Content Approved',provider,movie),
                              ),
                              SizedBox(width: 16),
                              _buildCustomButton(
                                label: 'Reject',
                                icon: Icons.cancel,
                                color: Colors.red,
                                onPressed: () => _showRejectionDialog(context,provider,movie),
                              ),
                              SizedBox(width: 16),
                              _buildCustomButton(
                                label: 'Request Edit',
                                icon: Icons.edit,
                                color: Colors.orange,
                                onPressed: () => _showEditRequestDialog(context,provider,movie),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Action Buttons
                          _buildActionButtons(context, selectedThemeData, movie),
                          const SizedBox(height: 20),
                          // Additional Details
                          movie.approvalStatus!.toLowerCase() == 'rejected'
                              ? Text(
                            "Reason For Rejection: ${movie.reason},",
                            style: TextStyle(
                                color: selectedThemeData.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16
                            ),
                            textAlign: TextAlign.center,
                          )
                              : SizedBox(),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'Edit Request Reason :  ${movie.reason??"N/A"}',
                              style:
                              TextStyle(color:selectedThemeData.primaryColor, fontWeight: FontWeight.bold,fontSize: 16),
                            ),
                          ),
                          _buildDetailCard(
                              'Release Date', movie.releaseDate.toString() ?? '-'),
                          _buildDetailCard('Description',
                              movie.description ?? 'No description available.'),
                          _buildDetailCard(
                              'Runtime', '${movie.runtime ?? '-'} minutes'),
                          _buildDetailCard(
                              'Director',
                              (movie.directorList != null &&
                                  movie.directorList!.isNotEmpty)
                                  ? movie.directorList!.first
                                  : 'Unknown'),
                          _buildDetailCard('Price', '₹ ${movie.price ?? '-'}'),
                          _buildDetailCard('Genres', movie.type ?? '-'),
                          _buildDetailCard('Revenue',
                              '₹ ${movie.totalRevenue ?? 'N/A'}'),
                          _buildDetailCard(
                              'Cast',
                              (movie.castList != null &&
                                  movie.castList!.isNotEmpty)
                                  ? movie.castList!.join(', ')
                                  : 'N/A'),
                          _buildDetailCard('Platform Percentage', movie.adminIncentivePecentage.toString() ?? 'N/A'),
                          _buildDetailCard('MediaHouse Percentage', movie.mediaHouseIncentivePecentage.toString() ?? 'N/A'),
                        ],
                      ),
                    ),
                    ResponsiveWidget.isDesktop(context)
                        ? Expanded(
                      flex: 6,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 550,
                          child: MovieSalesChart(
                            title: 'MovieDetailsGraph',
                            yAxisLabel: 'sales',
                            graphNumber: 0,
                            contentId: movie.id!,
                            metrics: ["revenue"],
                          ),
                        ),
                      ),
                    )
                        : const SizedBox(),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildTagChip(String label, Color color) {
  return Chip(
    label: Text(label, style: const TextStyle(color: Colors.white)),
    backgroundColor: color,
  );
}


Widget _buildActionButtons(BuildContext context, ThemeData selectedThemeData, Content movie) {
  return ResponsiveWidget.isMobile(context)
      ? Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildCustomButton(
              label: 'Watch Trailer',
              icon: Icons.play_circle_fill,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                    builder: (context) =>
                    TrailerPage(trailerUrl: movie.trailerUrl ?? '')));
              },
              color: selectedThemeData.primaryColor,
            ),
            const SizedBox(width: 10),
            _buildCustomButton(
              label: 'Watch Movie',
              icon: Icons.movie,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                    builder: (context) =>
                    TrailerPage(trailerUrl: movie.contentUrl ?? '')));
              },
              color: selectedThemeData.primaryColor,
            ),
          ],
        )
      : Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildCustomButton(
              label: 'Watch Trailer',
              icon: Icons.play_circle_fill,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            TrailerPage(trailerUrl: movie.trailerUrl ?? '')));
              },
              color: selectedThemeData.primaryColor,
            ),
            const SizedBox(width: 10),
            _buildCustomButton(
              label: 'Watch Movie',
              icon: Icons.movie,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            TrailerPage(trailerUrl: movie.contentUrl ?? '')));
              },
              color: selectedThemeData.primaryColor,
            ),
          ],
        );
}

Widget _buildCustomButton({
  required String label,
  required IconData icon,
  required VoidCallback onPressed,
  required Color color,
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

Widget _buildDetailCard(String title, String value) {
  return SizedBox(
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  );
}

void _handleApproval(BuildContext context, String message, VideoProvider provider, Content movie) {
  provider.changeContentStatus(context,"APPROVED", movie.id!);
}

// Show dialog for rejecting content
void _showRejectionDialog(BuildContext context,VideoProvider provider, Content movie) {
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
              provider.changeContentStatus(context,"REJECTED", movie.id!);

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

// Show dialog for requesting content edit
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


void deleteMovie(BuildContext context,Content content,ThemeData themeData) {
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
                  Provider.of<VideoProvider>(context, listen: false).deleteVideo(content.id!,context);

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
