import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:easy_localization/easy_localization.dart';

enum SlidableAction { more, unfriend }

class SlidableWidget<T> extends StatelessWidget {
  final Widget child;
  final Function(SlidableAction action) onDismissed;

  const SlidableWidget({
    @required this.child,
    @required this.onDismissed,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Slidable(
        actionPane: SlidableDrawerActionPane(),
        child: child,

        actions: <Widget>[
          IconSlideAction(
            caption: "MORE".tr(),
            color: Colors.grey[350],
            icon: Icons.more_horiz,
            onTap: () => onDismissed(SlidableAction.more),
          ),
          IconSlideAction(
            caption: "UNFRIEND".tr(),
            color: mRed,
            icon: Icons.cancel,
            onTap: () => onDismissed(SlidableAction.unfriend),
          ),
        ],
      );
}
