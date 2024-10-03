import 'package:data_dashboard/Device/Device.dart';
import 'package:data_dashboard/Device/DeviceConnectionWidgets/DeviceCardWidget.dart';
import 'package:flutter/material.dart';

class PageWidget extends StatelessWidget {
  const PageWidget({super.key, required this.child, this.onRefresh});

  final Widget child;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        // backgroundColor: AppColors.primarywhite,
        body: RefreshIndicator(
          displacement: 30,
          edgeOffset: MediaQuery.of(context).viewPadding.top,
          // color: AppColors.normalGreen,
          // backgroundColor: AppColors.offwhite,
          onRefresh: () async {
            if (onRefresh != null) {
              await onRefresh!();
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).viewPadding.top,
                bottom: 80 + MediaQuery.of(context).viewInsets.bottom),
            child: child,
          ),
        ),
      ),
    );
  }
}
