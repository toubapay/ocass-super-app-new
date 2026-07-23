import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:sixam_mart/features/rental_module/custom/custom_icon_layout.dart';
import 'package:sixam_mart/util/styles.dart';

class RentTypeCard extends StatelessWidget {
  const RentTypeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(height: 63,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade100, width: 1),),
      child: Row(children: [

        const CustomIconLayout(height: 32, width: 32, icon: Icons.hourglass_empty_outlined),
        const SizedBox(width: 16),

        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Text('rent_type'.tr, style: robotoMedium.copyWith(fontSize: 12, color: Colors.black,)),
            const SizedBox(height: 5),

            Text('hourly_estimated_5hr'.tr, style: robotoRegular.copyWith(fontSize: 12, color: Colors.grey.shade800),),

          ]),
        ),

        GestureDetector(onTap: () {}, child: Icon(Icons.edit, size: 18, color: Theme.of(context).primaryColor))

      ]),
    );
  }
}
