import 'dart:convert';

import 'package:cubes_n_slice/models/dto/product.dart';

class Categorie {
  String? category_id;
  String? name;
  String? image;
  String? thumbnail;

  Categorie({this.category_id, this.name, this.image, this.thumbnail});

  // ---------------------------------------------------------------------------
  // JSON
  // ---------------------------------------------------------------------------
  factory Categorie.fromRawJson(String str) =>
      Categorie.fromMap(json.decode(str));

  String toRawJson() => json.encode(toMap());

  // ---------------------------------------------------------------------------
  // Maps
  // ---------------------------------------------------------------------------

  factory Categorie.fromMap(Map<String, dynamic> json) {
    print(json);
    return Categorie(
        category_id: json['category_id'],
        name: json['name'],
        image: json['image'],
        thumbnail: json['thumbnail']);
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['category_id'] = category_id;
    data['name'] = name;
    data['image'] = image;
    data['thumbnail'] = thumbnail;
    return data;
  }
}

class SubCategorie {
  String? subcategory_id;
  String? subcategory_name;
  String? image;
  String? thumbnail;
  List<Product>? products;

  SubCategorie(
      {this.subcategory_id,
      this.subcategory_name,
      this.image,
      this.thumbnail,
      this.products});

  // ---------------------------------------------------------------------------
  // JSON
  // ---------------------------------------------------------------------------
  factory SubCategorie.fromRawJson(String str) =>
      SubCategorie.fromMap(json.decode(str));

  String toRawJson() => json.encode(toMap());

  // ---------------------------------------------------------------------------
  // Maps
  // ---------------------------------------------------------------------------

  factory SubCategorie.fromMap(Map<String, dynamic> json) {
    print(json);
    return SubCategorie(
      subcategory_id: json['subcategory_id'],
      subcategory_name: json['subcategory_name'],
      image: json['image'],
      thumbnail: json['thumbnail'],
      products: json["products"] == null
          ? []
          : List<Product>.from(json["products"].map((x) => Product.fromMap(x))),
    );
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['subcategory_id'] = subcategory_id;
    data['subcategory_name'] = subcategory_name;
    data['image'] = image;
    data['thumbnail'] = thumbnail;
    data['products'] = products == null
        ? []
        : List<dynamic>.from(products!.map((x) => x.toMap()));

    return data;
  }
}
