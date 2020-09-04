class ProcessConfigModel {
  final String id;
  final String configName;
  final List<dynamic> functionnalityTypes;
  final Map<String, dynamic> metaparameters;
  final List<dynamic> processingSteps;
  final Map<String, dynamic> fileTypeAndSizeInMB;

  const ProcessConfigModel({
    this.id,
    this.configName,
    this.functionnalityTypes,
    this.metaparameters,
    this.processingSteps,
    this.fileTypeAndSizeInMB,
  });
  ProcessConfigModel.fromJSON(Map<String, dynamic> parsedJSON)
      : id = parsedJSON['_id'],
        configName = parsedJSON['configName'],
        functionnalityTypes = parsedJSON['functionnalityTypes'],
        metaparameters = parsedJSON['metaparameters'],
        processingSteps = parsedJSON['processingSteps'],
        fileTypeAndSizeInMB = parsedJSON['fileTypeAndSizeInMB'];
}
