// To parse this JSON data, do
//
//     final applicationModel = applicationModelFromJson(jsonString);

import 'dart:convert';

ApplicationModel applicationModelFromJson(String str) =>
    ApplicationModel.fromJson(json.decode(str));

String applicationModelToJson(ApplicationModel data) =>
    json.encode(data.toJson());

class ApplicationModel {
  List<Datum> data;
  int count;
  String message;
  int status;

  ApplicationModel({
    required this.data,
    required this.count,
    required this.message,
    required this.status,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) =>
      ApplicationModel(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
        count: json["count"],
        message: json["message"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "count": count,
    "message": message,
    "status": status,
  };
}

class Datum {
  String shopAddress;
  String? shopTaxId;
  String shopPhone;
  String? reviewNote;
  String? shopDescription;
  String? closeBy;
  String? closeByName;
  String? imageUrl;
  String? shopWebsite;
  String uid;
  int id;
  String? shopEmail;
  String? shopContactName;
  String? shopImage;
  String? shopNote;
  DateTime? reviewAt;
  String? reviewBy;
  String? reviewByName;
  int applicantIdentity;
  DateTime createdAt;
  int isClose;
  String shopName;
  String reviewStatus;
  DateTime? closeAt;
  String? shopMobile;

  Datum({
    required this.shopAddress,
    required this.shopTaxId,
    required this.shopPhone,
    required this.reviewNote,
    required this.shopDescription,
    required this.closeBy,
    required this.closeByName,
    required this.imageUrl,
    required this.shopWebsite,
    required this.uid,
    required this.id,
    required this.shopEmail,
    required this.shopContactName,
    required this.shopImage,
    required this.shopNote,
    required this.reviewAt,
    required this.reviewBy,
    required this.reviewByName,
    required this.applicantIdentity,
    required this.createdAt,
    required this.isClose,
    required this.shopName,
    required this.reviewStatus,
    required this.closeAt,
    required this.shopMobile,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    shopAddress: json["shop_address"],
    shopTaxId: json["shop_tax_id"],
    shopPhone: json["shop_phone"] ?? '',
    reviewNote: json["review_note"] ?? '',
    shopDescription: json["shop_description"] ?? '',
    closeBy: json["close_by"] ?? '',
    closeByName: json["close_by_name"] ?? '',
    imageUrl: json["image_url"] ?? '',
    shopWebsite: json["shop_website"] ?? '',
    uid: json["uid"] ?? '',
    id: json["id"],
    shopEmail: json["shop_email"] ?? '',
    shopContactName: json["shop_contact_name"] ?? '',
    shopImage: json["shop_image"] ?? '',
    shopNote: json["shop_note"] ?? '',
    reviewAt: json["review_at"] ?? '',
    reviewBy: json["review_by"] ?? '',
    reviewByName: json["review_by_name"] ?? '',
    applicantIdentity: json["applicant_identity"],
    createdAt: json["created_at"] ?? '',
    isClose: json["is_close"],
    shopName: json["shop_name"] ?? '',
    reviewStatus: json["review_status"] ?? '',
    closeAt: json["close_at"] ?? '',
    shopMobile: json["shop_mobile"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "shop_address": shopAddress,
    "shop_tax_id": shopTaxId,
    "shop_phone": shopPhone,
    "review_note": reviewNote,
    "shop_description": shopDescription,
    "close_by": closeBy,
    "close_by_name": closeByName,
    "image_url": imageUrl,
    "shop_website": shopWebsite,
    "uid": uid,
    "id": id,
    "shop_email": shopEmail,
    "shop_contact_name": shopContactName,
    "shop_image": shopImage,
    "shop_note": shopNote,
    "review_at": reviewAt,
    "review_by": reviewBy,
    "review_by_name": reviewByName,
    "applicant_identity": applicantIdentity,
    "created_at": createdAt,
    "is_close": isClose,
    "shop_name": shopName,
    "review_status": reviewStatus,
    "close_at": closeAt,
    "shop_mobile": shopMobile,
  };
}
