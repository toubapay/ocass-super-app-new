import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_wallet_icon.dart';
import 'package:sixam_mart/common/widgets/rotating_search_hint.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:video_player/video_player.dart';

/// Universal Module Header Widget with curved bottom
class ModuleHeaderWithBackground1 extends StatefulWidget {
  final Widget? child;
  final double? customHeight;

  const ModuleHeaderWithBackground1({
    super.key,
    this.child,
    this.customHeight,
  });

  @override
  State<ModuleHeaderWithBackground1> createState() =>
      _ModuleHeaderWithBackgroundState();
}

class _ModuleHeaderWithBackgroundState
    extends State<ModuleHeaderWithBackground1> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _videoError = false;
  String? _currentVideoUrl;

  static const String _baseUrl =
      '${AppConstants.baseUrl}/storage/app/public/app_home_images/';

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  bool _isVideoUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.mp4') ||
        lowerUrl.endsWith('.mov') ||
        lowerUrl.endsWith('.webm') ||
        lowerUrl.endsWith('.gif');
  }

  String? _getBackgroundUrl(SplashController splashController) {
    String? backgroundUrl = splashController.module?.appHomePageFullUrl;

    if (backgroundUrl == null || backgroundUrl.isEmpty) {
      String? filename = splashController.module?.appHomePage;
      if (filename != null && filename.isNotEmpty) {
        if (filename.startsWith('http://') || filename.startsWith('https://')) {
          backgroundUrl = filename;
        } else {
          backgroundUrl = _baseUrl + filename;
        }
      }
    }

    return backgroundUrl;
  }

  void _initializeVideo(String url) {
    if (_currentVideoUrl == url && _videoController != null && !_videoError)
      return;

    _currentVideoUrl = url;
    _videoError = false;
    _videoController?.dispose();

    _videoController = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
            _videoError = false;
          });
          _videoController!.setLooping(true);
          _videoController!.setVolume(0);
          _videoController!.play();
        }
      }).catchError((error) {
        debugPrint('Error initializing video: $error');
        if (mounted) {
          setState(() {
            _isVideoInitialized = false;
            _videoError = true;
          });
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(builder: (splashController) {
      String? backgroundUrl = _getBackgroundUrl(splashController);
      bool hasBackground = backgroundUrl != null && backgroundUrl.isNotEmpty;
      bool isVideo = _isVideoUrl(backgroundUrl);

      if (isVideo && hasBackground && !_videoError) {
        _initializeVideo(backgroundUrl!);
      }

      bool showVideo = isVideo &&
          _isVideoInitialized &&
          !_videoError &&
          _videoController != null;
      bool showImage = hasBackground && !isVideo && !_videoError;
      bool usePrimaryColor = !hasBackground || _videoError;
      bool hasMediaBackground = showVideo || showImage;

      return ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(hasMediaBackground ? 25 : 15),
          bottomRight: Radius.circular(hasMediaBackground ? 25 : 15),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            // color: usePrimaryColor ? Theme.of(context).primaryColor : null,
          ),
          child: Stack(
            children: [
              // Video Background
              // if (showVideo)
              //   Positioned.fill(
              //     child: FittedBox(
              //       fit: BoxFit.cover,
              //       alignment: Alignment.topCenter,
              //       child: SizedBox(
              //         width: _videoController!.value.size.width,
              //         height: _videoController!.value.size.height,
              //         child: VideoPlayer(_videoController!),
              //       ),
              //     ),
              //   ),

              // Image Background
              // if (showImage)
              //   Positioned.fill(
              //     child: CachedNetworkImage(
              //       imageUrl: backgroundUrl!,
              //       fit: BoxFit.cover,
              //       alignment: Alignment.topCenter,
              //       placeholder: (context, url) => Container(
              //         color: Theme.of(context).primaryColor,
              //       ),
              //       errorWidget: (context, url, error) => Container(
              //         color: Theme.of(context).primaryColor,
              //       ),
              //     ),
              //   ),

              // Header Content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top),

                  // App Bar Section
                  Container(
                    width: Dimensions.webMaxWidth,
                    height: Get.find<LocalizationController>().isLtr ? 80 : 90,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeSmall,
                    ),
                    child: Row(
                      children: [
                        _buildBackButton(splashController),
                        SizedBox(
                          width: _shouldShowBackButton(splashController)
                              ? Dimensions.paddingSizeSmall
                              : 0,
                        ),
                        Expanded(child: _buildLocationSection()),
                        _buildWalletIcon(),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        _buildProfileIcon(),
                      ],
                    ),
                  ),

                  // Search Bar
                  // _buildSearchBar(),

                  // SizedBox(height: usePrimaryColor ? 20 : 300),

                  if (widget.child != null) widget.child!,
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildBackButton(SplashController splashController) {
    if (!_shouldShowBackButton(splashController)) {
      return const SizedBox();
    }

    return InkWell(
      onTap: () {
        splashController.removeModule();
        Get.find<StoreController>().resetStoreData();
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(
          Icons.arrow_back,
          size: 20,
          color: Theme.of(context).textTheme.bodyLarge!.color,
        ),
      ),
    );
  }

  bool _shouldShowBackButton(SplashController splashController) {
    return splashController.module != null &&
        splashController.configModel!.module == null &&
        splashController.moduleList != null &&
        splashController.moduleList!.length != 1;
  }

  Widget _buildLocationSection() {
    return InkWell(
      onTap: () =>
          Get.find<LocationController>().navigateToLocationScreen('home'),
      child: GetBuilder<LocationController>(
        builder: (locationController) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '30 minutes',
                style: robotoBold.copyWith(
                  color: Colors.black,
                  fontSize: Dimensions.fontSizeOverLarge,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    _getHouseLabel(),
                    style: robotoMedium.copyWith(
                      color: Colors.black,
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
                  const Icon(Icons.expand_more, color: Colors.black, size: 16),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      _getShortAddress(),
                      style: robotoRegular.copyWith(
                        color: Colors.black54,
                        fontSize: Dimensions.fontSizeExtraSmall,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWalletIcon() {
    return GetBuilder<ProfileController>(
      builder: (profileController) {
        return InkWell(
          onTap: () => Get.toNamed(RouteHelper.getWalletRoute()),
          child: SizedBox(
            width: 38,
            height: 48,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: CustomWalletIcon(size: 35, color: Colors.white),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      AuthHelper.isLoggedIn() &&
                          profileController.userInfoModel != null
                          ? PriceConverter.convertPrice(
                          profileController.userInfoModel!.walletBalance ??
                              0)
                          : '₹0',
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall - 1,
                        color: const Color(0xFFFF6B35),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileIcon() {
    return InkWell(
      onTap: () => Get.toNamed(RouteHelper.getProfileRoute()),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Image.asset(
            'assets/image/profileicon.png',
            width: 32,
            height: 32,
            fit: BoxFit.contain,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding:
      const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
      child: InkWell(
        onTap: () => Get.toNamed(RouteHelper.getSearchRoute()),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Colors.white,
            border:
            Border.all(color: Colors.white.withOpacity(0.3), width: 0.2),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                vertical: Dimensions.paddingSizeSmall),
            child: Row(
              children: [
                Icon(CupertinoIcons.search,
                    size: 25, color: Theme.of(context).primaryColor),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: DefaultTextStyle(
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).hintColor,
                      ),
                      child: const RotatingSearchHint(),
                    ),
                  ),
                ),
                Icon(Icons.keyboard_voice_sharp,
                    size: 22, color: Theme.of(context).disabledColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getHouseLabel() {
    AddressModel? address = AddressHelper.getUserAddressFromSharedPref();
    if (address?.house != null && address!.house!.isNotEmpty) {
      return address.house!.toUpperCase();
    }
    if (address?.addressType != null && address!.addressType!.isNotEmpty) {
      return address.addressType!.tr.toUpperCase();
    }
    return 'HOME';
  }

  String _getShortAddress() {
    AddressModel? address = AddressHelper.getUserAddressFromSharedPref();
    if (address?.address != null && address!.address!.isNotEmpty) {
      String fullAddress = address.address!;
      if (fullAddress.length > 35) {
        return '${fullAddress.substring(0, 35)}...';
      }
      return fullAddress;
    }
    return 'Select address';
  }
}
