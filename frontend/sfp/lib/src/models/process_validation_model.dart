class ProcessValidationModel {
  final String id;
  final String configName;
  final String initiatorId;
  final List<dynamic> addedFiles;
  final Map<String, dynamic> validators;
  final Map<String, dynamic> validatorMotives;

  const ProcessValidationModel({
    this.id,
    this.configName,
    this.initiatorId,
    this.addedFiles,
    this.validators,
    this.validatorMotives,
  });
  ProcessValidationModel.fromJSON(Map<String, dynamic> parsedJSON)
      : id = parsedJSON['id'],
        configName = parsedJSON['configName'],
        initiatorId = parsedJSON['initiatorId'],
        addedFiles = parsedJSON['addedFiles'],
        validators = parsedJSON['validators'],
        validatorMotives = parsedJSON['validatorMotives'];

  @override
  String toString() {
    return '{\tid:$id;\n\configName:$configName;\n\initiatorId:$initiatorId;\n\validators:$validators\n}';
  }
}
