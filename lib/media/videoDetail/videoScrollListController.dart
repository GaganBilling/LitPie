import 'dart:async';

import 'package:flutter/material.dart';
import 'package:litpie/media/videoDetail/videoScrollPageView.dart';
import 'package:litpie/models/userVideosModel.dart';
import 'package:video_player/video_player.dart';

typedef LoadMoreVideo = Future<List<VPVideoController>> Function(
  int index,
  List<VPVideoController> list,
);

class VideoScrollListController extends ChangeNotifier {
  VideoScrollListController({
    this.loadMoreCount = 1,
    this.preloadCount = 2,
    this.disposeCount = 3,
    @required this.initVideoIndex,
  });

  final int loadMoreCount;

  final int preloadCount;

  final int disposeCount;

  final int initVideoIndex;

  LoadMoreVideo _videoProvider;

  loadIndex(int target, {bool reload = false}) {
    if (!reload) {
      if (index.value == target) return;
    }
    var oldIndex = playerList.length == index.value ? target : index.value;
    var newIndex = target;

    if (!(oldIndex == 0 && newIndex == 0)) {
      if (playerOfIndex(oldIndex).controller.value.isInitialized) {
        playerOfIndex(oldIndex).controller.seekTo(Duration.zero);
        playerOfIndex(oldIndex)?.pause();
        print('OLD-INDEX: $oldIndex');
      }
    }
    playerOfIndex(newIndex).controller.addListener(_didUpdateValue);
    playerOfIndex(newIndex).showPauseIcon.addListener(_didUpdateValue);
    playerOfIndex(newIndex).play();
    print('NEW-INDEX $newIndex');
    for (var i = 0; i < playerList.length; i++) {
      if (i < newIndex - disposeCount || i > newIndex + disposeCount) {
        print('INDEX: $i');
        playerOfIndex(i).controller.removeListener(_didUpdateValue);
        playerOfIndex(i).showPauseIcon.removeListener(_didUpdateValue);
        playerOfIndex(i).dispose();
      } else {
        if (i > newIndex && i < newIndex + preloadCount) {
          // print('预加载$i');
          playerOfIndex(i)?.init();
        }
      }
    }
    // if (playerList.length - newIndex <= loadMoreCount + 1) {
    //   _videoProvider.call(newIndex, playerList).then(
    //         (list) async {
    //       playerList.addAll(list);
    //       notifyListeners();
    //     },
    //   );
    // }
    index.value = target;
  }

  _didUpdateValue() {
  //  notifyListeners();
  }

  VPVideoController playerOfIndex(int index, {bool isDelete,int currentIndex}) {
    if(isDelete!=null && isDelete){
      playerList.removeAt(currentIndex);
    }
    if (index < 0 || index > playerList.length - 1) {
      return null;
    }
    return playerList[index];
  }

  int get videoCount => playerList.length;

  init({
    @required VideoScrollPageController pageController,
    @required List<VPVideoController> initialList,
    @required LoadMoreVideo videoProvider,
  }) async {
    playerList.addAll(initialList);
    _videoProvider = videoProvider;
    pageController.addListener(() {
      var p = pageController.page;
      if (p % 1 == 0) {
        loadIndex(p ~/ 1);
      }
    });
    try {
      loadIndex(initVideoIndex, reload: true);
    } catch (e) {
      print("ERROR (LOAD INDEX CALL): $e");
    }
  //  notifyListeners();
  }

  ValueNotifier<int> index = ValueNotifier<int>(0);

  List<VPVideoController> playerList = [];

  VPVideoController get currentPlayer => playerList[
      index.value >= playerList.length ? playerList.length - 1 : index.value];

  void dispose() {
    for (var player in playerList) {
      player.showPauseIcon.dispose();
      player.dispose();
    }
    playerList = [];
    super.dispose();
  }
}

typedef ControllerSetter<T> = Future<void> Function(T controller);
typedef ControllerBuilder<T> = T Function();

abstract class VideoScrollVideoController<T> {
  T get controller;

  ValueNotifier<bool> get showPauseIcon;

  Future<void> init({ControllerSetter<T> afterInit});

  Future<void> dispose();

  Future<void> play();

  Future<void> pause({bool showPauseIcon: false});
}

class VPVideoController
    extends VideoScrollVideoController<VideoPlayerController> {
  VideoPlayerController _controller;
  ValueNotifier<bool> _showPauseIcon = ValueNotifier<bool>(false);

/*
  final Videos videoInfo;
*/
  final Videos videoInfo;

  final ControllerBuilder<VideoPlayerController> _builder;
  final ControllerSetter<VideoPlayerController> _afterInit;
  VPVideoController({
    this.videoInfo,
    @required ControllerBuilder<VideoPlayerController> builder,
    ControllerSetter<VideoPlayerController> afterInit,
  })  : this._builder = builder,
        this._afterInit = afterInit;

  @override
  VideoPlayerController get controller {
    if (_controller == null) {
      _controller = _builder.call();
    }
    return _controller;
  }

  List<Future> _actLocks = [];
  bool get prepared => _prepared;
  bool _prepared = false;

  Completer<void> _disposeLock;

  @override
  Future<void> dispose() async {
    if (!prepared) return;
    await Future.wait(_actLocks);
    _actLocks.clear();
    var completer = Completer<void>();
    _actLocks.add(completer.future);
    _prepared = false;
    await this.controller.dispose();
    _controller = null;
    _disposeLock = Completer<void>();
    completer.complete();
  }

  @override
  Future<void> init({
    ControllerSetter<VideoPlayerController> afterInit,
  }) async {
    if (prepared) return;
    await Future.wait(_actLocks);
    _actLocks.clear();
    var completer = Completer<void>();
    _actLocks.add(completer.future);
    await this.controller.initialize();
    await this.controller.setLooping(true);
    afterInit ??= this._afterInit;
    await afterInit?.call(this.controller);
    _prepared = true;
    completer.complete();
    if (_disposeLock != null) {
      _disposeLock?.complete();
      _disposeLock = null;
    }
  }

  @override
  Future<void> pause({bool showPauseIcon: false}) async {
    await Future.wait(_actLocks);
    _actLocks.clear();
    await init();
    if (!prepared) return;
    if (_disposeLock != null) {
      await _disposeLock?.future;
    }
    await this.controller.pause();
    _showPauseIcon.value = true;
  }

  @override
  Future<void> play() async {
    await Future.wait(_actLocks);
    _actLocks.clear();
    await init();
    if (!prepared) return;
    if (_disposeLock != null) {
      await _disposeLock?.future;
    }
    await this.controller.play();
    _showPauseIcon.value = false;
  }

  @override
  ValueNotifier<bool> get showPauseIcon => _showPauseIcon;
}
