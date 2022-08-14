import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:litpie/adminScreens/adminContactUs.dart';
import 'package:litpie/adminScreens/adminReports.dart';
import 'package:litpie/controller/FirebaseController.dart';
import 'package:provider/provider.dart';
import '../Theme/colors.dart';
import '../Theme/theme_provider.dart';

class AdminDrawerSideMenu extends StatefulWidget {
  @override
  _AdminDrawerSideMenuState createState() => _AdminDrawerSideMenuState();
}

class _AdminDrawerSideMenuState extends State<AdminDrawerSideMenu> {
  int snapshotCC;
  int snapshotRC;
  int cc = 0;
  int rc = 0;

  CollectionReference CCRef =
      FirebaseFirestore.instance.collection('ContactUs');
  CollectionReference RCRef = FirebaseFirestore.instance.collection('Reports');

  Future<int> getContactCountData() async {
    snapshotCC = await FirebaseFirestore.instance
        .collection("ContactUs")
        .doc('count')
        .get()
        .then((value) {
      var field = value.data();
      setState(() {
        cc = field['new'];
      });
      print("count data: ${value.data()['new']}");
      return value.data()['new'];
    });
  }

  Future<int> getReportCountData() async {
    snapshotRC = await FirebaseFirestore.instance
        .collection("Reports")
        .doc('count')
        .get()
        .then((value) {
      var field = value.data();
      setState(() {
        rc = field['new'];
      });
      print("count data: ${value.data()['new']}");
      return value.data()['new'];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getContactCountData();
    getReportCountData();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Drawer(
        elevation: 10,
        backgroundColor: Colors.blueGrey,
        child: Material(
          color: Colors.blueGrey,
          child: ListView(
            children: <Widget>[
              const SizedBox(
                height: 18,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.clear,
                      color: mRed,
                      size: 40,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              buildMenuItem(
                text: "Contact Us",
                countText: cc.toString(),
                onClicked: () => selectedItem(context, 0),
              ),
              Divider(color: mRed),
              const SizedBox(
                height: 18,
              ),
              buildMenuItem(
                text: "Reports",
                countText: rc.toString(),
                onClicked: () => selectedItem(context, 1),
              ),
              Divider(color: mRed),
            ],
          ),
        ));
  }

  Widget buildMenuItem({
    @required String text,
    String countText,
    VoidCallback onClicked,
  }) {
    const color = Colors.white;
    const hoverColor = mRed;
    return ListTile(
      title: Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: Row(
          children: [
            Text(
              text,
              style: const TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
            Text(
              countText,
              style: const TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
      ),
      hoverColor: hoverColor,
      onTap: onClicked,
    );
  }

  void selectedItem(BuildContext context, int index) {
    Navigator.of(context).pop();
    switch (index) {
      case 0:
        Navigator.of(context)
            .push(MaterialPageRoute(
          builder: (context) => AdminContactUs(),
        ))
            .whenComplete(() {
          CCRef.doc('count').update({'isRead': true, 'new': 0});
        });
        break;
      case 1:
        Navigator.of(context)
            .push(MaterialPageRoute(
          builder: (context) => AdminReports(),
        ))
            .whenComplete(() {
          RCRef.doc('count').update({'isRead': true, 'new': 0});
        });
        break;
    }
  }
}
