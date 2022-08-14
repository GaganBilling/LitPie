enum AppAssets { LITPIELOGO }

final String imageDir = "assets/images";

extension AssetsName on AppAssets {
  String get name {
    switch (this) {
      case AppAssets.LITPIELOGO:
        return "$imageDir/practicelogo.png";
    }
  }
}
