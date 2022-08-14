import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum MessageType { text, image, videoCall }

class ChatMessageModel {
  ChatMessageModel({
    this.messageId,
    this.receiverId,
    this.senderId,
    @required this.senderName,
    this.text,
    this.imageUrl,
    this.isRead,
    this.type,
    this.createdAt,
    this.replyChatMessage,
    this.liked,
  });

  String messageId;
  String receiverId;
  String senderId;
  String senderName;
  String text;
  String imageUrl;
  bool isRead, liked;
  MessageType type;
  int createdAt;
  ChatMessageModel replyChatMessage;

  factory ChatMessageModel.fromJson(Map json) => ChatMessageModel(
        liked: json['liked'],
        messageId: json["msgId"],
        receiverId: json["receiverId"],
        senderId: json["senderId"],
        senderName: json["senderName"],
        text: json["text"],
        imageUrl: json["imageURL"],
        isRead: json["isRead"],
        type: json["type"] == "text"
            ? MessageType.text
            : json["type"] == "image"
                ? MessageType.image
                : MessageType.videoCall,
        createdAt: json["createdAt"],
        replyChatMessage: json["replyChatMessage"] == null
            ? null
            : ChatMessageModel.fromJson(json["replyChatMessage"]),
      );

  Map<String, dynamic> toJson() {
    if (messageId != null) {
      return {
        "liked": liked,
        "messageId": messageId,
        "receiverId": receiverId,
        "senderId": senderId,
        "senderName": senderName,
        "text": text,
        "imageURL": imageUrl,
        "isRead": isRead,
        "type": type == MessageType.text
            ? "text"
            : type == MessageType.image
                ? "image"
                : "videoCall",
        "createdAt": createdAt,
        "replyChatMessage":
            replyChatMessage == null ? {} : replyChatMessage.toJson(),
      };
    } else {
      return {
        "liked": liked,
        "receiverId": receiverId,
        "senderId": senderId,
        "senderName": senderName,
        "text": text,
        "imageURL": imageUrl,
        "isRead": isRead,
        "type": type == MessageType.text
            ? "text"
            : type == MessageType.image
                ? "image"
                : "videoCall",
        "createdAt": createdAt,
        "replyChatMessage":
            replyChatMessage == null ? {} : replyChatMessage.toJson(),
      };
    }
  }

  factory ChatMessageModel.fromDocument(DocumentSnapshot doc) =>
      ChatMessageModel(
        liked: doc["liked"],
        messageId: doc.id,
        receiverId: doc["receiverId"],
        senderId: doc["senderId"],
        senderName: doc["senderName"],
        text: doc["text"],
        imageUrl: doc["imageUrl"],
        isRead: doc["isRead"],
        type: doc["type"] == "text"
            ? MessageType.text
            : doc["type"] == "image"
                ? MessageType.image
                : MessageType.videoCall,
        createdAt: doc["createdAt"],
      );
}
