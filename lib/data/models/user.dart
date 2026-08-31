class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.householdId,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        householdId: json['household_id'] as int,
      );

  final int id;
  final String name;
  final String email;
  final int householdId;
}
