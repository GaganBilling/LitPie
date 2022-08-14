// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:practiceflutter/BottomNavigation/Chat/Calling/call.dart';
// import 'package:practiceflutter/Theme/colors.dart';
// import 'package:practiceflutter/models/createAccountData.dart';
//
// class DialCall extends StatefulWidget {
//   final String channelName;
//   final CreateAccountData receiver;
//   final String callType;
//   const DialCall({@required this.channelName, this.receiver, this.callType});
//
//   @override
//   _DialCallState createState() => _DialCallState();
// }
//
// class _DialCallState extends State<DialCall> {
//   bool ispickup = false;
//   //final db = Firestore.instance;
//   CollectionReference callRef = FirebaseFirestore.instance.collection("calls");
//   @override
//   void initState() {
//     _addCallingData();
//     super.initState();
//   }
//
//   _addCallingData() async {
//     await callRef.doc(widget.channelName).delete();
//     await callRef.doc(widget.channelName).set({
//       'callType': widget.callType,
//       'calling': true,
//       'response': "Awaiting",
//       'channel_id': widget.channelName,
//       'last_call': FieldValue.serverTimestamp()
//     });
//   }
//
//   @override
//   void dispose() async {
//     super.dispose();
//     ispickup = true;
//     await callRef
//         .doc(widget.channelName)
//         .set({'calling': false}, SetOptions(merge: true));
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//           child: StreamBuilder<QuerySnapshot>(
//               stream: callRef
//                   .where("channel_id", isEqualTo: "${widget.channelName}")
//                   .snapshots(),
//               builder: (BuildContext context,
//                   AsyncSnapshot<QuerySnapshot> snapshot) {
//                 Future.delayed(Duration(seconds: 30), () async {
//                   if (!ispickup) {
//                     await callRef
//                         .doc(widget.channelName)
//                         .update({'response': 'Not-answer'});
//                   }
//                 });
//                 if (!snapshot.hasData) {
//                   return Container();
//                 } else
//                   try {
//                     switch (snapshot.data.docs[0]['response']) {
//                       case "Awaiting":
//                         {
//                           return Column(
//                             mainAxisAlignment: MainAxisAlignment.spaceAround,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: <Widget>[
//                               CircleAvatar(
//                                 backgroundColor: Colors.grey,
//                                 radius: 60,
//                                 child: Center(
//                                   child: ClipRRect(
//                                     borderRadius: BorderRadius.circular(
//                                       60,
//                                     ),
//                                     child: CachedNetworkImage(
//                                       imageUrl:
//                                       widget.receiver.profilepic ?? '',
//                                       useOldImageOnUrlChange: true,
//                                       placeholder: (context, url) =>
//                                           CupertinoActivityIndicator(
//                                             radius: 15,
//                                           ),
//                                       errorWidget: (context, url, error) =>
//                                           Column(
//                                             mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                             children: <Widget>[
//                                               Icon(
//                                                 Icons.error,
//                                                 color: Colors.black,
//                                                 size: 30,
//                                               ),
//                                               Text(
//                                                 "Enable to load",
//                                                 style: TextStyle(
//                                                   color: Colors.black,
//                                                 ),
//                                               )
//                                             ],
//                                           ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               Text("Calling to ${widget.receiver.name}...",
//                                   style: TextStyle(
//                                       fontSize: 25,
//                                       fontWeight: FontWeight.bold)),
//                               ElevatedButton.icon (
//                                 icon: Icon(Icons.call_end,color: white,),
//                                 label: Text("End",
//                                     style: TextStyle(color:Colors.white)),
//                                 onPressed: () async{
//                                   await callRef
//                                       .doc(widget.channelName)
//                                       .set({'response': "Call_Cancelled"},
//                                       SetOptions(merge: true));
//                                   // Navigator.pop(context);
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                     primary: mRed,
//                                     onPrimary:  white,
//                                     elevation: 5,
//                                     shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(20.7)
//                                     )
//                                 ),
//                               ),
//
//                             ],
//                           );
//                         }
//                         break;
//                       case "Pickup":
//                         {
//                           ispickup = true;
//                           return CallPage(
//                               channelName: widget.channelName,
//                               role: ClientRole.Broadcaster,
//                               callType: widget.callType);
//                         }
//                         break;
//                       case "Decline":
//                         {
//                           return Column(
//                             mainAxisAlignment: MainAxisAlignment.spaceAround,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: <Widget>[
//                               Text("${widget.receiver.name} is Busy",
//                                   style: TextStyle(
//                                       fontSize: 25,
//                                       fontWeight: FontWeight.bold)),
//
//                               ElevatedButton.icon (
//                                 icon: Icon(Icons.arrow_back,color: white,),
//                                 label: Text("Back",
//                                     style: TextStyle(color:Colors.white)),
//                                 onPressed: () async{
//                                   Navigator.pop(context);
//
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                     primary: mRed,
//                                     onPrimary:  white,
//                                     elevation: 5,
//                                     shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(20.7)
//                                     )
//                                 ),
//                               ),
//
//                             ],
//                           );
//                         }
//                         break;
//                       case "Not-answer":
//                         {
//                           return Column(
//                             mainAxisAlignment: MainAxisAlignment.spaceAround,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: <Widget>[
//                               Text("${widget.receiver.name} is Not-answering",
//                                   style: TextStyle(
//                                       fontSize: 25,
//                                       fontWeight: FontWeight.bold)),
//
//                               ElevatedButton.icon (
//                                 icon: Icon(Icons.arrow_back,color: white,),
//                                 label: Text("Back",
//                                     style: TextStyle(color:Colors.white)),
//                                 onPressed: () async{
//                                   Navigator.pop(context);
//                                   // _ageController.text=year1.toString();
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                     primary: mRed,
//                                     onPrimary:  white,
//                                     elevation: 5,
//                                     shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(20.7)
//                                     )
//                                 ),
//                               ),
//
//                             ],
//                           );
//                         }
//                         break;
//                     //call end
//                       default:
//                         {
//                           Future.delayed(Duration(milliseconds: 500), () {
//                             Navigator.pop(context);
//                           });
//                           return Container(
//                             child: Text("Call Ended..."),
//                           );
//                         }
//                         break;
//                     }
//                   }
//                   //  else if (!snapshot.data.documents[0]['calling']) {
//                   //   Navigator.pop(context);
//                   // }
//                   catch (e) {
//                     return Container();
//                   }
//               })),
//     );
//   }
// }
//
//
