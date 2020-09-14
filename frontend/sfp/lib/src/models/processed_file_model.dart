class ProcessedFileModel {
  final String id;
  final Map<String, dynamic> inFile;
  final Map<String, dynamic> outFile;
  final String userId;
  final String configName;
  final bool processingStatus;
  final String dateProcessed;
  final List<dynamic> fileLines;
  const ProcessedFileModel(
      {this.id,
      this.inFile,
      this.outFile,
      this.userId,
      this.configName,
      this.processingStatus,
      this.dateProcessed,
      this.fileLines});

  ProcessedFileModel.fromJSON(Map<String, dynamic> parsedJSON)
      : id = parsedJSON['id'],
        inFile = parsedJSON['inFile'],
        outFile = parsedJSON['outFile'],
        userId = parsedJSON['userId'],
        configName = parsedJSON['configName'],
        processingStatus = parsedJSON['processingStatus'],
        dateProcessed = parsedJSON['dateProcessed'],
        fileLines = parsedJSON['fileLines'];
}
