import '../entities/entities.dart';

class MyUser {
  String userId;
  String email;
  String name;
  bool hasActiveCart;
  String phone;

  MyUser({
    required this.userId,
    required this.email,
    required this.name,
    required this.hasActiveCart,
    required this.phone,
  });

  static final empty = MyUser(
		userId: '', 
		email: '', 
		name: '',
    hasActiveCart: false,
    phone: ''
	);

  MyUserEntity toEntity() {
    return MyUserEntity(
      userId: userId, 
      email: email, 
      name: name,
      hasActiveCart: hasActiveCart,
      phone: phone
    );
  }

  static MyUser fromEntity(MyUserEntity entity) {
    return MyUser(
      userId: entity.userId, 
      email: entity.email, 
      name: entity.name, 
      hasActiveCart: entity.hasActiveCart,
      phone: entity.phone
    );
  }

  @override
  String toString() {
    return 'MyUser: $userId, $email, $name, $hasActiveCart, $phone';
  }
}