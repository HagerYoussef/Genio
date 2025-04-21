class ResetRequestModel {
  final String email;

  ResetRequestModel({required this.email});

  Map<String, dynamic> toJson() {
    return {"email": email};
  }
}
