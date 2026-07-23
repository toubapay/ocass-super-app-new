import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';

class CustomPopWidget extends StatefulWidget {
  final Widget child;
  final Function()? onPopInvoked;
  final bool _canShowCloseDialog;
  final bool? isNavigationOnOnPop;

  const CustomPopWidget({
    super.key,
    required this.child,
    this.onPopInvoked,
    bool isExit = false,
    this.isNavigationOnOnPop,
  }) : _canShowCloseDialog = isExit;

  @override
  State<CustomPopWidget> createState() => _CustomPopWidgetState();
}

class _CustomPopWidgetState extends State<CustomPopWidget> {
  bool _canExit = GetPlatform.isWeb ? true : false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: ResponsiveHelper.isDesktop(context),
      onPopInvokedWithResult: (didPop, result) {
        if (widget.onPopInvoked != null) {
          widget.onPopInvoked!();

          if (widget.isNavigationOnOnPop ?? false) {
            return;
          }
        }

        if (didPop) {
          return;
        }

        if (_canShowCloseDialog()) {
          if (_canExit) {
            if (!GetPlatform.isWeb) {
              SystemNavigator.pop();
            }
          } else {
            customSnackBar(
              'back_press_again_to_exit'.tr,
              type: ToasterMessageType.info,
            );
            _canExit = true;
            Timer(const Duration(seconds: 2), () {
              _canExit = false;
            });
          }
        } else if (_canGoToInitialRoute()) {
          _goToInitialRoute(context);
        } else {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        }
      },
      child: widget.child,
    );
  }

  void _goToInitialRoute(BuildContext context) {
    Get.offAllNamed(ServiceRouteHelper.getInitialRoute());
    // if( !Navigator.canPop(context) && Get.find<ServiceLocationController>().getUserAddress() !=null && context.mounted && onPopInvoked == null){
    //   Get.offAllNamed(ServiceRouteHelper.getInitialRoute());
    // }
  }

  bool _canShowCloseDialog() =>
      !Navigator.canPop(context) && widget._canShowCloseDialog;
  bool _canGoToInitialRoute() =>
      !Navigator.canPop(context) && !widget._canShowCloseDialog;
}
