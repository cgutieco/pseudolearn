import 'package:flutter/material.dart';
import 'package:pseudolearn_app/composition/app_dependencies.dart';
import 'package:pseudolearn_app/composition/cubit_scope.dart';

final class AppStage extends StatelessWidget {
  final Size logicalSize;
  final AppDependencies dependencies;

  const AppStage({
    super.key,
    required this.logicalSize,
    required this.dependencies,
  });

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        size: logicalSize,
        padding: EdgeInsets.zero,
        viewPadding: EdgeInsets.zero,
        viewInsets: EdgeInsets.zero,
        textScaler: TextScaler.noScaling,
      ),
      child: SizedBox.fromSize(
        size: logicalSize,
        child: CubitScope(dependencies: dependencies),
      ),
    );
  }
}
