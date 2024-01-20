class AppUser {
  late String name;
  late String profileURL;
  late String about;
  late String email;
  late String password;

  AppUser({
    required this.name,
    required this.email,
    required this.profileURL,
    required this.about,
    required this.password,
  });


  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'profileURL': profileURL,
      'about': about,
      'password': password,
    };
  }


  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      name: json['name'],
      email: json['email'],
      profileURL: json['profileURL'],
      about: json['about'],
      password: json['password'],
    );
  }
}
