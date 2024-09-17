class UserRoles {
  int id;
  int rolid;
  String userid;

  UserRoles({
    required this.id,
    required this.userid,
    required this.rolid,

  });

  factory UserRoles.fromJson(Map<String, dynamic> json) {
    return UserRoles(
      id: json['id'] ?? 0, // Proporciona un valor predeterminado si el valor es nulo
      rolid: json['rolid'] ?? 0,
      userid: json['userid'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userid': userid,
      'id': id,
      'rolid': rolid,
    };
  }

}