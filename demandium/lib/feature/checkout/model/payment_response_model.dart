class PaymentResponseModel {
  String? responseCode;
  String? message;
  PaymentResponseModelContent? content;

  PaymentResponseModel({this.responseCode, this.message, this.content});

  PaymentResponseModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    message = json['message'];
    content =
    json['content'] != null ?  PaymentResponseModelContent.fromJson(json['content']) : null;
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

class PaymentResponseModelContent {
  String? bookingId;
  String? bookingRepeatId;
  String? newUserPhone;
  String? loginToken;

  PaymentResponseModelContent(
      {this.bookingId,
        this.bookingRepeatId,
        this.newUserPhone,
        this.loginToken});

  PaymentResponseModelContent.fromJson(Map<String, dynamic> json) {
    bookingId = json['booking_id'];
    bookingRepeatId = json['booking_repeat_id'];
    newUserPhone = json['new_user_phone'];
    loginToken = json['login_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['booking_id'] = bookingId;
    data['booking_repeat_id'] = bookingRepeatId;
    data['new_user_phone'] = newUserPhone;
    data['login_token'] = loginToken;
    return data;
  }
}
