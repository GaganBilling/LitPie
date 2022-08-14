class UserVideosModel {
  List<Videos> videos=[];
  int itemCount;
  String uid;
  String status;

  UserVideosModel({this.videos, this.itemCount, this.uid, this.status});

  UserVideosModel.fromJson(Map<String, dynamic> json) {
    if (json['videos'] != null) {
      videos = [];
      json['videos'].forEach((v) {
        videos.add(new Videos.fromJson(v));
      });
    }
    itemCount = json['itemCount'];
    uid = json['uid'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.videos != null) {
      data['videos'] = this.videos.map((v) => v.toJson()).toList();
    }
    data['itemCount'] = this.itemCount;
    data['uid'] = this.uid;
    data['status'] = this.status;
    return data;
  }
}

class Videos {
  String videoid;
  String videoUrl;
  String thumbnailUrl;
  String createdAt;
  String createdBy;

  Videos({this.videoid, this.videoUrl, this.thumbnailUrl, this.createdAt,this.createdBy});

  Videos.fromJson(Map<String, dynamic> json) {
    videoid = json['id'];
    videoUrl = json['video'];
    thumbnailUrl = json['thumbnail'];
    createdAt = json['createdAt'];
    createdBy = json['createdBy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.videoid;
    data['video'] = this.videoUrl;
    data['thumbnail'] = this.thumbnailUrl;
    data['createdAt'] = this.createdAt;
    data['createdBy'] = this.createdBy;
    return data;
  }
}
