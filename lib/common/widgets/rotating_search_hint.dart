import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/item/controllers/campaign_controller.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/util/app_constants.dart';

class RotatingSearchHint extends StatefulWidget {
  const RotatingSearchHint({super.key});

  @override
  State<RotatingSearchHint> createState() => _RotatingSearchHintState();
}

class _RotatingSearchHintState extends State<RotatingSearchHint> {
  Timer? _typingTimer;
  Timer? _rotationTimer;
  int _currentIndex = 0;
  int _charIndex = 0;
  List<String> _itemNames = [];
  String _displayedText = '';
  bool _isTyping = true;
  String? _lastModuleType;

  @override
  void initState() {
    super.initState();
    _loadItemNames();
    _startTypingAnimation();
  }

  void _loadItemNames() {
    final splashController = Get.find<SplashController>();
    final moduleType = splashController.module?.moduleType?.toString();

    if (_lastModuleType != moduleType) {
      _lastModuleType = moduleType;
      _currentIndex = 0;
      _charIndex = 0;
      _displayedText = '';
      _isTyping = true;
    }

    List<String> names = [];

    final itemController = Get.find<ItemController>();
    final campaignController = Get.find<CampaignController>();

    if (itemController.popularItemList != null &&
        itemController.popularItemList!.isNotEmpty) {
      names.addAll(itemController.popularItemList!
          .take(5)
          .map((item) => item.name ?? '')
          .where((name) => name.isNotEmpty));
    }

    if (itemController.discountedItemList != null &&
        itemController.discountedItemList!.isNotEmpty) {
      names.addAll(itemController.discountedItemList!
          .take(5)
          .map((item) => item.name ?? '')
          .where((name) => name.isNotEmpty));
    }

    if (itemController.reviewedItemList != null &&
        itemController.reviewedItemList!.isNotEmpty) {
      names.addAll(itemController.reviewedItemList!
          .take(5)
          .map((item) => item.name ?? '')
          .where((name) => name.isNotEmpty));
    }

    if (campaignController.itemCampaignList != null &&
        campaignController.itemCampaignList!.isNotEmpty) {
      names.addAll(campaignController.itemCampaignList!
          .take(5)
          .map((item) => item.name ?? '')
          .where((name) => name.isNotEmpty));
    }

    if (names.isNotEmpty) {
      _itemNames = names.toSet().take(10).toList();
      return;
    }

    switch (moduleType) {
      case AppConstants.food:
        _itemNames = [
          'Biryani',
          'Pizza',
          'Burger',
          'Pasta',
          'Momos',
          'Noodles',
          'Thali',
          'Dosa',
          'Sandwich',
          'Fried Rice'
        ];
        break;
      case AppConstants.grocery:
        _itemNames = [
          'Milk',
          'Bread',
          'Eggs',
          'Rice',
          'Vegetables',
          'Fruits',
          'Oil',
          'Sugar',
          'Flour',
          'Butter'
        ];
        break;
      case AppConstants.pharmacy:
        _itemNames = [
          'Paracetamol',
          'Vitamins',
          'Bandage',
          'Cough Syrup',
          'Pain Relief',
          'First Aid',
          'Sanitizer',
          'Masks'
        ];
        break;
      case AppConstants.ecommerce:
        _itemNames = [
          'Electronics',
          'Clothing',
          'Shoes',
          'Watches',
          'Bags',
          'Accessories',
          'Home Decor',
          'Gadgets'
        ];
        break;
      default:
        _itemNames = ['Products', 'Items', 'Stores', 'Deals', 'Offers'];
    }
  }

  void _startTypingAnimation() {
    _typingTimer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (!mounted) return;

      if (_itemNames.isEmpty) {
        _loadItemNames();
        if (_itemNames.isEmpty) return;
      }

      final currentWord = _itemNames[_currentIndex];

      if (_isTyping) {
        if (_charIndex < currentWord.length) {
          setState(() {
            _charIndex++;
            _displayedText = currentWord.substring(0, _charIndex);
          });
        } else {
          _typingTimer?.cancel();
          _rotationTimer = Timer(const Duration(milliseconds: 1200), () {
            if (mounted) {
              _isTyping = false;
              _startTypingAnimation();
            }
          });
        }
      } else {
        if (_charIndex > 0) {
          setState(() {
            _charIndex--;
            _displayedText = currentWord.substring(0, _charIndex);
          });
        } else {
          _typingTimer?.cancel();
          setState(() {
            _currentIndex = (_currentIndex + 1) % _itemNames.length;
            _isTyping = true;
          });
          _startTypingAnimation();
        }
      }
    });
  }

  @override
  void didUpdateWidget(RotatingSearchHint oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadItemNames();
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _rotationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
      builder: (splashController) {
        final currentModuleType =
            splashController.module?.moduleType?.toString();
        if (_lastModuleType != currentModuleType) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadItemNames();
          });
        }

        if (_itemNames.isEmpty) {
          return Text('search_item_or_store'.tr);
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${'search_for'.tr} '),
            Text(
              '"$_displayedText"',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        );
      },
    );
  }
}
