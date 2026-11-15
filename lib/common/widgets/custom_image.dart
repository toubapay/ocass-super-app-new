import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sixam_mart/helper/thumb_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/images.dart';

class CustomImage extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final bool isNotification;
  final String placeholder;
  final bool isHovered;
  final Color? color;
  final Alignment alignment;
  final Color? placeholderColor;
  final bool isLogo; // New parameter for logos

  const CustomImage({
    super.key,
    required this.image,
    this.height,
    this.width,
    this.fit,
    this.isNotification = false,
    this.placeholder = '',
    this.isHovered = false,
    this.color,
    this.alignment = Alignment.center,
    this.placeholderColor,
    this.isLogo = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
// For logos: use scaleDown to never crop and maintain aspect ratio
// For other images: use the provided fit or default to scaleDown
    final BoxFit effectiveFit =
        fit ?? (isLogo ? BoxFit.scaleDown : BoxFit.scaleDown);

    return AnimatedScale(
      scale: isHovered ? 1.1 : 1.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: height ?? double.infinity,
          maxWidth: width ?? double.infinity,
        ),
        child: CachedNetworkImage(
          color: color,
          // A small WebP copy sized for the screen (see ThumbHelper); if the
          // server can't make it, the original below.
          imageUrl: kIsWeb
              ? '${AppConstants.baseUrl}/image-proxy?url=$image'
              : ThumbHelper.url(image, logicalWidth: (width != null && width!.isFinite) ? width : MediaQuery.sizeOf(context).width, pixelRatio: MediaQuery.devicePixelRatioOf(context)),
          height: height,
          width: width,
          fit: effectiveFit,
          alignment: alignment,
          placeholder: (context, url) => Container(
            constraints: BoxConstraints(
              maxHeight: height ?? double.infinity,
              maxWidth: width ?? double.infinity,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Image.asset(
                placeholder.isNotEmpty
                    ? placeholder
                    : (isNotification
                        ? Images.notificationPlaceholder
                        : Images.logowithname),
                color: placeholderColor ?? color,
              ),
            ),
          ),
          errorWidget: (context, url, error) => !kIsWeb && url != image && image.isNotEmpty
              ? CachedNetworkImage(
                  color: color,
                  imageUrl: image,
                  height: height,
                  width: width,
                  fit: effectiveFit,
                  alignment: alignment,
                  errorWidget: (context, url, error) => _placeholderBox(),
                )
              : _placeholderBox(),
        ),
      ),
    );
  }

  Widget _placeholderBox() => Container(
            constraints: BoxConstraints(
              maxHeight: height ?? double.infinity,
              maxWidth: width ?? double.infinity,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Image.asset(
                placeholder.isNotEmpty
                    ? placeholder
                    : (isNotification
                        ? Images.notificationPlaceholder
                        : Images.logowithname),
                color: placeholderColor ?? color,
              ),
            ),
          );
}
