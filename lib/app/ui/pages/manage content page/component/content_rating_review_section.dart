import 'dart:convert';
import 'package:admin_ott/app/core/constant/api_constant.dart';
import 'package:admin_ott/app/core/network/api_helper.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ContentReview {
  final int? reviewId;
  final int? contentId;
  final int? userId;
  final String? username;
  final String? userProfile;
  final num? rating;
  final String? title;
  final String? comment;
  final dynamic createdAt;

  ContentReview({
    this.reviewId,
    this.contentId,
    this.userId,
    this.username,
    this.userProfile,
    this.rating,
    this.title,
    this.comment,
    this.createdAt,
  });

  factory ContentReview.fromJson(Map<String, dynamic> json) {
    return ContentReview(
      reviewId: json['reviewId'] ?? json['id'],
      contentId: json['contentId'],
      userId: json['userId'],
      username: json['username'] ?? 'Anonymous User',
      userProfile: json['userProfile'],
      rating: json['rating'] is num
          ? json['rating'] as num
          : num.tryParse('${json['rating']}'),
      title: json['title'],
      comment: json['comment'],
      createdAt: json['createdAt'],
    );
  }

  String get formattedDate {
    if (createdAt == null) return '';
    try {
      if (createdAt is int) {
        final dt = DateTime.fromMillisecondsSinceEpoch(createdAt as int);
        return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
      } else if (createdAt is String) {
        final dt = DateTime.parse(createdAt as String);
        return DateFormat('dd MMM yyyy, hh:mm a').format(dt.toLocal());
      }
    } catch (_) {}
    return '$createdAt';
  }
}

class ReviewRatingData {
  final num? ratingAvg;
  final List<ContentReview> reviews;

  ReviewRatingData({
    this.ratingAvg,
    required this.reviews,
  });

  factory ReviewRatingData.fromJson(Map<String, dynamic> json) {
    final reviewsJson = json['reviews'] as List? ?? [];
    return ReviewRatingData(
      ratingAvg: json['ratingAvg'] is num
          ? json['ratingAvg'] as num
          : num.tryParse('${json['ratingAvg']}'),
      reviews: reviewsJson
          .map((r) => ContentReview.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }

  int get count5Star =>
      reviews.where((r) => (r.rating ?? 0).round() == 5).length;
  int get count4Star =>
      reviews.where((r) => (r.rating ?? 0).round() == 4).length;
  int get count3Star =>
      reviews.where((r) => (r.rating ?? 0).round() == 3).length;
  int get count2Star =>
      reviews.where((r) => (r.rating ?? 0).round() == 2).length;
  int get count1Star =>
      reviews.where((r) => (r.rating ?? 0).round() == 1).length;
}

class ContentRatingReviewSection extends StatefulWidget {
  final int contentId;
  final String? contentTitle;

  const ContentRatingReviewSection({
    super.key,
    required this.contentId,
    this.contentTitle,
  });

  @override
  State<ContentRatingReviewSection> createState() =>
      _ContentRatingReviewSectionState();
}

class _ContentRatingReviewSectionState
    extends State<ContentRatingReviewSection> {
  bool _isLoading = false;
  String? _errorMessage;
  ReviewRatingData? _ratingData;

  int? _selectedStarFilter; // null: All, 5, 4, 3, 2, 1
  bool _onlyWithComments = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchRatingsAndReviews();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchRatingsAndReviews() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final apiUrl = ApiConstant.getContentRatingAndReviews(widget.contentId);
    try {
      final apiHelper = ApiHelper();
      final response = await apiHelper.getApi(apiUrl);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        final data = body['data'];
        if (data != null && data['reviewRating'] != null) {
          setState(() {
            _isLoading = false;
            _ratingData = ReviewRatingData.fromJson(
                data['reviewRating'] as Map<String, dynamic>);
          });
        } else {
          setState(() {
            _isLoading = false;
            _ratingData = ReviewRatingData(ratingAvg: 0, reviews: []);
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage =
              "Unable to load reviews (Status: ${response.statusCode})";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load ratings and reviews: $e";
      });
    }
  }

  List<ContentReview> get _filteredReviews {
    if (_ratingData == null) return [];
    var list = _ratingData!.reviews;

    // Filter by Star Rating
    if (_selectedStarFilter != null) {
      list = list
          .where((r) => (r.rating ?? 0).round() == _selectedStarFilter)
          .toList();
    }

    // Filter by Comments Only
    if (_onlyWithComments) {
      list = list
          .where((r) => (r.comment ?? '').trim().isNotEmpty)
          .toList();
    }

    // Filter by Search Query
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((r) {
        final name = (r.username ?? '').toLowerCase();
        final comment = (r.comment ?? '').toLowerCase();
        final title = (r.title ?? '').toLowerCase();
        return name.contains(query) ||
            comment.contains(query) ||
            title.contains(query);
      }).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().getTheme;
    final isDesktop = ResponsiveWidget.isDesktop(context);

    return Card(
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.star_rate_rounded,
                    color: Color(0xFFF59E0B),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Ratings & Reviews",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: theme.canvasColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (_ratingData != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star_rounded,
                                      size: 13, color: Color(0xFFF59E0B)),
                                  const SizedBox(width: 3),
                                  Text(
                                    "${(_ratingData!.ratingAvg ?? 0).toStringAsFixed(1)} Avg (${_ratingData!.reviews.length})",
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFF59E0B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Customer ratings, feedback, and user reviews for this content",
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: "Refresh Reviews",
                  onPressed: _fetchRatingsAndReviews,
                  icon: Icon(Icons.refresh_rounded, color: theme.canvasColor),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.scaffoldBackgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: theme.dividerColor.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Divider(color: theme.dividerColor.withValues(alpha: 0.15)),
            const SizedBox(height: 14),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: Colors.redAccent, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: theme.canvasColor.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _fetchRatingsAndReviews,
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              )
            else if (_ratingData == null || _ratingData!.reviews.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 36),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(
                      Icons.rate_review_outlined,
                      size: 46,
                      color: theme.hintColor.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "No ratings or reviews yet",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.canvasColor.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "User reviews will appear here once viewers rate this title.",
                      style: TextStyle(fontSize: 12, color: theme.hintColor),
                    ),
                  ],
                ),
              )
            else ...[
              // Summary & Rating Breakdown
              _buildRatingSummary(theme, isDesktop),
              const SizedBox(height: 16),

              // Filter Chips & Search Bar
              _buildFilterToolbar(theme, isDesktop),
              const SizedBox(height: 16),

              // Reviews List
              _buildReviewsList(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSummary(ThemeData theme, bool isDesktop) {
    final data = _ratingData!;
    final total = data.reviews.length;
    final avg = (data.ratingAvg ?? 0).toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          // Left: Big Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      avg.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFF59E0B),
                      size: 28,
                    ),
                  ],
                ),
                Text(
                  "$total ${total == 1 ? 'Review' : 'Reviews'}",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),

          // Right: Star Distribution Bars
          Expanded(
            child: Column(
              children: [
                _buildRatingBar(theme, 5, data.count5Star, total),
                _buildRatingBar(theme, 4, data.count4Star, total),
                _buildRatingBar(theme, 3, data.count3Star, total),
                _buildRatingBar(theme, 2, data.count2Star, total),
                _buildRatingBar(theme, 1, data.count1Star, total),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(
      ThemeData theme, int stars, int count, int totalCount) {
    final pct = totalCount > 0 ? (count / totalCount) : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "$stars",
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: theme.canvasColor,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.star_rounded,
                    size: 13, color: Color(0xFFF59E0B)),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 7,
                backgroundColor: theme.cardColor,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFF59E0B),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 30,
            child: Text(
              "$count",
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 11,
                color: theme.hintColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterToolbar(ThemeData theme, bool isDesktop) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Star Filters
        _buildChip(
          theme: theme,
          label: "All (${_ratingData?.reviews.length ?? 0})",
          isSelected: _selectedStarFilter == null && !_onlyWithComments,
          onSelected: () => setState(() {
            _selectedStarFilter = null;
            _onlyWithComments = false;
          }),
        ),
        _buildChip(
          theme: theme,
          label: "5 ★ (${_ratingData?.count5Star ?? 0})",
          isSelected: _selectedStarFilter == 5,
          onSelected: () => setState(() => _selectedStarFilter =
              _selectedStarFilter == 5 ? null : 5),
        ),
        _buildChip(
          theme: theme,
          label: "4 ★ (${_ratingData?.count4Star ?? 0})",
          isSelected: _selectedStarFilter == 4,
          onSelected: () => setState(() => _selectedStarFilter =
              _selectedStarFilter == 4 ? null : 4),
        ),
        _buildChip(
          theme: theme,
          label: "3 ★ (${_ratingData?.count3Star ?? 0})",
          isSelected: _selectedStarFilter == 3,
          onSelected: () => setState(() => _selectedStarFilter =
              _selectedStarFilter == 3 ? null : 3),
        ),
        _buildChip(
          theme: theme,
          label: "1-2 ★ (${(_ratingData?.count2Star ?? 0) + (_ratingData?.count1Star ?? 0)})",
          isSelected: _selectedStarFilter == 1 || _selectedStarFilter == 2,
          onSelected: () => setState(() => _selectedStarFilter =
              _selectedStarFilter == 1 ? null : 1),
        ),
        _buildChip(
          theme: theme,
          label: "With Written Review",
          icon: Icons.chat_bubble_outline_rounded,
          isSelected: _onlyWithComments,
          onSelected: () =>
              setState(() => _onlyWithComments = !_onlyWithComments),
        ),

        // Search in Reviews
        SizedBox(
          width: isDesktop ? 220 : double.infinity,
          height: 34,
          child: TextField(
            controller: _searchController,
            style: TextStyle(fontSize: 12.5, color: theme.canvasColor),
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              filled: true,
              fillColor: theme.scaffoldBackgroundColor,
              hintText: "Search reviews...",
              hintStyle: TextStyle(fontSize: 11.5, color: theme.hintColor),
              prefixIcon: Icon(Icons.search, size: 15, color: theme.hintColor),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 13),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.2)),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }

  Widget _buildChip({
    required ThemeData theme,
    required String label,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFF59E0B).withValues(alpha: 0.15)
              : theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFF59E0B)
                : theme.dividerColor.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 13,
                  color: isSelected
                      ? const Color(0xFFF59E0B)
                      : theme.hintColor),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFFF59E0B)
                    : theme.canvasColor.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsList(ThemeData theme) {
    final list = _filteredReviews;

    if (list.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        alignment: Alignment.center,
        child: Text(
          "No reviews match the selected filter",
          style: TextStyle(fontSize: 13, color: theme.hintColor),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final review = list[index];
        return _buildReviewCard(review, theme);
      },
    );
  }

  Widget _buildReviewCard(ContentReview review, ThemeData theme) {
    final rating = (review.rating ?? 0).round();
    final hasComment = (review.comment ?? '').trim().isNotEmpty;
    final hasTitle = (review.title ?? '').trim().isNotEmpty &&
        review.title?.trim() != review.comment?.trim();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User & Rating Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                backgroundImage: review.userProfile != null &&
                        review.userProfile!.isNotEmpty
                    ? NetworkImage(review.userProfile!)
                    : null,
                child: review.userProfile == null ||
                        review.userProfile!.isEmpty
                    ? Text(
                        (review.username ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF59E0B),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.username ?? 'Anonymous Viewer',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    if (review.formattedDate.isNotEmpty)
                      Text(
                        review.formattedDate,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.hintColor,
                        ),
                      ),
                  ],
                ),
              ),
              // Stars
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (i) {
                  return Icon(
                    i < rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: const Color(0xFFF59E0B),
                    size: 17,
                  );
                }),
              ),
            ],
          ),

          if (hasTitle) ...[
            const SizedBox(height: 10),
            Text(
              review.title!.trim(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],

          if (hasComment) ...[
            const SizedBox(height: 6),
            Text(
              review.comment!.trim(),
              style: TextStyle(
                fontSize: 12.5,
                height: 1.4,
                color: theme.canvasColor.withValues(alpha: 0.9),
              ),
            ),
          ] else ...[
            const SizedBox(height: 6),
            Text(
              "Rated $rating out of 5 stars (no written comment)",
              style: TextStyle(
                fontSize: 11.5,
                fontStyle: FontStyle.italic,
                color: theme.hintColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
