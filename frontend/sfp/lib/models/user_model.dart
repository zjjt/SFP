class UserModel {
  final String id;
  final String username;
  final String password;
  final String role;

  const UserModel({
    this.id,
    this.username,
    this.password,
    this.role,
  });
  UserModel.fromJSON(Map<String, String> parsedJSON)
      : id = parsedJSON['_id'],
        username = parsedJSON['username'],
        password = parsedJSON['password'],
        role = parsedJSON['role'];
  @override
  String toString() {
    return '{\tid:$id;\n\tusername:$username;\n\tpassword:$password;\n\trole:$role;\n}';
  }
}
