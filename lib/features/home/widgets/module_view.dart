import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:demandium/feature/bottomNav/view/bottom_nav_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/common/widgets/item_view.dart';
import 'package:sixam_mart/common/widgets/item_widget2.dart';
import 'package:sixam_mart/common/widgets/title_widget.dart';
import 'package:sixam_mart/features/address/controllers/address_controller.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/airtime/controllers/airtime_controller.dart';
import 'package:sixam_mart/features/home/widgets/components/review_item_card_widget.dart';
import 'package:sixam_mart/features/home/widgets/popular_store_view.dart';
import 'package:sixam_mart/features/home/widgets/views/promo_code_banner_view.dart';
import 'package:sixam_mart/features/home/widgets/views/promo_code_banner_view1.dart';
import 'package:sixam_mart/features/home/widgets/views/promotional_banner_view.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/menu/screens/menu_screen.dart';
import 'package:sixam_mart/features/notification/controllers/notification_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:video_player/video_player.dart';

import '../../../common/widgets/wallet_card.dart';
import '../../../util/app_constants.dart';
import '../../banner/controllers/banner_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import 'banner_view.dart';
import 'module_page_last.dart';
import 'package:eClassify/main.dart';

class ModuleView extends StatefulWidget {
  final SplashController splashController;
  const ModuleView({super.key, required this.splashController});

  @override
  State<ModuleView> createState() => _ModuleViewState();
}

class _ModuleViewState extends State<ModuleView> {
  static const String _baseBannerPath =
      '${AppConstants.baseUrl}/public/assets/landing/module';
  static const List<String> _supportedExtensions = [
    '.jpg',
    '.png',
    '.gif',
    '.mp4',
  ];
  bool isLoggedIn = AuthHelper.isLoggedIn();

  String? _bannerUrl;
  bool _isVideo = false;
  VideoPlayerController? _videoController;
  bool _isLoading = true;
  final ScrollController _horizontalController = ScrollController();
  @override
  void initState() {
    super.initState();
    _initBanner();
  }

  @override
  void didUpdateWidget(covariant ModuleView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldUrl = oldWidget.splashController.configModel?.homeModuleBannerFullUrl;
    final newUrl = widget.splashController.configModel?.homeModuleBannerFullUrl;
    if (oldUrl != newUrl) {
      _initBanner();
    }
  }

  void _initBanner() {
    final customBanner = widget.splashController.configModel?.homeModuleBannerFullUrl;
    if (customBanner != null && customBanner.isNotEmpty && !customBanner.endsWith('img2.jpg')) {
      if (mounted) {
        setState(() {
          _bannerUrl = customBanner;
          _isVideo = customBanner.toLowerCase().endsWith('.mp4');
          _isLoading = false;
        });
      } else {
        _bannerUrl = customBanner;
        _isVideo = customBanner.toLowerCase().endsWith('.mp4');
        _isLoading = false;
      }
      if (_isVideo) {
        _initializeVideo();
      } else {
        _videoController?.dispose();
        _videoController = null;
      }
    } else {
      _videoController?.dispose();
      _videoController = null;
      _findAvailableBanner();
    }
  }

  Future<void> _findAvailableBanner() async {
    for (String ext in _supportedExtensions) {
      final url = '$_baseBannerPath$ext';
      try {
        final response = await http.head(Uri.parse(url));
        if (response.statusCode == 200) {
          if (mounted) {
            setState(() {
              _bannerUrl = url;
              _isVideo = ext == '.mp4';
              _isLoading = false;
            });
            if (_isVideo) {
              _initializeVideo();
            }
          }
          return;
        }
      } catch (_) {
        // Continue to next extension
      }
    }
    // No banner found
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _initializeVideo() async {
    _videoController?.dispose();
    _videoController = null;

    final url = _bannerUrl!;
    try {
      final directory = await getTemporaryDirectory();
      final fileName = 'cached_banner_${url.split('/').last}';
      final file = File('${directory.path}/$fileName');

      if (await file.exists()) {
        _videoController = VideoPlayerController.file(file);
      } else {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
        _downloadAndCacheVideo(url, file);
      }
    } catch (_) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
    }

    if (_videoController != null) {
      try {
        await _videoController!.initialize();
        if (mounted) {
          setState(() {});
          _videoController!.setLooping(true);
          _videoController!.setVolume(0);
          _videoController!.play();
        }
      } catch (_) {
        // Fallback or ignore
      }
    }
  }

  Future<void> _downloadAndCacheVideo(String url, File file) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
      }
    } catch (_) {
      // Ignore download failures
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Widget _buildBannerWidget() {
    if (_isLoading || _bannerUrl == null) {
      return Container(
        width: double.infinity,
        height: 130,
        color: Colors.grey.shade50,
        child: Shimmer(
          duration: const Duration(seconds: 2),
          enabled: true,
          child: Container(color: Colors.grey.shade100),
        ),
      );
    }

    if (_isVideo) {
      if (_videoController != null && _videoController!.value.isInitialized) {
        return FittedBox(
          fit: BoxFit.fitWidth,
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: _videoController!.value.size.width,
            height: _videoController!.value.size.height,
            child: VideoPlayer(_videoController!),
          ),
        );
      } else {
        // Video is loading/initializing: show a premium shimmer container
        return Container(
          width: double.infinity,
          height: 130,
          color: Colors.grey.shade50,
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: true,
            child: Container(color: Colors.grey.shade100),
          ),
        );
      }
    }

    // For jpg, png, gif - use CachedNetworkImage
    return ClipRect(
      child: CachedNetworkImage(
        imageUrl: _bannerUrl!,
        fit: BoxFit.fitWidth,
        width: double.infinity,
        alignment: Alignment.topCenter,
        placeholder: (context, url) => Container(
          width: double.infinity,
          height: 130,
          color: Colors.grey.shade50,
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: true,
            child: Container(color: Colors.grey.shade100),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: double.infinity,
          height: 130,
          color: Colors.grey.shade50,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// 🔹 LOCATION AND NOTIFICATION BAR (ADDED ON TOP)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.transparent,
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeSmall,
              vertical: Dimensions.paddingSizeSmall,
            ),
            child: Row(
              children: [
                /// 🔹 LOCATION SECTION
                Expanded(
                  child: InkWell(
                    onTap: () => Get.find<LocationController>()
                        .navigateToLocationScreen('home'),
                    child: GetBuilder<LocationController>(
                      builder: (locationController) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AuthHelper.isLoggedIn()
                                  ? AddressHelper
                                          .getUserAddressFromSharedPref()!
                                      .addressType!
                                      .tr
                                  : 'Livraison'.tr,
                              style: robotoMedium.copyWith(
                                color: const Color(0xFF000000),
                                fontSize: Dimensions.fontSizeOverLarge2,
                                fontWeight: FontWeight.w900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    AddressHelper
                                            .getUserAddressFromSharedPref()!
                                        .address!,
                                    style: robotoRegular.copyWith(
                                      color: Colors.black.withOpacity(0.8),
                                      fontSize: Dimensions.fontSizeDefault,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(
                                  Icons.expand_more,
                                  color: Colors.black.withOpacity(0.8),
                                  size: 18,
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                /// NOTIFICATION ICON
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: GetBuilder<NotificationController>(
                    builder: (notificationController) {
                      return GetBuilder<ProfileController>(
                        builder: (profileController) {
                          final bool isLoggedIn = AuthHelper.isLoggedIn();
                          final String? image = profileController
                              .userInfoModel?.userInfo?.imageFullUrl;

                          return Stack(
                            children: [
                              GestureDetector(
                                onTap: () => Get.to(MenuScreen()),
                                child: CircleAvatar(
                                  radius: 25, // 👈 size control
                                  backgroundColor: Theme.of(context).cardColor,
                                  backgroundImage: isLoggedIn &&
                                          image != null &&
                                          image.isNotEmpty
                                      ? NetworkImage(image)
                                      : null,
                                  child: (!isLoggedIn ||
                                          image == null ||
                                          image.isEmpty)
                                      ? Icon(
                                          CupertinoIcons.person,
                                          color: Theme.of(context).primaryColor,
                                          size: 26,
                                        )
                                      : null,
                                ),
                              ),

                              /// 🔴 Notification dot
                              notificationController.hasNotification
                                  ? Positioned(
                                      top: 2,
                                      right: 2,
                                      child: Container(
                                        height: 10,
                                        width: 10,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            width: 1,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                            ],
                          );
                        },
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
        /// EXISTING CONTENT (STARTING AFTER THE TOP BAR)
        Padding(
          padding: const EdgeInsets.only(top: 80), // Space for the top bar

          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBannerWidget(),
                const SizedBox(height: 10),


                GetBuilder<ProfileController>(
                  builder: (profileController) {
                    final balance =
                        profileController.userInfoModel?.walletBalance ?? 0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: WalletCard(
                        title: "OcassWallet",
                        balance: "$balance",
                      ),
                    );
                  },
                ),

                widget.splashController.moduleList != null
                    ? widget.splashController.moduleList!.isNotEmpty
                        ? Builder(
                            builder: (context) {
                              List<Widget> tiles = [];
                              if (widget.splashController.moduleList != null) {
                                for (int index = 0; index < widget.splashController.moduleList!.length; index++) {
                                  final module = widget.splashController.moduleList![index];
                                  tiles.add(Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // ===== CARD =====
                                      CustomInkWell(
                                        onTap: () async {
                                          SharedPreferences prefs = await SharedPreferences.getInstance();
                                          prefs.setInt('mid', module.id!);
                                          widget.splashController.switchModule(index, true);
                                        },
                                        radius: Dimensions.radiusExtraLarge,
                                        child: Container(
                                          width: 72,
                                          height: 72,
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.transparent,
                                          ),
                                          child: CustomImage(
                                            image: module.iconFullUrl ?? '',
                                            width: 64,
                                            height: 64,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // ===== LABEL =====
                                      SizedBox(
                                        width: 76,
                                        child: Text(
                                          module.moduleName ?? '',
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: robotoMedium.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ));
                                }
                              }

                              bool showAirtime = (widget.splashController.configModel?.airtimeStatus ?? 0) == 1;
                              bool showBillPayment = (widget.splashController.configModel?.billPaymentStatus ?? 0) == 1;

                              if (showAirtime) {
                                // ──── AIRTIME TILE ────
                                tiles.add(Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CustomInkWell(
                                      onTap: () async {
                                        Get.toNamed(RouteHelper.getAirtimeRoute());
                                      },
                                      radius: Dimensions.radiusExtraLarge,
                                      child: Container(
                                        width: 72,
                                        height: 72,
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.transparent,
                                        ),
                                        child: (widget.splashController.configModel?.airtimeLogo != null &&
                                                widget.splashController.configModel!.airtimeLogo!.isNotEmpty)
                                            ? CustomImage(
                                                image: widget.splashController.configModel?.airtimeLogoFullUrl ?? '',
                                                width: 64,
                                                height: 64,
                                                isLogo: true,
                                                fit: BoxFit.contain,
                                              )
                                            : Image.asset(
                                                'assets/image/airtime.jpeg',
                                                width: 64,
                                                height: 64,
                                                fit: BoxFit.contain,
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: 76,
                                      child: Text(
                                        widget.splashController.configModel?.airtimeName ?? 'AirTime',
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: robotoMedium.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ));
                              }

                              if (showBillPayment) {
                                // ──── BILL PAYMENT TILE ────
                                tiles.add(Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CustomInkWell(
                                      onTap: () => Get.toNamed(RouteHelper.getBillPaymentRoute()),
                                      radius: Dimensions.radiusExtraLarge,
                                      child: Container(
                                        width: 72,
                                        height: 72,
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.transparent,
                                        ),
                                        child: (widget.splashController.configModel?.billPaymentLogo != null &&
                                                widget.splashController.configModel!.billPaymentLogo!.isNotEmpty)
                                            ? CustomImage(
                                                image: widget.splashController.configModel?.billPaymentLogoFullUrl ?? '',
                                                width: 64,
                                                height: 64,
                                                isLogo: true,
                                                fit: BoxFit.contain,
                                              )
                                            : Container(
                                                decoration: const BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Color(0xFF003366),
                                                      Color(0xFF0066CC)
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                ),
                                                child: const Icon(
                                                  Icons.receipt_long_rounded,
                                                  color: Colors.white,
                                                  size: 36,
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: 76,
                                      child: Text(
                                        widget.splashController.configModel?.billPaymentName ?? 'Bill Pay',
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: robotoMedium.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ));
                              }

                              // ──── LISTING TILE ────
                              tiles.add(Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomInkWell(
                                    onTap: () async {
                                      SharedPreferences prefs = Get.find();
                                      log('entering listing with user model ${Get.find<ProfileController>().userInfoModel?.phone}');
                                      if (Get.find<ProfileController>().userInfoModel != null) {
                                        prefs.setString(
                                            'listingName',
                                            ((Get.find<ProfileController>().userInfoModel!.fName) ?? '') +
                                                " " +
                                                (Get.find<ProfileController>().userInfoModel!.lName ?? ''));
                                        prefs.setString(
                                            'listingEmail',
                                            Get.find<ProfileController>().userInfoModel!.email ?? '');
                                        prefs.setString(
                                            'listingNumber',
                                            Get.find<ProfileController>().userInfoModel!.phone ?? '');
                                      } else {
                                        SharedPreferences prefs = await SharedPreferences.getInstance();
                                        prefs.remove('listingNumber');
                                      }
                                      Get.offAll(EclassyApp());
                                    },
                                    radius: Dimensions.radiusExtraLarge,
                                    child: Container(
                                      width: 72,
                                      height: 72,
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.transparent,
                                      ),
                                      child: Image.asset(
                                        'assets/image/listing.jpeg',
                                        width: 64,
                                        height: 64,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: 76,
                                    child: Text(
                                      'Listing'.tr,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ));

                              // ──── SERVICE TILE ────
                              tiles.add(Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomInkWell(
                                    onTap: () {
                                      log('address : ${AddressHelper.getUserAddressFromSharedPref()?.toJson()}');
                                      Get.to(BottomNavScreen(
                                          pageIndex: 0,
                                          showServiceNotAvailableDialog: false));
                                    },
                                    radius: Dimensions.radiusExtraLarge,
                                    child: Container(
                                      width: 72,
                                      height: 72,
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.transparent,
                                      ),
                                      child: Image.asset(
                                        'demandium/assets/images/service.png',
                                        width: 64,
                                        height: 64,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: 76,
                                    child: Text(
                                      'Service'.tr,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ));

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 16,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                    border: Border.all(color: Colors.grey.shade100),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 4,
                                            height: 16,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).primaryColor,
                                              borderRadius: BorderRadius.circular(2),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Nos Services'.tr,
                                            style: robotoBold.copyWith(
                                              fontSize: Dimensions.fontSizeLarge,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      GridView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        padding: EdgeInsets.zero,
                                        itemCount: tiles.length,
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 4,
                                          mainAxisSpacing: 16,
                                          crossAxisSpacing: 8,
                                          childAspectRatio: 0.75,
                                        ),
                                        itemBuilder: (context, index) {
                                          return tiles[index];
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          )
                        : Center(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: Dimensions.paddingSizeSmall,
                              ),
                              child: Text('no_module_found'.tr),
                            ),
                          )
                    : ModuleShimmer(
                        isEnabled: widget.splashController.moduleList == null,
                      ),

                GetBuilder<AddressController>(
                  builder: (locationController) {
                    List<AddressModel?> addressList = [];
                    if (AuthHelper.isLoggedIn() &&
                        locationController.addressList != null) {
                      addressList = [];
                      bool contain = false;
                      if (AddressHelper.getUserAddressFromSharedPref()!.id !=
                          null) {
                        for (int index = 0;
                            index < locationController.addressList!.length;
                            index++) {
                          if (locationController.addressList![index].id ==
                              AddressHelper.getUserAddressFromSharedPref()!
                                  .id) {
                            contain = true;
                            break;
                          }
                        }
                      }
                      if (!contain) {
                        addressList.add(
                          AddressHelper.getUserAddressFromSharedPref(),
                        );
                      }
                      addressList.addAll(locationController.addressList!);
                    }
                    return (!AuthHelper.isLoggedIn() ||
                            locationController.addressList != null)
                        ? addressList.isNotEmpty
                            ? const Column(
                                children: [
                                  // const SizedBox(
                                  //     height: Dimensions.paddingSizeLarge),
                                  // Padding(
                                  //   padding: const EdgeInsets.symmetric(
                                  //       horizontal: Dimensions.paddingSizeSmall),
                                  //   child: TitleWidget(title: 'deliver_to'.tr),
                                  // ),
                                  // const SizedBox(
                                  //     height: Dimensions.paddingSizeExtraSmall),
                                  // SizedBox(
                                  //   height: 80,
                                  //   child: ListView.builder(
                                  //     physics: const BouncingScrollPhysics(),
                                  //     itemCount: addressList.length,
                                  //     scrollDirection: Axis.horizontal,
                                  //     padding: const EdgeInsets.only(
                                  //         left: Dimensions.paddingSizeSmall,
                                  //         right: Dimensions.paddingSizeSmall,
                                  //         top: Dimensions.paddingSizeExtraSmall),
                                  //     itemBuilder: (context, index) {
                                  //       return Container(
                                  //         width: 300,
                                  //         padding: const EdgeInsets.only(
                                  //             right: Dimensions.paddingSizeSmall),
                                  //         child: AddressWidget(
                                  //           address: addressList[index],
                                  //           fromAddress: false,
                                  //           onTap: () {
                                  //             if (AddressHelper
                                  //                         .getUserAddressFromSharedPref()!
                                  //                     .id !=
                                  //                 addressList[index]!.id) {
                                  //               Get.dialog(
                                  //                   const CustomLoaderWidget(),
                                  //                   barrierDismissible: false);
                                  //               Get.find<LocationController>()
                                  //                   .saveAddressAndNavigate(
                                  //                 addressList[index],
                                  //                 false,
                                  //                 null,
                                  //                 false,
                                  //                 ResponsiveHelper.isDesktop(
                                  //                     context),
                                  //               );
                                  //             }
                                  //           },
                                  //         ),
                                  //       );
                                  //     },
                                  //   ),
                                  // ),
                                ],
                              )
                            : const SizedBox()
                        : AddressShimmer(
                            isEnabled: AuthHelper.isLoggedIn() &&
                                locationController.addressList == null,
                          );
                  },
                ),
                // const PromotionalBannerView(),
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: CachedNetworkImage(
                //     imageUrl:
                //         'https://app.ocass.net/public/assets/landing/module2.jpg',
                //     fit: BoxFit.cover,
                //     width: double.infinity,
                //     placeholder: (c, s) => const SizedBox(), // almost invisible
                //   ),
                // ),

                GetBuilder<BannerController>(
                  builder: (bannerController) {
                    return const BannerView(isFeatured: true);
                  },
                ),
                isLoggedIn ? const PromoCodeBannerView() : const SizedBox(),
                const PopularStoreView(isPopular: false, isFeatured: true),
                const SizedBox(height: 30),
                // const HeaderWidget(),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ModuleShimmer extends StatelessWidget {
  final bool isEnabled;
  const ModuleShimmer({super.key, required this.isEnabled});
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: Dimensions.paddingSizeExtraSmall,
        crossAxisSpacing: Dimensions.paddingSizeExtraSmall,
        childAspectRatio: (1 / 1),
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      itemCount: 6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
            color: Theme.of(context).cardColor,
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1),
            ],
          ),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: isEnabled,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusExtraLarge,
                    ),
                    color: Colors.grey[300],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Center(
                  child: Container(
                    height: 15,
                    width: 50,
                    color: Colors.grey[300],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AddressShimmer extends StatelessWidget {
  final bool isEnabled;
  const AddressShimmer({super.key, required this.isEnabled});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: Dimensions.paddingSizeLarge),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeSmall,
          ),
          child: TitleWidget(title: 'deliver_to'.tr),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        SizedBox(
          height: 70,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: 5,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeSmall,
            ),
            itemBuilder: (context, index) {
              return Container(
                width: 300,
                padding: const EdgeInsets.only(
                  right: Dimensions.paddingSizeSmall,
                ),
                child: Container(
                  padding: EdgeInsets.all(
                    ResponsiveHelper.isDesktop(context)
                        ? Dimensions.paddingSizeDefault
                        : Dimensions.paddingSizeSmall,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: ResponsiveHelper.isDesktop(context) ? 50 : 40,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                        child: Shimmer(
                          duration: const Duration(seconds: 2),
                          enabled: isEnabled,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 15,
                                width: 100,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeExtraSmall,
                              ),
                              Container(
                                height: 10,
                                width: 150,
                                color: Colors.grey[300],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class TopCropper extends CustomClipper<Rect> {
  final double cropHeight;

  TopCropper(this.cropHeight);

  @override
  Rect getClip(Size size) {
    // Crop from top: rectangle from (0, cropHeight) to (width, height)
    return Rect.fromLTRB(0, cropHeight, size.width, size.height);
  }

  @override
  bool shouldReclip(TopCropper oldClipper) {
    return oldClipper.cropHeight != cropHeight;
  }
}
