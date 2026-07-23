import 'package:demandium/feature/web_landing/model/web_landing_model.dart';
import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';

class FooterView extends StatefulWidget {
  const FooterView({super.key});

  @override
  State<FooterView> createState() => _FooterViewState();
}

class _FooterViewState extends State<FooterView> {
  final TextEditingController newsSubscriptionController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    newsSubscriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColorLight.withValues(alpha: 0.85);
    return GetBuilder<ServiceSplashController>(
      builder: (splashController) {
        ConfigModel? config = splashController.configModel;
        List<SocialMedia>? socialMediaList = config.content?.socialMedia;
        final activeSocialMediaList =
            socialMediaList?.where((item) => item.isActive ?? false).toList() ??
            [];

        bool pickedAddress =
            Get.find<ServiceLocationController>().getUserAddress() != null;
        return Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        Images.footerBg,
                      ), // Replace with your image path
                      fit: BoxFit.cover,
                      opacity: Get.isDarkMode ? 0.4 : 1,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(Dimensions.radiusSeven),
                    ),
                  ),
                ),

                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.07),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(Dimensions.radiusSeven),
                    ),
                  ),
                ),

                GetBuilder<WebLandingController>(
                  builder: (landingController) {
                    return SizedBox(
                      width: Dimensions.webMaxWidth,
                      child: Row(
                        spacing: 30,
                        children: [
                          Expanded(
                            child: Column(
                              spacing: Dimensions.paddingSizeDefault,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  config.content?.newsletterTitle
                                          ?.toUpperCase() ??
                                      "newsletter_subscription_title".tr
                                          .toUpperCase(),
                                  style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeLarge,
                                    color: Get.isDarkMode
                                        ? Colors.white
                                        : Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  config.content?.newsletterDescription ??
                                      "newsletter_subscription_subtitle".tr,
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Get.isDarkMode
                                        ? Colors.white
                                        : Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Expanded(
                            child: TextFormField(
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                              controller: newsSubscriptionController,
                              decoration: InputDecoration(
                                helperStyle: robotoRegular.copyWith(),
                                fillColor: Colors.white,
                                filled: true,
                                suffixIcon: InkWell(
                                  onTap: splashController.isLoading
                                      ? null
                                      : () async {
                                          if (newsSubscriptionController
                                              .text
                                              .isEmpty) {
                                            customSnackBar(
                                              "enter_email_address".tr,
                                              type: ToasterMessageType.info,
                                            );
                                          } else if (!GetUtils.isEmail(
                                            newsSubscriptionController.text,
                                          )) {
                                            customSnackBar(
                                              "enter_a_valid_email_address".tr,
                                              type: ToasterMessageType.info,
                                            );
                                          } else {
                                            splashController
                                                .newsLetterSubscription(
                                                  email:
                                                      newsSubscriptionController
                                                          .text,
                                                )
                                                .then((value) {
                                                  if (value.isSuccess!) {
                                                    newsSubscriptionController
                                                            .text =
                                                        "";
                                                    customSnackBar(
                                                      value.message,
                                                      type: ToasterMessageType
                                                          .success,
                                                    );
                                                  } else {
                                                    customSnackBar(
                                                      value.message,
                                                    );
                                                  }
                                                });
                                          }
                                        },

                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: Dimensions.paddingSizeTine,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: splashController.isLoading
                                            ? Theme.of(context).disabledColor
                                            : Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      width: 120,
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 5,
                                            vertical:
                                                Dimensions.paddingSizeSmall,
                                          ),
                                          child: splashController.isLoading
                                              ? Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  spacing: 8,
                                                  children: [
                                                    const SizedBox(
                                                      height: 12,
                                                      width: 12,
                                                      child:
                                                          CircularProgressIndicator(
                                                            color: Colors.white,
                                                            strokeWidth: 1.5,
                                                          ),
                                                    ),
                                                    Text(
                                                      'loading'.tr,
                                                      style: robotoRegular
                                                          .copyWith(
                                                            color: Colors.white,
                                                          ),
                                                    ),
                                                  ],
                                                )
                                              : Text(
                                                  'subscribe'.tr,
                                                  style: robotoMedium.copyWith(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                hintText: 'type_email'.tr,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 0,
                                ),
                                suffixIconConstraints: const BoxConstraints(
                                  maxHeight: 40,
                                ),
                                hintStyle: robotoRegular.copyWith(
                                  color: Theme.of(context).hintColor,
                                ),
                                alignLabelWithHint: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  borderSide: BorderSide(
                                    color: Theme.of(
                                      context,
                                    ).primaryColor.withValues(alpha: .5),
                                    width: 0.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  borderSide: BorderSide(
                                    color: Theme.of(
                                      context,
                                    ).primaryColor.withValues(alpha: .5),
                                    width: 0.5,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  borderSide: BorderSide(
                                    color: Theme.of(
                                      context,
                                    ).primaryColor.withValues(alpha: .5),
                                    width: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            Container(
              color: Theme.of(context).primaryColorDark,
              width: double.maxFinite,
              child: Center(
                child: Column(
                  children: [
                    SizedBox(
                      width: Dimensions.webMaxWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: Dimensions.paddingSizeLarge * 2,
                                ),
                                Image.asset(Images.webAppbarLogo, width: 180),
                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.asset(
                                      Images.footerAddress,
                                      width: 18,
                                    ),
                                    const SizedBox(
                                      width: Dimensions.paddingSizeSmall,
                                    ),
                                    Flexible(
                                      child: Text(
                                        Get.find<ServiceSplashController>()
                                                .configModel
                                                .content!
                                                .businessAddress ??
                                            "",
                                        style: robotoRegular.copyWith(
                                          color: color,
                                          fontSize:
                                              Dimensions.fontSizeExtraSmall,
                                          height: 1.5,
                                        ),
                                        maxLines: 2,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),

                                Container(
                                  height: 0.7,
                                  width: double.infinity,
                                  color: Colors.white.withValues(alpha: 0.3),
                                  margin: const EdgeInsets.only(
                                    bottom: 13,
                                    top: 10,
                                  ),
                                ),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'follow_us_on'.tr,
                                      style: robotoRegular.copyWith(
                                        color: color,
                                        fontSize: Dimensions.fontSizeExtraSmall,
                                        height: 1.5,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 50,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        itemCount: activeSocialMediaList.length,
                                        itemBuilder:
                                            (BuildContext context, index) {
                                              final item =
                                                  activeSocialMediaList[index];
                                              String? icon;

                                              switch (item.media) {
                                                case 'facebook':
                                                  icon = Images.facebookIcon;
                                                  break;
                                                case 'linkedin':
                                                  icon = Images.linkedinIcon;
                                                  break;
                                                case 'youtube':
                                                  icon = Images.youtubeIcon;
                                                  break;
                                                case 'twitter':
                                                  icon = Images.twitterIcon;
                                                  break;
                                                case 'instagram':
                                                  icon = Images.instagramIcon;
                                                  break;
                                                case 'pinterest':
                                                  icon = Images.pinterestIcon;
                                                  break;
                                              }

                                              return InkWell(
                                                onTap: () =>
                                                    _launchURL(item.link ?? ""),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        right: 15.0,
                                                      ),
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(6),
                                                    decoration:
                                                        const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Colors.white,
                                                        ),
                                                    child: Center(
                                                      child: Image.asset(
                                                        icon!,
                                                        height: 15,
                                                        width: 15,
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeLarge),
                          if (config.content!.appUrlAndroid != null ||
                              config.content!.appUrlIos != null)
                            Expanded(
                              flex: 4,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: Dimensions.paddingSizeLarge * 2,
                                  ),
                                  Text(
                                    'download_our_app'.tr,
                                    style: robotoRegular.copyWith(
                                      color: color,
                                      fontSize: Dimensions.fontSizeLarge,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: Dimensions.paddingSizeSmall,
                                  ),
                                  Text(
                                    'download_our_app_from_google_play_store'
                                        .tr,
                                    style: robotoRegular.copyWith(
                                      color: color,
                                      fontSize: Dimensions.fontSizeExtraSmall,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: Dimensions.paddingSizeLarge,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      if (config.content!.appUrlAndroid != null)
                                        InkWell(
                                          onTap: () {
                                            _launchURL(
                                              Get.find<
                                                    ServiceSplashController
                                                  >()
                                                  .configModel
                                                  .content!
                                                  .appUrlAndroid!,
                                            );
                                          },
                                          child: Image.asset(
                                            Images.playStoreIcon,
                                            height: 40,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      const SizedBox(
                                        width: Dimensions.paddingSizeSmall,
                                      ),
                                      if (config.content!.appUrlIos != null)
                                        InkWell(
                                          onTap: () {
                                            _launchURL(
                                              Get.find<
                                                    ServiceSplashController
                                                  >()
                                                  .configModel
                                                  .content!
                                                  .appUrlIos!,
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                            ),
                                            child: Image.asset(
                                              Images.appStoreIcon,
                                              height: 40,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: Dimensions.paddingSizeLarge,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "contact_us".tr,
                                        style: robotoMedium.copyWith(
                                          color: light.cardColor,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: Dimensions.paddingSizeSmall,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ContactUsWidget(
                                              icon: Icons.email,
                                              title:
                                                  Get.find<
                                                        ServiceSplashController
                                                      >()
                                                      .configModel
                                                      .content
                                                      ?.businessEmail ??
                                                  "",
                                            ),
                                          ),
                                          const SizedBox(
                                            width:
                                                Dimensions.paddingSizeDefault,
                                          ),
                                          Expanded(
                                            child: ContactUsWidget(
                                              icon: Icons.phone,
                                              title:
                                                  Get.find<
                                                        ServiceSplashController
                                                      >()
                                                      .configModel
                                                      .content
                                                      ?.businessPhone ??
                                                  "",
                                            ),
                                          ),
                                          const SizedBox(
                                            width: Dimensions.paddingSizeSmall,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: Dimensions.paddingSizeLarge * 2,
                                ),
                                Text(
                                  'useful_link'.tr,
                                  style: robotoRegular.copyWith(
                                    color: color,
                                    fontSize: Dimensions.fontSizeLarge,
                                  ),
                                ),
                                const SizedBox(height: 5.0),
                                Container(
                                  height: 1,
                                  width: 60,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeLarge,
                                ),
                                FooterButton(
                                  title: 'privacy_policy'.tr,
                                  route:
                                      ServiceRouteHelper.getPrivacyPolicyRoute(),
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),
                                FooterButton(
                                  title: 'terms_and_conditions'.tr,
                                  route:
                                      ServiceRouteHelper.getTermsAndConditionsRoute(),
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),
                                FooterButton(
                                  title: 'about_us'.tr,
                                  route: ServiceRouteHelper.getAboutUsRoute(),
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),
                                FooterButton(
                                  title: 'contact_us'.tr,
                                  route: ServiceRouteHelper.getSupportRoute(),
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: Dimensions.paddingSizeLarge * 2,
                                ),
                                Text(
                                  'quick_links'.tr,
                                  style: robotoRegular.copyWith(
                                    color: Colors.white,
                                    fontSize: Dimensions.fontSizeLarge,
                                  ),
                                ),
                                const SizedBox(height: 5.0),
                                Container(
                                  height: 1,
                                  width: 60,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeLarge,
                                ),
                                FooterButton(
                                  title: 'current_offers'.tr,
                                  route: pickedAddress
                                      ? ServiceRouteHelper.getOffersRoute()
                                      : ServiceRouteHelper.getPickMapRoute(
                                          ServiceRouteHelper.offers,
                                          true,
                                          'false',
                                          null,
                                          null,
                                        ),
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),
                                FooterButton(
                                  title: 'popular_services'.tr,
                                  route: pickedAddress
                                      ? ServiceRouteHelper.getSearchResultRoute(
                                          fromPage: "popular",
                                        )
                                      : ServiceRouteHelper.getPickMapRoute(
                                          ServiceRouteHelper.allServiceScreen,
                                          true,
                                          'false',
                                          null,
                                          null,
                                        ),
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),
                                FooterButton(
                                  title: 'categories'.tr,
                                  route: pickedAddress
                                      ? ServiceRouteHelper.getCategoryRoute(
                                          '',
                                          '',
                                        )
                                      : (ServiceRouteHelper.getPickMapRoute(
                                          ServiceRouteHelper.categories,
                                          true,
                                          'false',
                                          null,
                                          null,
                                        )),
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),

                                if (config.content?.providerSelfRegistration ==
                                    1)
                                  FooterButton(
                                    title: 'become_a_provider'.tr,
                                    url: true,
                                    route:
                                        '${AppConstants.baseUrl}/provider/auth/sign-up',
                                  ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: double.maxFinite,
                          color: const Color(0xff253036),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: Dimensions.paddingSizeDefault,
                            ),
                            child: Center(
                              child: Text(
                                Get.find<ServiceSplashController>()
                                        .configModel
                                        .content!
                                        .footerText ??
                                    "",
                                style: robotoRegular.copyWith(
                                  color: Colors.white,
                                  fontSize: Dimensions.fontSizeSmall,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

Future<void> _launchURL(String url) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {
    throw 'Could not launch $url';
  }
}

class ContactUsWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  const ContactUsWidget({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Flexible(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: light.cardColor.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }
}

class FooterButton extends StatelessWidget {
  final String title;
  final String route;
  final bool url;
  const FooterButton({
    super.key,
    required this.title,
    required this.route,
    this.url = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextHover(
      builder: (hovered) {
        return InkWell(
          hoverColor: Colors.transparent,
          onTap: route.isNotEmpty
              ? () async {
                  if (url) {
                    if (await canLaunchUrlString(route)) {
                      launchUrlString(
                        route,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  } else {
                    Get.toNamed(route);
                  }
                }
              : null,
          child: Text(
            title,
            style: hovered
                ? robotoRegular.copyWith(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: Dimensions.fontSizeExtraSmall,
                  )
                : robotoRegular.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: Dimensions.fontSizeExtraSmall,
                  ),
          ),
        );
      },
    );
  }
}
