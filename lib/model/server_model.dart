class ServerModel {
  String name;
  int? numberOfFile;
  DateTime timeCreate;
  ServerModel({
    required this.name,
    this.numberOfFile,
    required this.timeCreate,
  });
}
