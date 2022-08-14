import 'package:flutter/material.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/widgets/ShimmerWidget.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class BuildShimmerListView extends StatelessWidget {
  const BuildShimmerListView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    return Shimmer.fromColors(
      baseColor: themeProvider.isDarkMode ? Colors.black26 : Colors.grey[400],
      highlightColor:
          themeProvider.isDarkMode ? Colors.white10 : Colors.grey[100],
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: 10,
        itemBuilder: (context, index) {
          return ListTile(
            title: Align(
              alignment: Alignment.centerLeft,
              child: ShimmerWidget.rectangular(width: 270, height: 10),
            ),
            subtitle: Align(
              alignment: Alignment.centerLeft,
              child: ShimmerWidget.rectangular(width: 150, height: 10),
            ),
            leading: ShimmerWidget.circular(width: 50, height: 50),
          );
        },
      ),
    );
  }
}
