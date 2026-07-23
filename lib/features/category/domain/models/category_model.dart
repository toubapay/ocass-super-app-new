class CategoryModel {
  int? id;
  String? name;
  String? imageFullUrl;
  String? image;

  CategoryModel({this.id, this.name, this.imageFullUrl, this.image});

  CategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    imageFullUrl = json['image_full_url'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image_full_url'] = imageFullUrl;
    data['image'] = image;
    return data;
  }
}
