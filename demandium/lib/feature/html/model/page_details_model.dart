// To parse this JSON data, do
//
//     final pageDetailsModel = pageDetailsModelFromJson(jsonString);

import 'dart:convert';

PageDetailsModel pageDetailsModelFromJson(String str) => PageDetailsModel.fromJson(json.decode(str));

String pageDetailsModelToJson(PageDetailsModel data) => json.encode(data.toJson());

class PageDetailsModel {
  String? id;
  String? pageKey;
  String? title;
  String? content;
  dynamic image;
  int? isActive;
  int? isDefault;
  DateTime? createdAt;
  DateTime? updatedAt;

  PageDetailsModel({
    this.id,
    this.pageKey,
    this.title,
    this.content,
    this.image,
    this.isActive,
    this.isDefault,
    this.createdAt,
    this.updatedAt,
  });

  factory PageDetailsModel.fromJson(Map<String, dynamic>? json) => PageDetailsModel(
    id: json?["id"],
    pageKey: json?["page_key"],
    title: json?["title"],
    content: json?["content"],
    image: json?["image_full_path"],
    isActive: json?["is_active"],
    isDefault: json?["is_default"],
    createdAt: json?["created_at"] == null ? null : DateTime.parse(json?["created_at"]),
    updatedAt: json?["updated_at"] == null ? null : DateTime.parse(json?["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "page_key": pageKey,
    "title": title,
    "content": content,
    "image": image,
    "is_active": isActive,
    "is_default": isDefault,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
