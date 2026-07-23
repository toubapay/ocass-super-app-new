import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/util/images.dart';

import '../../features/wallet/widgets/add_fund_dialogue_widget.dart';
import '../../helper/route_helper.dart';

class WalletCard extends StatelessWidget {
  final String title;
  final String balance;

  const WalletCard({
    super.key,
    required this.title,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    final ScrollController cardScrollController = ScrollController();
    final primaryColor = Theme.of(context).primaryColor;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor,
            primaryColor.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Get.toNamed(RouteHelper.getWalletRoute());
        },
        child: Row(
          children: [
            /// Left side (Balance)
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      Images.walletIconNew,
                      height: 24,
                      width: 24,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title.tr,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          balance,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// Right side (Actions)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _WalletActionButton(
                  imagePath: Images.plus,
                  title: "top_up",
                  onTap: () {
                    Get.dialog(
                      Dialog(
                        backgroundColor: Colors.transparent,
                        surfaceTintColor: Colors.transparent,
                        child: SizedBox(
                          width: 500,
                          child: SingleChildScrollView(
                            controller: cardScrollController,
                            child: AddFundDialogueWidget(cardScrollController: cardScrollController),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                _WalletActionButton(
                  imagePath: Images.coin,
                  title: "points",
                  onTap: () {
                    Get.toNamed(RouteHelper.getLoyaltyRoute());
                  },
                ),
                const SizedBox(width: 16),
                _WalletActionButton(
                  imagePath: Images.refer,
                  title: "refer",
                  onTap: () {
                    Get.toNamed(RouteHelper.getReferAndEarnRoute());
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletActionButton extends StatelessWidget {
  final String imagePath;
  final String title;
  final VoidCallback onTap;

  const _WalletActionButton({
    required this.imagePath,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            alignment: Alignment.center,
            child: Image.asset(
              imagePath,
              width: 18,
              height: 18,
              color: Colors.white,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title.tr,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}
