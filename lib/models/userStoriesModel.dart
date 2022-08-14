class UserStoriesModel {
  List<Stories> stories;
  String uid;
  String status;
  int itemCount;

  UserStoriesModel({this.stories, this.uid, this.status, this.itemCount});

  UserStoriesModel.fromJson(Map<String, dynamic> json) {
    if (json['stories'] != null) {
      stories = [];
      json['stories'].forEach((v) {
        stories.add(new Stories.fromJson(v));
      });
    }
    uid = json['uid'];
    status = json['status'];
    itemCount = json['itemCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.stories != null) {
      data['stories'] = this.stories.map((v) => v.toJson()).toList();
    }
    data['uid'] = this.uid;
    data['status'] = this.status;
    data['itemCount'] = this.itemCount;
    return data;
  }
}

class Stories {
  String storyid;
  String type;
  String url;
  String thumbnailUrl;
  String uploadedOn;

  Stories(
      {this.storyid, this.type, this.url, this.thumbnailUrl, this.uploadedOn});

  Stories.fromJson(Map<String, dynamic> json) {
    storyid = json['storyid'];
    type = json['type'];
    url = json['url'];
    thumbnailUrl = json['thumbnail_url'];
    uploadedOn = json['uploaded_on'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['storyid'] = this.storyid;
    data['type'] = this.type;
    data['url'] = this.url;
    data['thumbnail_url'] = this.thumbnailUrl;
    data['uploaded_on'] = this.uploadedOn;
    return data;
  }
}
