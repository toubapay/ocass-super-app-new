
class ForgetPasswordBody {
  String? identity;
  String? identityType;
  int ? isFirebaseOtp;
  String? otp;
  int? fromUrl;

  ForgetPasswordBody({
    this.identity, this.identityType, this.otp, this.fromUrl, this.isFirebaseOtp
  });

  ForgetPasswordBody.fromJson(Map<String, dynamic> json) {
    identity = json['identity'];
    isFirebaseOtp = json['is_firebase_otp'];
    identityType = json['identity_type'];
    otp = json['otp'];
    fromUrl = json['from_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['identity'] = identity;
    data['is_firebase_otp'] = isFirebaseOtp;
    data['identity_type'] = identityType;
    data['otp'] = otp;
    data['from_url'] = fromUrl;
    return data;
  }
}