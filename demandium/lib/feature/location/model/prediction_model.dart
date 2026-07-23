class PredictionModel {
  // Backward compatible field
  PlacePrediction? placePrediction;
  
  // New fields matching StackFood implementation
  String? description;
  String? id;
  int? distanceMeters;
  String? placeId;
  String? reference;
  String? place;
  List<String>? types;

  PredictionModel({
    this.placePrediction,
    this.description,
    this.id,
    this.distanceMeters,
    this.placeId,
    this.reference,
    this.place,
    this.types,
  });

  PredictionModel.fromJson(Map<String, dynamic> json) {
    // Parse nested placePrediction structure
    placePrediction = json['placePrediction'] != null
        ? PlacePrediction.fromJson(json['placePrediction'])
        : null;
    
    // Parse flat fields for easier access (StackFood pattern)
    if (json['placePrediction'] != null) {
      description = json['placePrediction']['text']?['text'];
      id = json['placePrediction']['placeId'];
      placeId = json['placePrediction']['placeId'];
      place = json['placePrediction']['place'];
      reference = json['placePrediction']['text']?['text'];
      types = json['placePrediction']['types'] != null 
          ? List<String>.from(json['placePrediction']['types']) 
          : null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (placePrediction != null) {
      data['placePrediction'] = placePrediction!.toJson();
    }
    return data;
  }
}

class PlacePrediction {
  String? placeId;
  SuggestionText? text;

  PlacePrediction({this.placeId, this.text});

  PlacePrediction.fromJson(Map<String, dynamic> json) {
    placeId = json['placeId'];
    text = json['text'] != null ? SuggestionText.fromJson(json['text']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['placeId'] = placeId;
    if (text != null) {
      data['text'] = text!.toJson();
    }
    return data;
  }
}

class SuggestionText {
  String? text;

  SuggestionText({this.text});

  SuggestionText.fromJson(Map<String, dynamic> json) {
    text = json['text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    return data;
  }
}