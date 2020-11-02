class UserModel {
  final String id;
  final String username;
  final String password;
  final String fileIdToValidate;
  final String role;
  final String creatorId;

  const UserModel(
      {this.id,
      this.username,
      this.password,
      this.role,
      this.fileIdToValidate,
      this.creatorId});

  UserModel.fromJSON(Map<String, dynamic> parsedJSON)
      : id = parsedJSON['id'],
        username = parsedJSON['username'],
        password = parsedJSON['password'],
        role = parsedJSON['role'],
        fileIdToValidate = parsedJSON['fileIdToValidate'],
        creatorId = parsedJSON['creatorId'];

  @override
  String toString() {
    return '{\tid:$id;\n\tusername:$username;\n\tpassword:$password;\n\trole:$role;\nfileIdToValidate:$fileIdToValidate\n\tcreatorId:$creatorId\n}';
  }
}
