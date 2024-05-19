import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class DashboardTileWidget extends StatelessWidget {
  const DashboardTileWidget(
      {super.key, this.height = 1, this.width = 1, required this.child});

  final int height;
  final int width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return StaggeredGridTile.count(
      crossAxisCellCount: width,
      mainAxisCellCount: height,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
              color: Theme.of(context).colorScheme.primary, width: 2),
        ),
        child: child,
      ),
    );
  }
}
