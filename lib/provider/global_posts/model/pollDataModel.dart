import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PollDataModel {
  PollQuestion pollQuestion;
  List<PollOption> pollOption;

  bool anonymously;

  Map<String, dynamic> userWhoVoted;
  String pollId, type, createdBy, textPost, postId, id;
  int createdAt;

  PollDataModel(
      {this.pollId,
      @required this.pollQuestion,
      @required this.pollOption,
      @required this.userWhoVoted,
      @required this.anonymously,
      @required this.type,
      @required this.createdBy,
      @required this.createdAt,
      @required this.id,

      //
      this.textPost,
      this.postId});

  Map<String, dynamic> toMap() {
    return {
      "textPost": textPost,
      "createdBy": createdBy,
      "createdAt": createdAt,
      "anonymously": anonymously,
      "postId": postId,
      "type": type,
      "id": id,
    };
  }

  PollDataModel.fromJson(Map<String, dynamic> json) {
    pollQuestion = json['PollQuestion'] != null ? new PollQuestion.fromJson(json['PollQuestion']) : null;
    if (json['PollOption'] != null) {
      pollOption = [];
      json['PollOption'].forEach((v) {
        pollOption.add(new PollOption.fromJson(v));
      });
    }
    userWhoVoted = json['userWhoVoted'];
    pollId = json['id'];
    id = json['id'];
    type = json['type'];
    createdBy = json['createdBy'];
    createdAt = json['createdAt'];
    anonymously = json['anonymously'] != null ? json['anonymously'] : true;
    //
    textPost = json['textPost'];
    postId = json['postId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.pollQuestion != null) {
      data['PollQuestion'] = this.pollQuestion.toJson();
    }
    if (this.pollOption != null) {
      data['PollOption'] = this.pollOption.map((v) => v.toJson()).toList();
    }
    data['userWhoVoted'] = this.userWhoVoted;
    data['id'] = this.pollId;
    data['type'] = this.type;
    data['createdAt'] = this.createdAt;
    data['id'] = this.id;
    data['createdBy'] = this.createdBy;
    data['anonymously'] = this.anonymously;
    //
    data['textPost'] = this.textPost;
    data['postId'] = this.postId;

    return data;
  }

  factory PollDataModel.fromDocument(DocumentSnapshot doc) => PollDataModel(
        pollQuestion: PollQuestion(
          question: doc["PollQuestion"]["question"],
          createdAt: doc["PollQuestion"]["createdAt"],
          createdBy: doc["PollQuestion"]["createdBy"],
          duration: doc["PollQuestion"]["duration"],
        ),
        pollOption: List.generate(doc["PollOption"].length, (index) => PollOption(option: doc["PollOption"][index]["option"], voteCount: doc["PollOption"][index]["voteCount"])),
        userWhoVoted: doc["userWhoVoted"],
        pollId: doc.id,
        createdAt: doc['createdAt'],
        createdBy: doc['createdBy'],
        type: doc['poll'],
        id: doc['id'],
        anonymously: doc['anonymously'] != null ? doc['anonymously'] : true,
        //
        textPost: doc['textPost'],
        postId: doc['postId'],
      );
}

class PollQuestion {
  PollQuestion({
    @required this.question,
    @required this.createdBy,
    @required this.createdAt,
    @required this.duration,
  });

  String question, type, textPost;
  String createdBy;
  Timestamp createdAt;
  Timestamp duration;

  factory PollQuestion.fromJson(Map<String, dynamic> json) => PollQuestion(
        question: json["question"],
        createdBy: json["createdBy"],
        createdAt: json["createdAt"],
        duration: json["duration"],
      );

  Map<String, dynamic> toJson() => {
        "question": question,
        "createdBy": createdBy,
        "createdAt": createdAt,
        "duration": duration,
      };

  factory PollQuestion.fromDocument(DocumentSnapshot doc) => PollQuestion(
        question: doc["PollQuestion"]["question"],
        createdBy: doc["PollQuestion"]["createdAt"],
        createdAt: doc["PollQuestion"]["createdBy"],
        duration: doc["PollQuestion"]["duration"],
      );
}

class PollOption {
  PollOption({
    @required this.option,
    @required this.voteCount,
  });

  String option;
  int voteCount;

  factory PollOption.fromJson(Map<String, dynamic> json) => PollOption(
        option: json["option"],
        voteCount: json["voteCount"],
      );

  Map<String, dynamic> toJson() => {
        "option": option,
        "voteCount": voteCount,
      };

  factory PollOption.fromDocument(DocumentSnapshot doc) => PollOption(
        option: doc["option"],
        voteCount: doc['voteCount'],
      );
}
