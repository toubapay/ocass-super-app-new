import 'package:demandium/util/core_export.dart';

class CustomImage extends StatelessWidget {
  final String? image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final BoxFit? placeHolderBoxFit;
  final String? placeholder;

  const CustomImage({
    super.key,
    required this.image,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.placeHolderBoxFit,
  });

  bool _isGif(String? url) {
    if (url == null) return false;
    return url.toLowerCase().endsWith('.gif');
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = kIsWeb ? '${AppConstants.baseUrl}/image-proxy?url=$image' : image ?? '';

    // On web, use Image.network for GIFs to preserve animation
    if (kIsWeb && _isGif(imageUrl)) {
      return Image.network(
        imageUrl,
        height: height,
        width: width,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Image.asset(
            placeholder ?? Images.placeholder,
            height: height,
            width: width,
            fit: placeHolderBoxFit ?? fit,
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            placeholder ?? Images.placeholder,
            height: height,
            width: width,
            fit: placeHolderBoxFit ?? fit,
          );
        },
      );
    }

    // Use CachedNetworkImage for mobile or non-GIF images
    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: height,
      width: width,
      fit: fit,
      placeholder: (context, url) => Image.asset(
        placeholder ?? Images.placeholder,
        height: height,
        width: width,
        fit: placeHolderBoxFit ?? fit,
      ),
      errorWidget: (context, url, error) => Image.asset(
        placeholder ?? Images.placeholder,
        height: height,
        width: width,
        fit: placeHolderBoxFit ?? fit,
      ),
    );
  }
}