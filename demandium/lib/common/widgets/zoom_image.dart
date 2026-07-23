import 'package:demandium/common/widgets/custom_pop_widget.dart';
import 'package:demandium/util/core_export.dart';
import 'package:photo_view/photo_view.dart';


class ZoomImage extends StatefulWidget {
  final String image;
  final String imagePath;
  final String? createdAt;
  const ZoomImage({super.key, required this.image, required this.imagePath, this.createdAt})
      ;

  @override
  State<ZoomImage> createState() => _ZoomImageState();
}

class _ZoomImageState extends State<ZoomImage> {
  bool isZoomed = false;


  @override
  Widget build(BuildContext context) {


    return CustomPopWidget(
      child: Scaffold(
        appBar: isZoomed ? null : CustomAppBar(title: widget.image, subTitle: widget.createdAt, centerTitle: false,),
        endDrawer:ResponsiveHelper.isDesktop(context) ? const MenuDrawer():null,
        body: FooterBaseView(
          isScrollView: ResponsiveHelper.isDesktop(context) ? true : false,
          child: Center(
            child: SizedBox(
              width: ResponsiveHelper.isDesktop(context) ? 300 : Dimensions.webMaxWidth,
              height: ResponsiveHelper.isDesktop(context) ? 600 : MediaQuery.of(context).size.height,
              child: PhotoView(
                initialScale: PhotoViewComputedScale.contained,
      
                scaleStateChangedCallback: (value) {
                  if (value != PhotoViewScaleState.initial) {
                    isZoomed = true;
                  } else {
                    isZoomed = false;
                  }
                  setState(() {});
                },
      
                minScale: PhotoViewComputedScale.contained,
                imageProvider: NetworkImage(kIsWeb ? '${AppConstants.baseUrl}/image-proxy?url=${widget.imagePath}' : widget.imagePath),
              ),
            ),
          ),
        ),
      ),
    );
  }
}