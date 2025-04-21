class UserSignupModel {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String password;
  final String confirmPassword;
  final String countryCode;

  UserSignupModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.confirmPassword,
    this.countryCode = "+20",
  });

  Map<String, dynamic> toJson() {
    return {
      "firstname": firstName,
      "lastname": lastName,
      "email": email,
      "phonenumber": phoneNumber,
      "password": password,
      "confirmpassword": confirmPassword,
      "countrycode": countryCode,
    };
  }
}