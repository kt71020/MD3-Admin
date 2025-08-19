// To parse this JSON data, do
//
//     final applicationUploadModel = applicationUploadModelFromJson(jsonString);

import 'dart:convert';

ApplicationUploadModel applicationUploadModelFromJson(String str) =>
    ApplicationUploadModel.fromJson(json.decode(str));

String applicationUploadModelToJson(ApplicationUploadModel data) =>
    json.encode(data.toJson());

class ApplicationUploadModel {
  int status;
  List<String> csvContentList;
  int error;
  int sid;
  ValidationDetails validationDetails;
  List<String> message;
  int version;
  int rowsRegional;
  List<int>? regionalIdList;

  ApplicationUploadModel({
    required this.status,
    required this.csvContentList,
    required this.error,
    required this.sid,
    required this.validationDetails,
    required this.message,
    required this.version,
    required this.rowsRegional,
    this.regionalIdList,
  });

  factory ApplicationUploadModel.fromJson(
    Map<String, dynamic> json,
  ) => ApplicationUploadModel(
    status: json["status"],
    csvContentList: List<String>.from(json["csv_content_list"].map((x) => x)),
    error: json["error"],
    sid: json["sid"],
    validationDetails: ValidationDetails.fromJson(json["validation_details"]),
    message: List<String>.from(json["message"].map((x) => x)),
    version: json["version"],
    rowsRegional: json["rows_regional"],
    regionalIdList: List<int>.from(json["regional_id_list"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "csv_content_list": List<dynamic>.from(csvContentList.map((x) => x)),
    "error": error,
    "sid": sid,
    "validation_details": validationDetails.toJson(),
    "message": List<dynamic>.from(message.map((x) => x)),
    "version": version,
    "rows_regional": rowsRegional,
    if (regionalIdList != null)
      "regional_id_list": List<dynamic>.from(regionalIdList!.map((x) => x)),
  };
}

class ValidationDetails {
  int shopInfoCount;
  int categoryCount;
  int shopOptionCount;
  int shopOptionValueCount;
  int productCount;
  int regionalCount;

  ValidationDetails({
    required this.shopInfoCount,
    required this.categoryCount,
    required this.shopOptionCount,
    required this.shopOptionValueCount,
    required this.productCount,
    required this.regionalCount,
  });

  factory ValidationDetails.fromJson(Map<String, dynamic> json) =>
      ValidationDetails(
        shopInfoCount: json["shop_info_count"],
        categoryCount: json["category_count"],
        shopOptionCount: json["shop_option_count"],
        shopOptionValueCount: json["shop_option_value_count"],
        productCount: json["product_count"],
        regionalCount: json["regional_count"],
      );

  Map<String, dynamic> toJson() => {
    "shop_info_count": shopInfoCount,
    "category_count": categoryCount,
    "shop_option_count": shopOptionCount,
    "shop_option_value_count": shopOptionValueCount,
    "product_count": productCount,
    "regional_count": regionalCount,
  };
}
