// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:litpie/Theme/colors.dart';
// import 'package:litpie/Theme/theme_provider.dart';
//
// class SwipeAdWidget extends StatefulWidget {
//   final BannerAd bannerAd;
//   final ThemeProvider themeProvider;
//
//   const SwipeAdWidget({Key key, @required this.bannerAd, @required this.themeProvider}) : super(key: key);
//   @override
//   _SwipeAdWidgetState createState() => _SwipeAdWidgetState();
// }
//
// class _SwipeAdWidgetState extends State<SwipeAdWidget> with AutomaticKeepAliveClientMixin {
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       key: UniqueKey(),
//       body: Center(
//         child: Container(
//           height: MediaQuery.of(
//               context)
//               .size
//               .height *
//               .65,
//           // color:Colors.red,
//           alignment: Alignment.center,
//           child: Stack(
//             children: [
//               Align(
//                 alignment: Alignment.center,
//                 child: Card(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20.0),
//                   ),
//                   child: Container(
//                     height: MediaQuery.of(
//                         context)
//                         .size
//                         .height *
//                         .65,
//                     width: MediaQuery
//                         .of(context)
//                         .size
//                         .width,
//                     child: Container(
//                       // height: 70,
//                       decoration:
//                       BoxDecoration(
//                         boxShadow: [
//                           BoxShadow(
//                               color: Colors
//                                   .blueGrey,
//                               offset: Offset(
//                                   2,
//                                   2),
//                               spreadRadius:
//                               1,
//                               blurRadius:
//                               3),
//                         ],
//                         borderRadius:
//                         BorderRadius.all(
//                             Radius.circular(
//                                 20)),
//                         color: widget.themeProvider
//                             .isDarkMode
//                             ? dRed
//                             : white,
//                       ),
//
//                       child: StatefulBuilder(
//                         builder: (context,s){
//                           return Transform.scale(
//                           scale: 1.1,
//                           child: Container(
//                             child: AdWidget(
//                             ad: widget.bannerAd..load(),),
//                           ),
//                           );
//                         },
//                       ),
//                       // child: Transform.scale(
//                       //   scale: 1.1,
//                       //   child: AdWidget(
//                       //     ad: widget.bannerAd..load(),),
//                       // ),
//                     ),
//                   ),
//                 ),
//               ),
//               Align(
//                 alignment: Alignment.topCenter,
//                 child: Container(
//                   padding: EdgeInsets.only(top: 20.0),
//                     child: Text("ADVERTISEMENT", textAlign: TextAlign.center, style: TextStyle(
//                   fontSize: 20.0,
//                 ),)),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   // TODO: implement wantKeepAlive
//   bool get wantKeepAlive => true;
// }
