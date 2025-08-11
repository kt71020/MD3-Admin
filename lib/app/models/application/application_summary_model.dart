// To parse this JSON data, do
//
//     final appleicationSummaryModel = appleicationSummaryModelFromJson(jsonString);

import 'dart:convert';

AppleicationSummaryModel appleicationSummaryModelFromJson(String str) =>
    AppleicationSummaryModel.fromJson(json.decode(str));

String appleicationSummaryModelToJson(AppleicationSummaryModel data) =>
    json.encode(data.toJson());

class AppleicationSummaryModel {
  String message;
  Channel channel;
  int status;

  AppleicationSummaryModel({
    required this.message,
    required this.channel,
    required this.status,
  });

  factory AppleicationSummaryModel.fromJson(Map<String, dynamic> json) =>
      AppleicationSummaryModel(
        message: json["message"],
        channel: Channel.fromJson(json["channel"]),
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "channel": channel.toJson(),
    "status": status,
  };
}

class Channel {
  ApplicationSummary shop;
  ApplicationSummary all;
  ApplicationSummary user;

  Channel({required this.shop, required this.all, required this.user});

  factory Channel.fromJson(Map<String, dynamic> json) => Channel(
    shop: ApplicationSummary.fromJson(json["SHOP"]),
    all: ApplicationSummary.fromJson(json["ALL"]),
    user: ApplicationSummary.fromJson(json["USER"]),
  );

  Map<String, dynamic> toJson() => {
    "SHOP": shop.toJson(),
    "ALL": all.toJson(),
    "USER": user.toJson(),
  };
}

class ApplicationSummary {
  int processing;
  int newApplication;
  String channel;
  int approve;
  int colse;
  int pedding;
  int reject;
  int totalApplication;
  int check;

  ApplicationSummary({
    required this.processing,
    required this.newApplication,
    required this.channel,
    required this.approve,
    required this.colse,
    required this.pedding,
    required this.reject,
    required this.totalApplication,
    required this.check,
  });

  factory ApplicationSummary.fromJson(Map<String, dynamic> json) =>
      ApplicationSummary(
        processing: json["processing"],
        newApplication: json["newApplication"],
        channel: json["channel"],
        approve: json["approve"],
        colse: json["colse"],
        pedding: json["pedding"],
        reject: json["reject"],
        totalApplication: json["totalApplication"],
        check: json["check"],
      );

  Map<String, dynamic> toJson() => {
    "processing": processing,
    "newApplication": newApplication,
    "channel": channel,
    "approve": approve,
    "colse": colse,
    "pedding": pedding,
    "reject": reject,
    "totalApplication": totalApplication,
    "check": check,
  };
}
