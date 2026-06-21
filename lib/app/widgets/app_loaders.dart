import 'package:admin_ott/app/core/loading/app_loading_controller.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AppLoaderOverlay extends StatelessWidget {
  const AppLoaderOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppLoadingController.isLoading,
      builder: (context, isLoading, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            child,
            IgnorePointer(
              ignoring: !isLoading,
              child: AnimatedOpacity(
                opacity: isLoading ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                child: const AppFullScreenLoader(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class AppFullScreenLoader extends StatelessWidget {
  const AppFullScreenLoader({super.key, this.label = 'Loading'});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scrim = theme.brightness == Brightness.dark
        ? Colors.black.withValues(alpha: 0.58)
        : Colors.black.withValues(alpha: 0.24);

    return ColoredBox(
      color: scrim,
      child: Center(
        child: Semantics(
          label: label,
          liveRegion: true,
          child: Container(
            constraints: const BoxConstraints(minWidth: 124),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.canvasColor.withValues(alpha: 0.1),
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                  color: Colors.black.withValues(alpha: 0.18),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppSpinner(size: 32),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.canvasColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppSpinner extends StatelessWidget {
  const AppSpinner({
    super.key,
    this.size = 24,
    this.strokeWidth = 2.6,
    this.color,
  });

  final double size;
  final double strokeWidth;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox.square(
      dimension: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class AppButtonLoader extends StatelessWidget {
  const AppButtonLoader({super.key, required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.onPrimary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppSpinner(size: 18, strokeWidth: 2, color: effectiveColor),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class AppPaginationLoader extends StatelessWidget {
  const AppPaginationLoader({super.key, this.label = 'Loading more'});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppSpinner(size: 18, strokeWidth: 2),
            const SizedBox(width: 10),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.canvasColor.withValues(alpha: 0.72),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppSkeleton extends StatelessWidget {
  const AppSkeleton({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  final Widget child;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: dark ? Colors.white10 : Colors.black12,
      highlightColor: dark ? Colors.white24 : Colors.white70,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: ColoredBox(color: theme.cardColor, child: child),
      ),
    );
  }
}

class AppCardSkeletonList extends StatelessWidget {
  const AppCardSkeletonList({
    super.key,
    this.itemCount = 6,
    this.gridDelegate,
    this.padding = const EdgeInsets.all(12),
  });

  final int itemCount;
  final SliverGridDelegate? gridDelegate;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    if (gridDelegate != null) {
      return GridView.builder(
        padding: padding,
        itemCount: itemCount,
        gridDelegate: gridDelegate!,
        itemBuilder: (_, __) => const _CardSkeleton(),
      );
    }

    return ListView.separated(
      padding: padding,
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const SizedBox(
        height: 96,
        child: _CardSkeleton(),
      ),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const AppSkeleton(child: SizedBox.expand());
  }
}
