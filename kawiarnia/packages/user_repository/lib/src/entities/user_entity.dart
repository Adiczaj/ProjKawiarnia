class MyUserEntity {
  String userId;
  String email;
  String name;
  bool hasActiveCart;
  String phone;

  MyUserEntity({
    required this.userId,
    required this.email,
    required this.name,
    required this.hasActiveCart,
    required this.phone,
  });

  Map<String, Object?> toDocument() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'hasActiveCart': hasActiveCart,
      'phone': phone,
    };
  }

  static MyUserEntity fromDocument(Map<String, dynamic> doc) {
    return MyUserEntity(
      userId: doc['userId'], 
      email: doc['email'], 
      name: doc['name'], 
      hasActiveCart: doc['hasActiveCart'],
      phone: doc['phone']
    );
  }
}