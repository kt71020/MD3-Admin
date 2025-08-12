// To parse this JSON data, do
//
//     final admsSummaryModel = admsSummaryModelFromJson(jsonString);

import 'dart:convert';

AdmsSummaryModel admsSummaryModelFromJson(String str) =>
    AdmsSummaryModel.fromJson(json.decode(str));

String admsSummaryModelToJson(AdmsSummaryModel data) =>
    json.encode(data.toJson());

class AdmsSummaryModel {
  int groupCount;
  int userCount;
  int shopCount;

  AdmsSummaryModel({
    required this.groupCount,
    required this.userCount,
    required this.shopCount,
  });

  factory AdmsSummaryModel.fromJson(Map<String, dynamic> json) =>
      AdmsSummaryModel(
        groupCount: json["group_count"],
        userCount: json["user_count"],
        shopCount: json["shop_count"],
      );

  Map<String, dynamic> toJson() => {
    "group_count": groupCount,
    "user_count": userCount,
    "shop_count": shopCount,
  };
}
