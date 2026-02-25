abstract class ExportState {}

class ExportInitial extends ExportState {}

class ExportLoading extends ExportState {}

class ExportSuccess extends ExportState {
  final String filePath;
  ExportSuccess(this.filePath);
}

class ExportError extends ExportState {
  final String message;
  ExportError(this.message);
}
