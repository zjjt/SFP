class UserModel {
  final String id;
  final String username;
  final String password;
  final String role;
  final Map<String, dynamic> validations;

  const UserModel(
      {this.id, this.username, this.password, this.role, this.validations});
  UserModel.fromJSON(Map<String, dynamic> parsedJSON)
      : id = parsedJSON['id'],
        username = parsedJSON['username'],
        password = parsedJSON['password'],
        role = parsedJSON['role'],
        validations = parsedJSON['validations'];
  @override
  String toString() {
    return '{\tid:$id;\n\tusername:$username;\n\tpassword:$password;\n\trole:$role;\nvalidations:$validations\n}';
  }
}
