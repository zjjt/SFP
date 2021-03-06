class ProcessedFileModel {
  final String id;
  final String processingId;
  final List<dynamic> inFile;
  final List<dynamic> outFile;
  final String userId;
  final String configName;
  final bool processingStatus;
  final bool hasBeenExecutedOnce;
  final bool canBeRemoved;
  final DateTime lastExecution;
  final DateTime nextExecution;
  final String dateProcessed;
  final List<dynamic> fileLines;
  const ProcessedFileModel(
      {this.id,
      this.processingId,
      this.inFile,
      this.outFile,
      this.userId,
      this.configName,
      this.processingStatus,
      this.hasBeenExecutedOnce,
      this.canBeRemoved,
      this.lastExecution,
      this.nextExecution,
      this.dateProcessed,
      this.fileLines});

  ProcessedFileModel.fromJSON(Map<String, dynamic> parsedJSON)
      : processingId = parsedJSON['processingId'],
        id = parsedJSON['id'],
        inFile = parsedJSON['inFile'],
        outFile = parsedJSON['outFile'],
        userId = parsedJSON['userId'],
        configName = parsedJSON['configName'],
        processingStatus = parsedJSON['processingStatus'],
        hasBeenExecutedOnce = parsedJSON['hasBeenExecutedOnce'],
        canBeRemoved = parsedJSON['canBeRemoved'],
        lastExecution = DateTime.parse(parsedJSON['lastExecution']),
        nextExecution = DateTime.parse(parsedJSON['nextExecution']),
        dateProcessed = parsedJSON['dateProcessed'],
        fileLines = parsedJSON['fileLines'];
}
