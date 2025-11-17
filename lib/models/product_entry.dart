// To parse this JSON data, do
//
//     final productEntry = productEntryFromJson(jsonString);

import 'dart:convert';

List<ProductEntry> productEntryFromJson(String str) => List<ProductEntry>.from(json.decode(str).map((x) => ProductEntry.fromJson(x)));

String productEntryToJson(List<ProductEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProductEntry {
    String id;
    String name;
    String user;
    String description;
    String category;
    String categoryId;
    String thumbnail;
    int price;
    int stock;
    bool isFeatured;
    int userId;
    DateTime createdAt;
    int views;

    ProductEntry({
        required this.id,
        required this.name,
        required this.user,
        required this.description,
        required this.category,
        required this.categoryId,
        required this.thumbnail,
        required this.price,
        required this.stock,
        required this.isFeatured,
        required this.userId,
        required this.createdAt,
        required this.views,
    });

    factory ProductEntry.fromJson(Map<String, dynamic> json) => ProductEntry(
        id: json["id"],
        name: json["name"],
        user: json["user"],
        description: json["description"],
        category: json["category"],
        categoryId: json["category_id"],
        thumbnail: json["thumbnail"],
        price: json["price"],
        stock: json["stock"],
        isFeatured: json["is_featured"],
        userId: json["user_id"],
        createdAt: DateTime.parse(json["created_at"]),
        views: json["views"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "user": user,
        "description": description,
        "category": category,
        "category_id": categoryId,
        "thumbnail": thumbnail,
        "price": price,
        "stock": stock,
        "is_featured": isFeatured,
        "user_id": userId,
        "created_at": createdAt.toIso8601String(),
        "views": views,
    };
}
