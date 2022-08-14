class AllStoriesModel {
  List<SingleStory> singleStory;
  String status;
  int itemCount;

  AllStoriesModel({this.singleStory, this.status, this.itemCount});

  AllStoriesModel.fromJson(Map<String, dynamic> json) {
    if (json['singleStory'] != null) {
      singleStory = [];
      json['singleStory'].forEach((v) {
        singleStory.add(new SingleStory.fromJson(v));
      });
    }
    status = json['status'];
    itemCount = json['itemCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.singleStory != null) {
      data['singleStory'] = this.singleStory.map((v) => v.toJson()).toList();
    }
    data['status'] = this.status;
    data['itemCount'] = this.itemCount;
    return data;
  }
}

class SingleStory {
  String storyid;
  String type;
  String url;
  String thumbnailUrl;
  String uploadedOn;
  String uid;

  SingleStory(
      {this.storyid,
        this.type,
        this.url,
        this.thumbnailUrl,
        this.uploadedOn,
        this.uid});

  SingleStory.fromJson(Map<String, dynamic> json) {
    storyid = json['storyid'];
    type = json['type'];
    url = json['url'];
    thumbnailUrl = json['thumbnail_url'];
    uploadedOn = json['uploaded_on'];
    uid = json['uid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['storyid'] = this.storyid;
    data['type'] = this.type;
    data['url'] = this.url;
    data['thumbnail_url'] = this.thumbnailUrl;
    data['uploaded_on'] = this.uploadedOn;
    data['uid'] = this.uid;
    return data;
  }
}
