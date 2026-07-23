import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';

class ProfileCardItem extends StatelessWidget {
  final String leadingIcon;
  final bool? isDarkItem;
  final String title;
  final IconData? trailingIcon;
  final Function()? onTap;
  const ProfileCardItem({
    super.key,
    this.trailingIcon = Icons.arrow_forward_ios,
    required this.title,
    required this.leadingIcon,
    this.onTap,
    this.isDarkItem = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeExtraSmall,
      ),
      child: Container(
        height: 70,
        width: Get.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          color: Theme.of(context).hoverColor,
          boxShadow: Get.find<ServiceThemeController>().darkTheme
              ? null
              : cardShadow,
        ),

        child: Center(
          child: ListTile(
            title: Row(
              children: [
                Image.asset(leadingIcon, width: Dimensions.profileImageSize),
                const SizedBox(width: Dimensions.paddingSizeDefault),
                Text(title),
              ],
            ),
            trailing: isDarkItem == false
                ? Icon(
                    trailingIcon,
                    size: Dimensions.fontSizeDefault,
                    color: Get.isDarkMode
                        ? Theme.of(context).textTheme.bodyLarge?.color
                        : Theme.of(context).colorScheme.primary,
                  )
                : GetBuilder<ServiceThemeController>(
                    builder: (themeController) {
                      return Switch(
                        value: themeController.darkTheme,
                        onChanged: (value) {
                          themeController.toggleTheme();
                        },
                      );
                    },
                  ),
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}
