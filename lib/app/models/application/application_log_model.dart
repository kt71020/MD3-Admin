// To parse this JSON data, do
//
//     final appleicationLogModel = appleicationLogModelFromJson(jsonString);

import 'dart:convert';

ApplicationLogModel applicationLogModelFromJson(String str) =>
    ApplicationLogModel.fromJson(json.decode(str));

String applicationLogModelToJson(ApplicationLogModel data) =>
    json.encode(data.toJson());

class ApplicationLogModel {
  int status;
  String message;
  int count;
  List<ApplicationLog> applicationLog;

  ApplicationLogModel({
    required this.status,
    required this.message,
    required this.count,
    required this.applicationLog,
  });

  factory ApplicationLogModel.fromJson(Map<String, dynamic> json) =>
      ApplicationLogModel(
        status: json["status"],
        message: json["message"],
        count: json["count"],
        applicationLog: List<ApplicationLog>.from(
          json["application_log"].map((x) => ApplicationLog.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "count": count,
    "application_log": List<dynamic>.from(
      applicationLog.map((x) => x.toJson()),
    ),
  };
}

class ApplicationLog {
  String type;
  int logId;
  String? content;
  int id;
  String createdAt;
  String name;

  ApplicationLog({
    required this.type,
    required this.logId,
    required this.content,
    required this.id,
    required this.createdAt,
    required this.name,
  });

  factory ApplicationLog.fromJson(Map<String, dynamic> json) => ApplicationLog(
    type: json["type"],
    logId: json["log_id"],
    content: json["content"] ?? '',
    id: json["id"],
    createdAt: json["created_at"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "log_id": logId,
    "content": content,
    "id": id,
    "created_at": createdAt,
    "name": name,
  };
}
