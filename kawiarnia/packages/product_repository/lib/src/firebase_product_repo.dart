import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:product_repository/product_repository.dart';

class FirebaseKawiarniaRepo implements ProductRepo {
  final kawiarniaCollection = FirebaseFirestore.instance.collection('products');

  @override
  Future<List<Product>> getProducts() async {
    try {
      return await kawiarniaCollection
          .get()
          .then((value) => value.docs
              .map((e) => Product.fromEntity(ProductEntity.fromDocument(e.data())))
              .toList());
    } catch (e, stack) {
      log(e.toString(), stackTrace: stack);
      rethrow;
    }
  }
}