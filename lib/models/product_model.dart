// Model dibuat dari JSON https://dummyjson.com/products
// (hasil konversi JSON ke Dart, lalu disesuaikan agar aman terhadap
// angka bulat dan field yang tidak dikirim server)

class ProductsResponse {
  List<Product>? products;
  int? total;
  int? skip;
  int? limit;

  ProductsResponse({this.products, this.total, this.skip, this.limit});

  ProductsResponse.fromJson(Map<String, dynamic> json) {
    if (json['products'] != null) {
      products = <Product>[];
      json['products'].forEach((v) {
        products!.add(Product.fromJson(v));
      });
    }
    total = (json['total'] as num?)?.toInt();
    skip = (json['skip'] as num?)?.toInt();
    limit = (json['limit'] as num?)?.toInt();
  }
}

class Product {
  int? id;
  String? title;
  String? description;
  String? category;
  double? price;
  double? discountPercentage;
  double? rating;
  int? stock;
  List<String>? tags;
  String? brand;
  String? sku;
  int? weight;
  Dimensions? dimensions;
  String? warrantyInformation;
  String? shippingInformation;
  String? availabilityStatus;
  List<Reviews>? reviews;
  String? returnPolicy;
  int? minimumOrderQuantity;
  Meta? meta;
  List<String>? images;
  String? thumbnail;

  Product({
    this.id,
    this.title,
    this.description,
    this.category,
    this.price,
    this.discountPercentage,
    this.rating,
    this.stock,
    this.tags,
    this.brand,
    this.sku,
    this.weight,
    this.dimensions,
    this.warrantyInformation,
    this.shippingInformation,
    this.availabilityStatus,
    this.reviews,
    this.returnPolicy,
    this.minimumOrderQuantity,
    this.meta,
    this.images,
    this.thumbnail,
  });

  Product.fromJson(Map<String, dynamic> json) {
    id = (json['id'] as num?)?.toInt();
    title = json['title'];
    description = json['description'];
    category = json['category'];
    price = (json['price'] as num?)?.toDouble();
    discountPercentage = (json['discountPercentage'] as num?)?.toDouble();
    rating = (json['rating'] as num?)?.toDouble();
    stock = (json['stock'] as num?)?.toInt();
    tags = (json['tags'] as List?)?.cast<String>();
    brand = json['brand'];
    sku = json['sku'];
    weight = (json['weight'] as num?)?.toInt();
    dimensions = json['dimensions'] != null
        ? Dimensions.fromJson(json['dimensions'])
        : null;
    warrantyInformation = json['warrantyInformation'];
    shippingInformation = json['shippingInformation'];
    availabilityStatus = json['availabilityStatus'];
    if (json['reviews'] != null) {
      reviews = <Reviews>[];
      json['reviews'].forEach((v) {
        reviews!.add(Reviews.fromJson(v));
      });
    }
    returnPolicy = json['returnPolicy'];
    minimumOrderQuantity = (json['minimumOrderQuantity'] as num?)?.toInt();
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    images = (json['images'] as List?)?.cast<String>();
    thumbnail = json['thumbnail'];
  }
}

class Dimensions {
  double? width;
  double? height;
  double? depth;

  Dimensions({this.width, this.height, this.depth});

  Dimensions.fromJson(Map<String, dynamic> json) {
    width = (json['width'] as num?)?.toDouble();
    height = (json['height'] as num?)?.toDouble();
    depth = (json['depth'] as num?)?.toDouble();
  }
}

class Reviews {
  int? rating;
  String? comment;
  String? date;
  String? reviewerName;
  String? reviewerEmail;

  Reviews({
    this.rating,
    this.comment,
    this.date,
    this.reviewerName,
    this.reviewerEmail,
  });

  Reviews.fromJson(Map<String, dynamic> json) {
    rating = (json['rating'] as num?)?.toInt();
    comment = json['comment'];
    date = json['date'];
    reviewerName = json['reviewerName'];
    reviewerEmail = json['reviewerEmail'];
  }
}

class Meta {
  String? createdAt;
  String? updatedAt;
  String? barcode;
  String? qrCode;

  Meta({this.createdAt, this.updatedAt, this.barcode, this.qrCode});

  Meta.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    barcode = json['barcode'];
    qrCode = json['qrCode'];
  }
}

// Satu kategori dari https://dummyjson.com/products/categories
class Category {
  String? slug;
  String? name;

  Category({this.slug, this.name});

  Category.fromJson(Map<String, dynamic> json) {
    slug = json['slug'];
    name = json['name'];
  }
}
