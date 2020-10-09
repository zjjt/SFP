class ProcessValidationModel {
  final String id;
  final String configName;
  final String initiatorId;
  final Map<String, String> validators;

  const ProcessValidationModel({
    this.id,
    this.configName,
    this.initiatorId,
    this.validators,
  });
  ProcessValidationModel.fromJSON(Map<String, dynamic> parsedJSON)
      : id = parsedJSON['id'],
        configName = parsedJSON['configName'],
        initiatorId = parsedJSON['initiatorId'],
        validators = parsedJSON['validators'];

  @override
  String toString() {
    return '{\tid:$id;\n\configName:$configName;\n\initiatorId:$initiatorId;\n\validators:$validators\n}';
  }
}
