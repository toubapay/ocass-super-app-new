import 'package:demandium/common/widgets/custom_slideup_animaiton_widget.dart';
import 'package:demandium/feature/address/widget/address_details_section.dart';
import 'package:get/get.dart';
import 'package:flutter/scheduler.dart';
import 'package:demandium/util/core_export.dart';
import 'package:demandium/feature/address/widget/contact_info_section.dart';

class AddressFormBottomSheet extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController contactPersonNameController;
  final TextEditingController contactPersonNumberController;
  final TextEditingController serviceAddressController;
  final TextEditingController houseController;
  final TextEditingController floorController;
  final TextEditingController countryController;
  final TextEditingController cityController;
  final TextEditingController zipController;
  final TextEditingController streetController;

  final FocusNode nameNode;
  final FocusNode numberNode;
  final FocusNode serviceAddressNode;
  final FocusNode houseNode;
  final FocusNode floorNode;
  final FocusNode countryNode;
  final FocusNode cityNode;
  final FocusNode zipNode;
  final FocusNode streetNode;

  final VoidCallback onSave;
  final bool isUpdate;

  // ValueNotifier to communicate extent changes to parent for map animation
  final ValueNotifier<double> bottomSheetExtent;

  const AddressFormBottomSheet({
    super.key,
    required this.formKey,
    required this.contactPersonNameController,
    required this.contactPersonNumberController,
    required this.serviceAddressController,
    required this.houseController,
    required this.floorController,
    required this.countryController,
    required this.cityController,
    required this.zipController,
    required this.streetController,
    required this.nameNode,
    required this.numberNode,
    required this.serviceAddressNode,
    required this.houseNode,
    required this.floorNode,
    required this.countryNode,
    required this.cityNode,
    required this.zipNode,
    required this.streetNode,
    required this.onSave,
    required this.isUpdate,
    required this.bottomSheetExtent, // Required parameter
  });

  @override
  State<AddressFormBottomSheet> createState() => _AddressFormBottomSheetState();
}

class _AddressFormBottomSheetState extends State<AddressFormBottomSheet> {
  final DraggableScrollableController _dragController =
      DraggableScrollableController();

  // Key to measure the visible header part
  final GlobalKey _headerKey = GlobalKey();
  final GlobalKey _bottomSheetWidgetKey = GlobalKey();
  final GlobalKey _buttonKey = GlobalKey();

  // Dynamic initial size calculation
  double _currentExtent = 0.0; // Default fallback
  double _initialChildSize = 0.1; // Default fallback
  double _minChildSize = 0.25; // Default fallback
  double _maxChildSize = 0.85; // Default fallback
  bool _isCalculated = false;

  late final List<double> _snapSizes;

  @override
  void initState() {
    super.initState();

    // Measure height after the first frame renders
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _calculateInitialHeight();
    });

    _dragController.addListener(() {
      if (_dragController.size != _currentExtent) {
        final previousExtent = _currentExtent;
        setState(() {
          _currentExtent = _dragController.size;
        });

        widget.bottomSheetExtent.value = _currentExtent;

        // Close keyboard when user minimizes the bottom sheet
        if (previousExtent > 0.4 && _currentExtent <= 0.4) {
          _closeKeyboard();
        }
      }
    });

    // Add focus listeners to all text fields to auto-expand on keyboard open
    _addFocusListeners();
  }

  void _calculateInitialHeight() {
    final RenderBox? renderBox =
        _headerKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? bottomSheetRenderBox =
        _bottomSheetWidgetKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? buttonRenderBox =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox != null &&
        bottomSheetRenderBox != null &&
        buttonRenderBox != null) {
      final screenHeight = MediaQuery.of(context).size.height;
      final headerHeight = renderBox.size.height;
      final buttonHeight = renderBox.size.height;
      final targetHeight = headerHeight + buttonHeight + 20;

      final contentHeight = bottomSheetRenderBox.size.height;

      setState(() {
        _initialChildSize = (targetHeight / screenHeight).clamp(0.15, 0.85);
        _minChildSize = _initialChildSize;

        // Calculate max size based on total content height (content + save button + handle)
        final contentBasedSize = (contentHeight / screenHeight).clamp(
          0.15,
          1.0,
        );
        // Add small buffer (0.1) to ensure content fits without being cut off
        _maxChildSize = (contentBasedSize + 0.1).clamp(0.15, 0.95);

        _snapSizes = [_minChildSize, _maxChildSize];

        Get.find<ServiceLocationController>().updateBottomSheetExtent(
          _minChildSize,
          _maxChildSize,
        );

        _isCalculated = true;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _dragController.isAttached) {
          _dragController.animateTo(
            _initialChildSize,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _addFocusListeners() {
    final focusNodes = [
      widget.serviceAddressNode,
      widget.nameNode,
      widget.numberNode,
      widget.houseNode,
      widget.floorNode,
      widget.cityNode,
      widget.countryNode,
      widget.zipNode,
      widget.streetNode,
    ];

    for (var node in focusNodes) {
      node.addListener(_onFocusChange);
    }
  }

  void _onFocusChange() {
    // Expand bottom sheet when any text field gains focus
    if (_hasFocus() && _currentExtent < 0.85) {
      _expandBottomSheet();
    }
  }

  bool _hasFocus() {
    return widget.serviceAddressNode.hasFocus ||
        widget.nameNode.hasFocus ||
        widget.numberNode.hasFocus ||
        widget.houseNode.hasFocus ||
        widget.floorNode.hasFocus ||
        widget.cityNode.hasFocus ||
        widget.countryNode.hasFocus ||
        widget.zipNode.hasFocus ||
        widget.streetNode.hasFocus;
  }

  @override
  void dispose() {
    _removeFocusListeners();
    _dragController.dispose();
    super.dispose();
  }

  void _removeFocusListeners() {
    final focusNodes = [
      widget.serviceAddressNode,
      widget.nameNode,
      widget.numberNode,
      widget.houseNode,
      widget.floorNode,
      widget.cityNode,
      widget.countryNode,
      widget.zipNode,
      widget.streetNode,
    ];

    for (var node in focusNodes) {
      node.removeListener(_onFocusChange);
    }
  }

  void _expandBottomSheet() {
    _dragController.animateTo(
      _maxChildSize,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _closeKeyboard() {
    // Unfocus all text fields to close the keyboard
    widget.serviceAddressNode.unfocus();
    widget.nameNode.unfocus();
    widget.numberNode.unfocus();
    widget.houseNode.unfocus();
    widget.floorNode.unfocus();
    widget.cityNode.unfocus();
    widget.countryNode.unfocus();
    widget.zipNode.unfocus();
    widget.streetNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading state widget while calculating dimensions
    if (!_isCalculated) {
      return _BottomSheetContentWidget(
        headerKey: _headerKey,
        bottomSheetWidgetKey: _bottomSheetWidgetKey,
        buttonKey: _buttonKey,
        formKey: widget.formKey,
        serviceAddressController: widget.serviceAddressController,
        houseController: widget.houseController,
        floorController: widget.floorController,
        cityController: widget.cityController,
        countryController: widget.countryController,
        zipController: widget.zipController,
        streetController: widget.streetController,
        serviceAddressNode: widget.serviceAddressNode,
        houseNode: widget.houseNode,
        floorNode: widget.floorNode,
        cityNode: widget.cityNode,
        countryNode: widget.countryNode,
        zipNode: widget.zipNode,
        streetNode: widget.streetNode,
        nameNode: widget.nameNode,
        contactPersonNameController: widget.contactPersonNameController,
        contactPersonNumberController: widget.contactPersonNumberController,
        numberNode: widget.numberNode,
        onSave: widget.onSave,
        isUpdate: widget.isUpdate,
        onExpandBottomSheet: _expandBottomSheet,
      );
    }

    return CustomSlideUpAnimationWidget(
      child: DraggableScrollableSheet(
        controller: _dragController,
        initialChildSize: _initialChildSize,
        minChildSize: _minChildSize,
        maxChildSize: _maxChildSize,
        snap: true,
        snapSizes: _snapSizes,
        builder: (context, scrollController) {
          return _BottomSheetContentWidget(
            headerKey: _headerKey,
            bottomSheetWidgetKey: _bottomSheetWidgetKey,
            buttonKey: _buttonKey,
            formKey: widget.formKey,
            serviceAddressController: widget.serviceAddressController,
            houseController: widget.houseController,
            floorController: widget.floorController,
            cityController: widget.cityController,
            countryController: widget.countryController,
            zipController: widget.zipController,
            streetController: widget.streetController,
            serviceAddressNode: widget.serviceAddressNode,
            houseNode: widget.houseNode,
            floorNode: widget.floorNode,
            cityNode: widget.cityNode,
            countryNode: widget.countryNode,
            zipNode: widget.zipNode,
            streetNode: widget.streetNode,
            nameNode: widget.nameNode,
            contactPersonNameController: widget.contactPersonNameController,
            contactPersonNumberController: widget.contactPersonNumberController,
            numberNode: widget.numberNode,
            onSave: widget.onSave,
            isUpdate: widget.isUpdate,
            onExpandBottomSheet: _expandBottomSheet,
            scrollController: scrollController,
          );
        },
      ),
    );
  }
}

// Extracted widget class for bottom sheet content
class _BottomSheetContentWidget extends StatelessWidget {
  final GlobalKey headerKey;
  final GlobalKey bottomSheetWidgetKey;
  final GlobalKey buttonKey;
  final GlobalKey<FormState> formKey;
  final TextEditingController serviceAddressController;
  final TextEditingController houseController;
  final TextEditingController floorController;
  final TextEditingController cityController;
  final TextEditingController countryController;
  final TextEditingController zipController;
  final TextEditingController streetController;
  final FocusNode serviceAddressNode;
  final FocusNode houseNode;
  final FocusNode floorNode;
  final FocusNode cityNode;
  final FocusNode countryNode;
  final FocusNode zipNode;
  final FocusNode streetNode;
  final FocusNode nameNode;
  final TextEditingController contactPersonNameController;
  final TextEditingController contactPersonNumberController;
  final FocusNode numberNode;
  final VoidCallback onSave;
  final bool isUpdate;
  final VoidCallback onExpandBottomSheet;
  final ScrollController? scrollController;

  const _BottomSheetContentWidget({
    required this.headerKey,
    required this.bottomSheetWidgetKey,
    required this.buttonKey,
    required this.formKey,
    required this.serviceAddressController,
    required this.houseController,
    required this.floorController,
    required this.cityController,
    required this.countryController,
    required this.zipController,
    required this.streetController,
    required this.serviceAddressNode,
    required this.houseNode,
    required this.floorNode,
    required this.cityNode,
    required this.countryNode,
    required this.zipNode,
    required this.streetNode,
    required this.nameNode,
    required this.contactPersonNameController,
    required this.contactPersonNumberController,
    required this.numberNode,
    required this.onSave,
    required this.isUpdate,
    required this.onExpandBottomSheet,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return PointerInterceptor(
      key: bottomSheetWidgetKey,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(Dimensions.radiusLarge),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Scrollable Content (including draggable handle)
              Flexible(
                child: SingleChildScrollView(
                  controller: scrollController,
                  physics: const ClampingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Draggable Handle
                      GestureDetector(
                        onTap: onExpandBottomSheet,
                        behavior: HitTestBehavior.translucent,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeDefault,
                          ),
                          child: Center(
                            child: Container(
                              height: 5,
                              width: 45,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusDefault,
                                ),
                                color: Theme.of(
                                  context,
                                ).hintColor.withValues(alpha: 0.15),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Form Content
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                        ),
                        child: GetBuilder<ServiceLocationController>(
                          builder: (locationController) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Address Details Section
                                AddressDetailsSection(
                                  headerKey: headerKey,
                                  serviceAddressController:
                                      serviceAddressController,
                                  houseController: houseController,
                                  floorController: floorController,
                                  cityController: cityController,
                                  countryController: countryController,
                                  zipController: zipController,
                                  streetController: streetController,
                                  serviceAddressNode: serviceAddressNode,
                                  houseNode: houseNode,
                                  floorNode: floorNode,
                                  cityNode: cityNode,
                                  countryNode: countryNode,
                                  zipNode: zipNode,
                                  streetNode: streetNode,
                                  nextFocus: nameNode,
                                ),

                                // Contact Info Section (shown when expanded)
                                const SizedBox(
                                  height: Dimensions.paddingSizeLarge,
                                ),

                                ContactInfoSection(
                                  nameController: contactPersonNameController,
                                  numberController:
                                      contactPersonNumberController,
                                  nameNode: nameNode,
                                  numberNode: numberNode,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Fixed Save Button at Bottom
              GetBuilder<ServiceLocationController>(
                builder: (locationController) {
                  return Container(
                    key: buttonKey,
                    padding: EdgeInsets.only(
                      left: Dimensions.paddingSizeDefault,
                      right: Dimensions.paddingSizeDefault,
                      bottom: bottomPadding + Dimensions.paddingSizeDefault,
                      top: Dimensions.paddingSizeDefault,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: CustomButton(
                      radius: Dimensions.radiusSmall,
                      fontSize: Dimensions.fontSizeLarge,
                      buttonText: isUpdate
                          ? 'update_address'.tr
                          : 'save_location'.tr,
                      isLoading: locationController.isLoading,
                      onPressed:
                          (locationController.buttonDisabled ||
                              locationController.loading)
                          ? null
                          : () {
                              if (!(formKey.currentState?.validate() ??
                                  false)) {
                                onExpandBottomSheet();
                              }
                              onSave();
                            },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
