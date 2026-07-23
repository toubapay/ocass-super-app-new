import 'package:get/get.dart';

enum BnbItem {homePage, bookings, cart, offers, more}
class BottomNavController extends GetxController implements GetxService{
  static BottomNavController get to => Get.find();

  var currentPage = BnbItem.homePage;
  void changePage(BnbItem bnbItem, {bool shouldUpdate = true}) {
    currentPage = bnbItem;

    if(shouldUpdate){
      update();
    }
  }

  int _currentMenuPageIndex = 0;
  int get currentMenuPageIndex => _currentMenuPageIndex;

  void updateMenuPageIndex(int index, {bool shouldUpdate = false}){
    _currentMenuPageIndex = index;
    if(shouldUpdate){
      update();
    }
  }
}
