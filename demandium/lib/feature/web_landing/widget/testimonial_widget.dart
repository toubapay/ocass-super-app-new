import 'package:demandium/feature/web_landing/model/web_landing_model.dart';
import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';

class TestimonialWidget extends StatelessWidget {
  final WebLandingController webLandingController;
  final Map<String?, String?>? textContent;
  final PageController _pageController = PageController();

  TestimonialWidget({
    super.key,
    required this.webLandingController,
    required this.textContent,
  });

  @override
  Widget build(BuildContext context) {
    bool isLtr = Get.find<ServiceLocalizationController>().isLtr;

    return Container(
      color: Theme.of(context).hintColor.withValues(alpha: 0.07),
      height: Dimensions.webLandingTestimonialHeight,
      width: Dimensions.webMaxWidth,
      child: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: Dimensions.webMaxWidth,
          child: Column(
            children: [
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: webLandingController
                      .webLandingContent!
                      .testimonial!
                      .length,
                  itemBuilder: (context, index) {
                    Testimonial testimonial = webLandingController
                        .webLandingContent!
                        .testimonial!
                        .elementAt(index);
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 100),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  textContent?['testimonial_title'] ?? "",
                                  style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeOverLarge,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 50),

                                SizedBox(
                                  width: Dimensions.webMaxWidth / 2,
                                  child: Text(
                                    "‘ ${testimonial.review ?? ""} ʼ",
                                    style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                    ),
                                    maxLines: 5,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                Text(
                                  "- ${testimonial.name!}",
                                  style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                Dimensions.radiusSeven,
                              ),
                              child: CustomImage(
                                image: testimonial.imageFullPath ?? "",
                                height: 180,
                                width: 180,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  onPageChanged: (int index) {
                    webLandingController.setPageIndex(index);
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 120),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(),
                    Text(
                      "${webLandingController.currentPage + 1}/${webLandingController.webLandingContent!.testimonial!.length}",
                    ),

                    Row(
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(100),
                          onTap: () => webLandingController.currentPage > 0
                              ? _pageController.previousPage(
                                  duration: const Duration(seconds: 1),
                                  curve: Curves.easeInOut,
                                )
                              : null,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: webLandingController.currentPage > 0
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.white,
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: isLtr ? 7 : 0.0,
                                right: !isLtr ? 7 : 0.0,
                              ),
                              child: Icon(
                                Icons.arrow_back_ios,
                                size: 18,
                                color: webLandingController.currentPage > 0
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(100),
                          onTap: () =>
                              webLandingController.currentPage + 1 <
                                  webLandingController
                                      .webLandingContent!
                                      .testimonial!
                                      .length
                              ? _pageController.nextPage(
                                  duration: const Duration(seconds: 1),
                                  curve: Curves.easeInOut,
                                )
                              : null,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  webLandingController.currentPage + 1 <
                                      webLandingController
                                          .webLandingContent!
                                          .testimonial!
                                          .length
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.white,
                            ),
                            child: Icon(
                              size: 18,
                              Icons.arrow_forward_ios,
                              color:
                                  webLandingController.currentPage + 1 <
                                      webLandingController
                                          .webLandingContent!
                                          .testimonial!
                                          .length
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: Dimensions.paddingSizeLarge),
            ],
          ),
        ),
      ),
    );
  }
}
