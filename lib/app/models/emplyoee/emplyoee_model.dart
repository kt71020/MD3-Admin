// To parse this JSON data, do
//
//     final emplyoeeModel = emplyoeeModelFromJson(jsonString);

import 'dart:convert';

EmplyoeeModel emplyoeeModelFromJson(String str) =>
    EmplyoeeModel.fromJson(json.decode(str));

String emplyoeeModelToJson(EmplyoeeModel data) => json.encode(data.toJson());

class EmplyoeeModel {
  int status;
  int employeeCount;
  String message;
  List<EmployeeList> employeeList;

  EmplyoeeModel({
    required this.status,
    required this.employeeCount,
    required this.message,
    required this.employeeList,
  });

  factory EmplyoeeModel.fromJson(Map<String, dynamic> json) => EmplyoeeModel(
    status: json["status"],
    employeeCount: json["employee_count"],
    message: json["message"],
    employeeList: List<EmployeeList>.from(
      json["employee_list"].map((x) => EmployeeList.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "employee_count": employeeCount,
    "message": message,
    "employee_list": List<dynamic>.from(employeeList.map((x) => x.toJson())),
  };
}

class EmployeeList {
  DateTime createdAt;
  String level;
  String employeeId;
  bool status;
  String email;
  String name;
  DateTime modifiedAt;

  EmployeeList({
    required this.createdAt,
    required this.level,
    required this.employeeId,
    required this.status,
    required this.email,
    required this.name,
    required this.modifiedAt,
  });

  factory EmployeeList.fromJson(Map<String, dynamic> json) => EmployeeList(
    createdAt: DateTime.parse(json["created_at"]),
    level: json["level"],
    employeeId: json["employee_id"],
    status: json["status"] == 1 ? true : false,
    email: json["email"],
    name: json["name"],
    modifiedAt: DateTime.parse(json["modified_at"]),
  );

  Map<String, dynamic> toJson() => {
    "created_at": createdAt.toIso8601String(),
    "level": level,
    "employee_id": employeeId,
    "status": status,
    "email": email,
    "name": name,
    "modified_at": modifiedAt.toIso8601String(),
  };
}
