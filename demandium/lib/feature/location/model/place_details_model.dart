class PlaceDetailsModel {
  String? responseCode;
  String? message;
  PlaceDetailsContent? content;


  PlaceDetailsModel({this.responseCode, this.message, this.content});

  PlaceDetailsModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    message = json['message'];
    content =
    json['content'] != null ? PlaceDetailsContent.fromJson(json['content']) : null;

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['response_code'] = responseCode;
    data['message'] = message;
    if (content != null) {
      data['content'] = content!.toJson();
    }
    return data;
  }
}

class PlaceDetailsContent {
  String? name;
  String? id;
  List<String>? types;
  String? formattedAddress;
  Location? location;
  DisplayName? displayName;
  List<AddressComponent>? addressComponents;

  PlaceDetailsContent({this.name, this.id, this.types, this.formattedAddress, this.location, this.displayName});

  PlaceDetailsContent.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'];
    types = json['types'].cast<String>();
    formattedAddress = json['formattedAddress'];
    location = json['location'] != null
        ? Location.fromJson(json['location'])
        : null;
    displayName = json['displayName'] != null
        ? DisplayName.fromJson(json['displayName'])
        : null;
    if (json['address_components'] != null) {
      addressComponents = <AddressComponent>[];
      json['address_components'].forEach((v) {
        addressComponents!.add(AddressComponent.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['id'] = id;
    data['types'] = types;
    data['formattedAddress'] = formattedAddress;
    if (location != null) {
      data['location'] = location!.toJson();
    }
    if (displayName != null) {
      data['displayName'] = displayName!.toJson();
    }
    if (addressComponents != null) {
      data['address_components'] =
          addressComponents!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AddressComponent {
  String? longName;
  String? shortName;
  List<String>? types;

  AddressComponent({this.longName, this.shortName, this.types});

  AddressComponent.fromJson(Map<String, dynamic> json) {
    longName = json['long_name'];
    shortName = json['short_name'];
    types = json['types'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['long_name'] = longName;
    data['short_name'] = shortName;
    data['types'] = types;
    return data;
  }
}

class Location {
  double? latitude;
  double? longitude;

  Location({this.latitude, this.longitude});

  Location.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}

class DisplayName {
  String? text;
  String? languageCode;

  DisplayName({this.text, this.languageCode});

  DisplayName.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    languageCode = json['languageCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    data['languageCode'] = languageCode;
    return data;
  }
}

