// To parse this JSON data, do
//
//     final applicationModel = applicationModelFromJson(jsonString);

import 'dart:convert';

ApplicationModel applicationModelFromJson(String str) =>
    ApplicationModel.fromJson(json.decode(str));

String applicationModelToJson(ApplicationModel data) =>
    json.encode(data.toJson());

class ApplicationModel {
  int count;
  int status;
  String message;
  List<Application> data;

  ApplicationModel({
    required this.count,
    required this.status,
    required this.data,
    required this.message,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) =>
      ApplicationModel(
        count: json["count"],
        status: json["status"],
        data: List<Application>.from(
          json["data"].map((x) => Application.fromJson(x)),
        ),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
    "count": count,
    "status": status,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "message": message,
  };
}

class Application {
  int id;
  String? reviewNote;
  String imageUrl;
  String? closeAt;
  String? closeBy;
  String? shopImage;
  String shopAddress;
  String uid;
  String? shopMobile;
  String shopName;
  String? shopEmail;
  String? shopDescription;
  String reviewStatus;
  String? closeByName;
  String shopPhone;
  String? shopContactName;
  String? reviewBy;
  String status;
  String? shopWebsite;
  bool isClose;
  String? reviewerName;
  String? shopTaxId;
  String? shopNote;
  int applicantIdentity;
  String? reviewAt;
  String? reviewByName;
  String createdAt;
  String? closerName;
  String userName;
  String? shopCity;
  String? shopRegion;
  String channel;
  Application({
    required this.id,
    required this.reviewNote,
    required this.imageUrl,
    required this.closeAt,
    required this.closeBy,
    required this.shopImage,
    required this.shopAddress,
    required this.uid,
    required this.shopMobile,
    required this.shopName,
    required this.shopEmail,
    required this.shopDescription,
    required this.reviewStatus,
    required this.closeByName,
    required this.shopPhone,
    required this.shopContactName,
    required this.reviewBy,
    required this.status,
    required this.shopWebsite,
    required this.isClose,
    required this.reviewerName,
    required this.shopTaxId,
    required this.shopNote,
    required this.applicantIdentity,
    required this.reviewAt,
    required this.reviewByName,
    required this.createdAt,
    required this.closerName,
    required this.userName,
    required this.shopCity,
    required this.shopRegion,
    required this.channel,
  });

  factory Application.fromJson(Map<String, dynamic> json) => Application(
    id: json["id"],
    reviewNote: json["review_note"],
    imageUrl: json["image_url"],
    closeAt: json["close_at"],
    closeBy: json["close_by"],
    shopImage: json["shop_image"],
    shopAddress: json["shop_address"],
    uid: json["uid"],
    shopMobile: json["shop_mobile"],
    shopName: json["shop_name"],
    shopEmail: json["shop_email"],
    shopDescription: json["shop_description"],
    reviewStatus: json["review_status"],
    closeByName: json["close_by_name"],
    shopPhone: json["shop_phone"],
    shopContactName: json["shop_contact_name"],
    reviewBy: json["review_by"],
    status: json["status"],
    shopWebsite: json["shop_website"],
    isClose: json["is_close"] == 1,
    reviewerName: json["reviewer_name"],
    shopTaxId: json["shop_tax_id"],
    shopNote: json["shop_note"],
    applicantIdentity: json["applicant_identity"],
    reviewAt: json["review_at"],
    reviewByName: json["review_by_name"],
    createdAt: json["created_at"],
    closerName: json["closer_name"],
    userName: json["user_name"],
    shopCity: json["shop_city"],
    shopRegion: json["shop_region"],
    channel: json["channel"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "review_note": reviewNote,
    "image_url": imageUrl,
    "close_at": closeAt,
    "close_by": closeBy,
    "shop_image": shopImage,
    "shop_address": shopAddress,
    "uid": uid,
    "shop_mobile": shopMobile,
    "shop_name": shopName,
    "shop_email": shopEmail,
    "shop_description": shopDescription,
    "review_status": reviewStatus,
    "close_by_name": closeByName,
    "shop_phone": shopPhone,
    "shop_contact_name": shopContactName,
    "review_by": reviewBy,
    "status": status,
    "shop_website": shopWebsite,
    "is_close": isClose,
    "reviewer_name": reviewerName,
    "shop_tax_id": shopTaxId,
    "shop_note": shopNote,
    "applicant_identity": applicantIdentity,
    "review_at": reviewAt,
    "review_by_name": reviewByName,
    "created_at": createdAt,
    "closer_name": closerName,
    "user_name": userName,
    "shop_city": shopCity,
    "shop_region": shopRegion,
    "channel": channel,
  };

  /// 創建一個新的 Application 實例，只更新指定的欄位
  Application copyWith({
    int? id,
    String? reviewNote,
    String? imageUrl,
    String? closeAt,
    String? closeBy,
    String? shopImage,
    String? shopAddress,
    String? uid,
    String? shopMobile,
    String? shopName,
    String? shopEmail,
    String? shopDescription,
    String? reviewStatus,
    String? closeByName,
    String? shopPhone,
    String? shopContactName,
    String? reviewBy,
    String? status,
    String? shopWebsite,
    bool? isClose,
    String? reviewerName,
    String? shopTaxId,
    String? shopNote,
    int? applicantIdentity,
    String? reviewAt,
    String? reviewByName,
    String? createdAt,
    String? closerName,
    String? userName,
    String? shopCity,
    String? shopRegion,
    String? channel,
  }) {
    return Application(
      id: id ?? this.id,
      reviewNote: reviewNote ?? this.reviewNote,
      imageUrl: imageUrl ?? this.imageUrl,
      closeAt: closeAt ?? this.closeAt,
      closeBy: closeBy ?? this.closeBy,
      shopImage: shopImage ?? this.shopImage,
      shopAddress: shopAddress ?? this.shopAddress,
      uid: uid ?? this.uid,
      shopMobile: shopMobile ?? this.shopMobile,
      shopName: shopName ?? this.shopName,
      shopEmail: shopEmail ?? this.shopEmail,
      shopDescription: shopDescription ?? this.shopDescription,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      closeByName: closeByName ?? this.closeByName,
      shopPhone: shopPhone ?? this.shopPhone,
      shopContactName: shopContactName ?? this.shopContactName,
      reviewBy: reviewBy ?? this.reviewBy,
      status: status ?? this.status,
      shopWebsite: shopWebsite ?? this.shopWebsite,
      isClose: isClose ?? this.isClose,
      reviewerName: reviewerName ?? this.reviewerName,
      shopTaxId: shopTaxId ?? this.shopTaxId,
      shopNote: shopNote ?? this.shopNote,
      applicantIdentity: applicantIdentity ?? this.applicantIdentity,
      reviewAt: reviewAt ?? this.reviewAt,
      reviewByName: reviewByName ?? this.reviewByName,
      createdAt: createdAt ?? this.createdAt,
      closerName: closerName ?? this.closerName,
      userName: userName ?? this.userName,
      shopCity: shopCity ?? this.shopCity,
      shopRegion: shopRegion ?? this.shopRegion,
      channel: channel ?? this.channel,
    );
  }
}
