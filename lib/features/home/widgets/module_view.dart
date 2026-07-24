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
    final primaryColor = Theme.of(context).primaryColor;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              Dimensions.paddingSizeSmall,
              Dimensions.paddingSizeSmall,
              Dimensions.paddingSizeSmall,
              Dimensions.paddingSizeLarge,
            ),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              children: [
                /// 🔹 LOCATION PILL + PROFILE
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                        onTap: () => Get.find<LocationController>().navigateToLocationScreen('home'),
                        child: GetBuilder<LocationController>(
                          builder: (locationController) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeDefault,
                                vertical: Dimensions.paddingSizeSmall,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.home_filled, color: primaryColor, size: 20),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      AuthHelper.isLoggedIn()
                                          ? AddressHelper.getUserAddressFromSharedPref()!.address!
                                          : 'Livraison'.tr,
                                      style: robotoBold.copyWith(
                                        color: Colors.black87,
                                        fontSize: Dimensions.fontSizeDefault,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.expand_more, color: Colors.black54, size: 18),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GetBuilder<NotificationController>(
                      builder: (notificationController) {
                        return GetBuilder<ProfileController>(
                          builder: (profileController) {
                            final bool isLoggedIn = AuthHelper.isLoggedIn();
                            final String? image = profileController.userInfoModel?.userInfo?.imageFullUrl;

                            return Stack(
                              children: [
                                GestureDetector(
                                  onTap: () => Get.to(MenuScreen()),
                                  child: CircleAvatar(
                                    radius: 22,
                                    backgroundColor: Colors.white,
                                    backgroundImage: isLoggedIn && image != null && image.isNotEmpty
                                        ? NetworkImage(image)
                                        : null,
                                    child: (!isLoggedIn || image == null || image.isEmpty)
                                        ? Icon(CupertinoIcons.person, color: primaryColor, size: 22)
                                        : null,
                                  ),
                                ),
                                if (notificationController.hasNotification)
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Container(
                                      height: 10,
                                      width: 10,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                        border: Border.all(width: 1, color: Colors.white),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                /// 🔹 CATEGORY GRID
                widget.splashController.moduleList != null
                    ? widget.splashController.moduleList!.isNotEmpty
                        ? Builder(
                            builder: (context) {
                              List<Widget> tiles = [];
                              for (int index = 0; index < widget.splashController.moduleList!.length; index++) {
                                final module = widget.splashController.moduleList![index];
                                tiles.add(_buildModuleTile(
                                  icon: CustomImage(image: module.iconFullUrl ?? '', width: 34, height: 34, fit: BoxFit.contain),
                                  label: module.moduleName ?? '',
                                  onTap: () async {
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    prefs.setInt('mid', module.id!);
                                    widget.splashController.switchModule(index, true);
                                  },
                                ));
                              }

                              bool showAirtime = (widget.splashController.configModel?.airtimeStatus ?? 0) == 1;
                              bool showBillPayment = (widget.splashController.configModel?.billPaymentStatus ?? 0) == 1;

                              if (showAirtime) {
                                tiles.add(_buildModuleTile(
                                  icon: (widget.splashController.configModel?.airtimeLogo != null &&
                                          widget.splashController.configModel!.airtimeLogo!.isNotEmpty)
                                      ? CustomImage(image: widget.splashController.configModel?.airtimeLogoFullUrl ?? '', width: 34, height: 34, isLogo: true, fit: BoxFit.contain)
                                      : Image.asset('assets/image/airtime.jpeg', width: 34, height: 34, fit: BoxFit.contain),
                                  label: widget.splashController.configModel?.airtimeName ?? 'AirTime',
                                  onTap: () => Get.toNamed(RouteHelper.getAirtimeRoute()),
                                ));
                              }

                              if (showBillPayment) {
                                tiles.add(_buildModuleTile(
                                  icon: (widget.splashController.configModel?.billPaymentLogo != null &&
                                          widget.splashController.configModel!.billPaymentLogo!.isNotEmpty)
                                      ? CustomImage(image: widget.splashController.configModel?.billPaymentLogoFullUrl ?? '', width: 34, height: 34, isLogo: true, fit: BoxFit.contain)
                                      : Icon(Icons.receipt_long_rounded, color: primaryColor, size: 32),
                                  label: widget.splashController.configModel?.billPaymentName ?? 'Bill Pay',
                                  onTap: () => Get.toNamed(RouteHelper.getBillPaymentRoute()),
                                ));
                              }

                              tiles.add(_buildModuleTile(
                                icon: Image.asset('assets/image/listing.jpeg', width: 34, height: 34, fit: BoxFit.contain),
                                label: 'Listing'.tr,
                                onTap: () async {
                                  SharedPreferences prefs = Get.find();
                                  log('entering listing with user model ${Get.find<ProfileController>().userInfoModel?.phone}');
                                  if (Get.find<ProfileController>().userInfoModel != null) {
                                    prefs.setString(
                                        'listingName',
                                        ((Get.find<ProfileController>().userInfoModel!.fName) ?? '') +
                                            " " +
                                            (Get.find<ProfileController>().userInfoModel!.lName ?? ''));
                                    prefs.setString('listingEmail', Get.find<ProfileController>().userInfoModel!.email ?? '');
                                    prefs.setString('listingNumber', Get.find<ProfileController>().userInfoModel!.phone ?? '');
                                  } else {
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    prefs.remove('listingNumber');
                                  }
                                },
                              ));

                              tiles.add(_buildModuleTile(
                                icon: Image.asset('demandium/assets/images/service.png', width: 34, height: 34, fit: BoxFit.contain),
                                label: 'Service'.tr,
                                onTap: () {
                                  log('address : ${AddressHelper.getUserAddressFromSharedPref()?.toJson()}');
                                  Get.to(BottomNavScreen(pageIndex: 0, showServiceNotAvailableDialog: false));
                                },
                              ));

                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemCount: tiles.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  mainAxisSpacing: Dimensions.paddingSizeDefault,
                                  crossAxisSpacing: Dimensions.paddingSizeSmall,
                                  childAspectRatio: 0.8,
                                ),
                                itemBuilder: (context, index) => tiles[index],
                              );
                            },
                          )
                        : Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                              child: Text('no_module_found'.tr, style: const TextStyle(color: Colors.white)),
                            ),
                          )
                    : ModuleShimmer(isEnabled: widget.splashController.moduleList == null),
              ],
            ),
          ),

          /// 🔹 WHITE CONTENT AREA
          Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: Dimensions.paddingSizeDefault),
                _buildBannerWidget(),
                const SizedBox(height: 10),

                GetBuilder<ProfileController>(
                  builder: (profileController) {
                    final balance = profileController.userInfoModel?.walletBalance ?? 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: WalletCard(title: "OcassWallet", balance: "$balance"),
                    );
                  },
                ),

                GetBuilder<AddressController>(
                  builder: (locationController) {
                    if (AuthHelper.isLoggedIn() && locationController.addressList == null) {
                      return AddressShimmer(isEnabled: true);
                    }
                    return const SizedBox();
                  },
                ),

                GetBuilder<BannerController>(
                  builder: (bannerController) {
                    return const BannerView(isFeatured: true);
                  },
                ),
                isLoggedIn ? const PromoCodeBannerView() : const SizedBox(),
                const PopularStoreView(isPopular: false, isFeatured: true),
                const SizedBox(height: 30),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleTile({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomInkWell(
          onTap: onTap,
          radius: Dimensions.radiusExtraLarge,
          child: Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 3)),
              ],
            ),
            child: icon,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        Container(
          constraints: const BoxConstraints(maxWidth: 78),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeExtraSmall,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
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
        crossAxisCount: 4,
        mainAxisSpacing: Dimensions.paddingSizeDefault,
        crossAxisSpacing: Dimensions.paddingSizeSmall,
        childAspectRatio: 0.8,
      ),
      padding: EdgeInsets.zero,
      itemCount: 8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Shimmer(
          duration: const Duration(seconds: 2),
          enabled: isEnabled,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Container(
                height: 15,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
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
