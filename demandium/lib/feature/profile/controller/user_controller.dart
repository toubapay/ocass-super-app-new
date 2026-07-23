import 'package:demandium/api/local/cache_response.dart';
import 'package:demandium/helper/data_sync_helper.dart';
import 'package:demandium/helper/file_validation_helper.dart';
import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';
import 'package:timeago/timeago.dart' as timeago;

class UserController extends GetxController implements GetxService {
  final UserRepo userRepo;
  UserController({required this.userRepo});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  XFile? _pickedProfileImageFile;
  XFile? get pickedProfileImageFile => _pickedProfileImageFile;

  UserInfoModel? _userInfoModel;
  UserInfoModel? get userInfoModel => _userInfoModel;

  var countryDialCode = "+880";

  final int _year = 0;
  int get year => _year;

  final int _month = 0;
  int get month => _month;

  final int _day = 0;
  int get day => _day;
  final now = DateTime.now();
  String _createdAccountAgo = '';
  String get createdAccountAgo => _createdAccountAgo;

  String _userProfileImage = '';
  String get userProfileImage => _userProfileImage;

  var editProfilePageCurrentState = EditProfileTabControllerState.generalInfo;

  UserInfoModel? setUserInfoModelData(UserInfoModel? userInfoModel) =>
      _userInfoModel = userInfoModel;

  Future<void> getUserData() async {
    await userRepo.getUserInfo(source: DataSourceEnum.client);
    getUserInfo();
    update();
  }

  Future<void> getUserInfo({bool reload = true}) async {
    if (reload || _userInfoModel == null) {
      _userInfoModel = null;
    }

    DataSyncHelper.fetchAndSyncData(
      fetchFromLocal: () =>
          userRepo.getUserInfo<CacheResponseData>(source: DataSourceEnum.local),
      fetchFromClient: () =>
          userRepo.getUserInfo(source: DataSourceEnum.client),
      onResponse: (data, source) {
        _userInfoModel = UserInfoModel.fromJson(data['content']);
        _userProfileImage = _userInfoModel?.image ?? "";
        final difference = now.difference(
          DateConverter.isoUtcStringToLocalDate(data['content']['created_at']),
        );
        _createdAccountAgo = timeago.format(now.subtract(difference));

        AddressModel? addressModel = Get.find<ServiceLocationController>()
            .getUserAddress();

        if (_userInfoModel != null &&
            (addressModel?.contactPersonNumber == "" ||
                addressModel?.contactPersonNumber == null)) {
          String? firstName;
          if (Get.find<UserController>().userInfoModel?.phone != null &&
              Get.find<UserController>().userInfoModel?.fName != null) {
            firstName = "${Get.find<UserController>().userInfoModel?.fName} ";
          }
          addressModel?.contactPersonNumber = firstName != null
              ? Get.find<UserController>().userInfoModel?.phone ?? ""
              : "";
          addressModel?.contactPersonName = firstName != null
              ? "$firstName${Get.find<UserController>().userInfoModel?.lName ?? ""}"
              : "";
          if (addressModel != null) {
            Get.find<ServiceLocationController>().saveUserAddress(addressModel);
          }
        }
        update();
      },
    );
  }

  bool showReferWelcomeDialog() {
    if (_userInfoModel != null &&
        _userInfoModel!.referredBy != null &&
        _userInfoModel!.bookingsCount != null &&
        _userInfoModel!.bookingsCount! < 1) {
      return true;
    } else {
      return false;
    }
  }

  Future removeUser() async {
    _isLoading = true;
    update();
    Response response = await userRepo.deleteUser();
    _isLoading = false;
    if (response.statusCode == 200) {
      customSnackBar('your_account_remove_successfully'.tr);
      Get.find<ServiceAuthController>().clearSharedData();
      Get.find<ServiceAuthController>().googleLogout();
      Get.find<ServiceAuthController>().signOutWithFacebook();
      Get.offAllNamed(ServiceRouteHelper.getInitialRoute());
    } else {
      Get.back();
      ApiChecker.checkApi(response);
    }
  }

  void pickProfileImage() async {
    _pickedProfileImageFile = await FileValidationHelper.validateAndPickImage(
      source: ImageSource.gallery,
    );
    update();
  }

  Future<void> removeProfileImage() async {
    _pickedProfileImageFile = null;
  }

  void updateEditProfilePage(
    EditProfileTabControllerState editProfileTabControllerState, {
    bool shouldUpdate = true,
  }) {
    editProfilePageCurrentState = editProfileTabControllerState;
    if (shouldUpdate) {
      update();
    }
  }

  Future<void> updateUserProfile({required UserInfoModel userInfoModel}) async {
    _isLoading = true;
    update();
    Response response = await userRepo.updateProfile(
      userInfoModel,
      pickedProfileImageFile,
    );

    if (response.body['response_code'] == 'default_update_200') {
      customSnackBar(
        '${response.body['response_code']}'.tr,
        type: ToasterMessageType.success,
      );
    } else {
      ApiChecker.checkApi(response);
    }
    await Get.find<UserController>().getUserInfo(reload: false);
    _isLoading = false;
    update();
  }
}
