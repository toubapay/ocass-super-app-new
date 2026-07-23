
class PagesModel {
  String? responseCode;
  String? message;
  PagesContent? content;


  PagesModel({this.responseCode, this.message, this.content});

  PagesModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    message = json['message'];
    content =
    json['content'] != null ? PagesContent.fromJson(json['content']) : null;

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

class PagesContent {
  AboutUs? aboutUs;
  AboutUs? termsAndConditions;
  AboutUs? privacyPolicy;
  AboutUs? refundPolicy;
  AboutUs? returnPolicy;
  AboutUs? cancellationPolicy;
  PageImages? images;

  PagesContent({
    this.aboutUs,
    this.termsAndConditions,
    this.privacyPolicy,
    this.refundPolicy,
    this.returnPolicy,
    this.cancellationPolicy,
    this.images
  });

  PagesContent.fromJson(Map<String, dynamic> json) {
    aboutUs = json['about_us'] != null
        ? AboutUs.fromJson(json['about_us'])
        : null;
    termsAndConditions = json['terms_and_conditions'] != null
        ? AboutUs.fromJson(json['terms_and_conditions'])
        : null;
    privacyPolicy = json['privacy_policy'] != null
        ? AboutUs.fromJson(json['privacy_policy'])
        : null;
    refundPolicy = json['refund_policy'] != null
        ? AboutUs.fromJson(json['refund_policy'])
        : null;
    returnPolicy = json['return_policy'];
    cancellationPolicy = json['cancellation_policy'] != null
        ? AboutUs.fromJson(json['cancellation_policy'])
        : null;
    images  = json['images'] != null
        ? PageImages.fromJson(json['images'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (aboutUs != null) {
      data['about_us'] = aboutUs!.toJson();
    }
    if (termsAndConditions != null) {
      data['terms_and_conditions'] = termsAndConditions!.toJson();
    }
    if (privacyPolicy != null) {
      data['privacy_policy'] = privacyPolicy!.toJson();
    }
    if (refundPolicy != null) {
      data['refund_policy'] = refundPolicy!.toJson();
    }
    data['return_policy'] = returnPolicy;
    if (cancellationPolicy != null) {
      data['cancellation_policy'] = cancellationPolicy!.toJson();
    }
    return data;
  }
}

class AboutUs {
  String? id;
  String? keyName;
  String? liveValues;
  String? settingsType;
  String? mode;
  int? isActive;
  String? createdAt;
  String? updatedAt;

  AboutUs(
      {this.id,
        this.keyName,
        this.liveValues,
        this.settingsType,
        this.mode,
        this.isActive,
        this.createdAt,
        this.updatedAt});

  AboutUs.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    keyName = json['key'];
    liveValues = json['value'];
    settingsType = json['type'];
    //mode = json['mode'];
    //isActive = json['is_active'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['key_name'] = keyName;
    data['live_values'] = liveValues;
    data['settings_type'] = settingsType;
    data['mode'] = mode;
    data['is_active'] = isActive;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class PageImages {
  String? aboutUs;
  String? termsAndConditions;
  String? refundPolicy;
  String? returnPolicy;
  String? cancellationPolicy;
  String? privacyPolicy;

  PageImages(
      {this.aboutUs,
        this.termsAndConditions,
        this.refundPolicy,
        this.returnPolicy,
        this.cancellationPolicy,
        this.privacyPolicy});

  PageImages.fromJson(Map<String, dynamic> json) {
    aboutUs = json['about_us'];
    termsAndConditions = json['terms_and_conditions'];
    refundPolicy = json['refund_policy'];
    returnPolicy = json['return_policy'];
    cancellationPolicy = json['cancellation_policy'];
    privacyPolicy = json['privacy_policy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['about_us'] = aboutUs;
    data['terms_and_conditions'] = termsAndConditions;
    data['refund_policy'] = refundPolicy;
    data['return_policy'] = returnPolicy;
    data['cancellation_policy'] = cancellationPolicy;
    data['privacy_policy'] = privacyPolicy;
    return data;
  }
}
