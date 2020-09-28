class ProcessedFileModel {
  final String id;
  final List<dynamic> inFile;
  final List<dynamic> outFile;
  final String userId;
  final String configName;
  final bool processingStatus;
  final bool hasBeenExecutedOnce;
  final DateTime lastExecution;
  final DateTime nextExecution;
  final String dateProcessed;
  final List<dynamic> fileLines;
  const ProcessedFileModel(
      {this.id,
      this.inFile,
      this.outFile,
      this.userId,
      this.configName,
      this.processingStatus,
      this.hasBeenExecutedOnce,
      this.lastExecution,
      this.nextExecution,
      this.dateProcessed,
      this.fileLines});

  ProcessedFileModel.fromJSON(Map<String, dynamic> parsedJSON)
      : id = parsedJSON['id'],
        inFile = parsedJSON['inFile'],
        outFile = parsedJSON['outFile'],
        userId = parsedJSON['userId'],
        configName = parsedJSON['configName'],
        processingStatus = parsedJSON['processingStatus'],
        hasBeenExecutedOnce = parsedJSON['hasBeenExecutedOnce'],
        lastExecution = DateTime.parse(parsedJSON['lastExecution']),
        nextExecution = DateTime.parse(parsedJSON['nextExecution']),
        dateProcessed = parsedJSON['dateProcessed'],
        fileLines = parsedJSON['fileLines'];
}
