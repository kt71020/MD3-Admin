// To parse this JSON data, do
//
//     final appleicationCsvModel = appleicationCsvModelFromJson(jsonString);

import 'dart:convert';

AppleicationCsvModel appleicationCsvModelFromJson(String str) =>
    AppleicationCsvModel.fromJson(json.decode(str));

String appleicationCsvModelToJson(AppleicationCsvModel data) =>
    json.encode(data.toJson());

class AppleicationCsvModel {
  String message;
  int status;
  List<String> csv;

  AppleicationCsvModel({
    required this.message,
    required this.status,
    required this.csv,
  });

  factory AppleicationCsvModel.fromJson(Map<String, dynamic> json) =>
      AppleicationCsvModel(
        message: json["message"],
        status: json["status"],
        csv: List<String>.from(json["csv"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "status": status,
    "csv": List<dynamic>.from(csv.map((x) => x)),
  };
}
