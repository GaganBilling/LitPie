class UserImagesModel {
  List<Images> images;
  int itemCount;
  String uid;
  String status;

  UserImagesModel({this.images, this.itemCount, this.uid, this.status});

  UserImagesModel.fromJson(Map<String, dynamic> json) {
    if (json['images'] != null) {
      images = [];
      json['images'].forEach((v) {
        images.add(new Images.fromJson(v));
      });
    }
    itemCount = json['itemCount'];
    uid = json['uid'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.images != null) {
      data['images'] = this.images.map((v) => v.toJson()).toList();
    }
    data['itemCount'] = this.itemCount;
    data['uid'] = this.uid;
    data['status'] = this.status;
    return data;
  }
}

class Images {
  String id;
  String imageUrl;
  String createdAt;
  String createdBy;

  Images({this.id, this.imageUrl, this.createdAt});

  Images.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    imageUrl = json['image'];
    createdAt = json['createdAt'];
    createdBy = json['uid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['image'] = this.imageUrl;
    data['createdAt'] = this.createdAt;
    data['uid'] = this.createdBy;
    return data;
  }
}
