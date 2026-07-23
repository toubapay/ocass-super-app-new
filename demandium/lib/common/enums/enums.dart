enum SocialLoginType { google, facebook, apple}

enum LoginMedium { manual, otp, social}

enum DiscountType {general, coupon, campaign, refer}

enum SendOtpType {forgetPassword, firebase, verification}

enum EditProfileTabControllerState {generalInfo,accountIno}
enum ToasterMessageType {success, error, info}
enum RepeatBookingType {daily, weekly, custom}

enum ServiceType { all ,regular, repeat}
enum ServiceLocationType { customer, provider}




enum DataSourceEnum {client, local}
enum LocalCachesTypeEnum{all, app, web, none}
enum ApiMethodType {get, post}


enum HtmlType {
  termsAndCondition('terms-and-conditions'),
  aboutUs('about-us'),
  privacyPolicy('privacy-policy'),
  cancellationPolicy('cancellation-policy'),
  refundPolicy('refund-policy'),
  others('');

  final String value;
  const HtmlType(this.value);

  /// Convert string to enum
  static HtmlType? fromValue(String value) {
    return HtmlType.values.firstWhere(
          (type) => type.value == value,
      orElse: () => others,
    );
  }
}