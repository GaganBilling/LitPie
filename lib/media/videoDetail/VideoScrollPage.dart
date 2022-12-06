import 'package:flutter/material.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:easy_localization/easy_localization.dart';

class VideoScrollPage extends StatelessWidget {
  final Widget video;
  final double aspectRatio;
  final String tag;
  final double bottomPadding;

  final Widget rightButtonColumn;
  final Widget userInfoWidget;

  final bool hidePauseIcon;

  final VideoPlayerController player;

  ValueNotifier<bool> isVideoPlaying;

  VideoScrollPage({
    Key key,
    this.bottomPadding: 16,
    this.tag,
    this.rightButtonColumn,
    this.userInfoWidget,
    this.video,
    this.aspectRatio: 9 / 16.0,
    this.hidePauseIcon: false,
    @required this.player,
  }) : super(key: key) {
    isVideoPlaying = ValueNotifier(player.value.isPlaying);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    Widget videoContainer = Stack(
      children: <Widget>[
        Container(
          height: double.infinity,
          width: double.infinity,
          color: Colors.black,
          alignment: Alignment.center,
          child: Container(

            child: AspectRatio(
              key: key,
              aspectRatio: aspectRatio,
              child: video,
            ),
          ),
        ),
        // ValueListenableBuilder<bool>(
        //     valueListenable: isVideoPlaying,
        //     builder: (context, condition, child) {
        //       if (!condition) {
        //         return Container(
        //           height: double.infinity,
        //           width: double.infinity,
        //           alignment: Alignment.center,
        //           child: Icon(
        //             Icons.play_circle_outline,
        //             size: 80,
        //             color: Colors.white.withOpacity(0.4),
        //           ),
        //         );
        //       } else {
        //         return Container();
        //       }
        //     }),
      ],
    );
    Widget videoGesture = GestureDetector(
      onTap: () async {
        if (player.value.isPlaying) {
          await player.pause();
          isVideoPlaying = ValueNotifier(false);
        } else {
          await player.play();
          isVideoPlaying = ValueNotifier(true);
        }
      },
      child: videoContainer,
    );

    Widget body = Container(
      child: Stack(
        children: <Widget>[
          videoGesture,
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(bottom: 20.0),
              child: buildIndicator(player),
            ),
          ),
        ],
      ),
    );
    return body;
  }
}

class VideoLoadingPlaceHolder extends StatelessWidget {
  const VideoLoadingPlaceHolder({
    Key key,
    @required this.tag,
  }) : super(key: key);

  final String tag;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          colors: <Color>[
            // themeProvider.isDarkMode ? Colors.black : Colors.white,
            //themeProvider.isDarkMode ? Colors.black : Colors.white,
            Colors.black,
            Colors.black,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // SpinKitWave(
          //   size: 36,
          //   color: Colors.white.withOpacity(0.3),
          // ),

          Text(
            "Loading...".tr(),
            style: TextStyle(color: Colors.white),
          ),
          Container(
            padding: EdgeInsets.all(50),
            child: Text(
              tag,
              // style: StandardTextStyle.normalWithOpacity,
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildIndicator(VideoPlayerController controller) => Container(
      margin: EdgeInsets.all(8),
      height: 7,
      child: VideoProgressIndicator(
        controller,
        allowScrubbing: true,
      ),
    );
