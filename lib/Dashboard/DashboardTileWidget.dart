import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class DashboardTileWidget extends StatelessWidget {
  const DashboardTileWidget(
      {super.key,
      this.height = 1,
      this.width = 1,
      required this.child,
      this.color});

  final int height;
  final int width;
  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return StaggeredGridTile.count(
      crossAxisCellCount: width,
      mainAxisCellCount: height,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(40),
          border: color == null
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary, width: 2)
              : null,
        ),
        child: child,
      ),
    );
  }
}
