class ProcessConfigModel {
  final String id;
  final String configName;
  final String description;
  final List<dynamic> functionnalityTypes;
  final Map<String, dynamic> metaparameters;
  final List<dynamic> processingSteps;
  final Map<String, dynamic> fileTypeAndSizeInMB;

  const ProcessConfigModel({
    this.id,
    this.configName,
    this.description,
    this.functionnalityTypes,
    this.metaparameters,
    this.processingSteps,
    this.fileTypeAndSizeInMB,
  });
  ProcessConfigModel.fromJSON(Map<String, dynamic> parsedJSON)
      : id = parsedJSON['id'],
        configName = parsedJSON['configName'],
        description = parsedJSON['description'],
        functionnalityTypes = parsedJSON['functionnalityTypes'],
        metaparameters = parsedJSON['metaparameters'],
        processingSteps = parsedJSON['processingSteps'],
        fileTypeAndSizeInMB = parsedJSON['fileTypeAndSizeInMB'];
}
