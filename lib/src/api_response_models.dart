class APIResponseModel {
  static const String statusKey = 'status';
  static const String descriptionKey = 'description';

  final String status;
  final String description;

  const APIResponseModel({
    required this.status,
    required this.description,
  });

  factory APIResponseModel.fromJson(Map<String, dynamic> json) {
    return APIResponseModel(
      status: json[APIResponseModel.statusKey],
      description: json[APIResponseModel.descriptionKey],
    );
  }

  Map<String, dynamic> toJson() => {
    APIResponseModel.statusKey: status,
    APIResponseModel.descriptionKey: description,
  };
}