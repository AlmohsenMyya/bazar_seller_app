import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/data/repository/profile_repo.dart';
import 'package:flutter_sixvalley_ecommerce/helper/network_info.dart';
import 'package:flutter_sixvalley_ecommerce/provider/splash_provider.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/chat/inbox_screen.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/home/home_screens.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/more/more_screen.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/notification/notification_screen.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/order/order_screen.dart';
// import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../../data/model/response/user_info_model.dart';
import '../../../data/repository/auth_repo.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/profile_provider.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({Key? key}) : super(key: key);

  @override
  DashBoardScreenState createState() => DashBoardScreenState();
}

//  edite by almohsen
class DashBoardScreenState extends State<DashBoardScreen>
    with WidgetsBindingObserver {
void beActive (BuildContext context) async{
  String ? token = await   Provider.of<AuthProvider>(context, listen: false).getUserToken();
  await Provider.of<ProfileProvider>(context, listen: false).updateIsActive(
      true,
     token);
  print("------klaus----init-------- ");
}

  @override
   didChangeAppLifecycleState(AppLifecycleState state) async {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        print("+-void v-${Provider.of<AuthProvider>(context, listen: false).getUserToken()} --void-+");
        String ? token = await   Provider.of<AuthProvider>(context, listen: false).getUserToken() ;
        print("+-void v--- $token --void-+");
        await Provider.of<ProfileProvider>(context, listen: false).updateIsActive(
            true,
            token);

        print("------klaus----resumed-------- ");

        // TODO: Handle this case.
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      print("+-void v-${Provider.of<AuthProvider>(context, listen: false).getUserToken()} --void-+");
      String ? token = await   Provider.of<AuthProvider>(context, listen: false).getUserToken() ;
      print("+-void v--- $token --void-+");
      await Provider.of<ProfileProvider>(context, listen: false).updateIsActive(
          false,
          token);

        print("------klaus----paused--------");

        // TODO: Handle this case.
        break;
    }
  }

  final PageController _pageController = PageController();
  int _pageIndex = 0;
  late List<Widget> _screens;

  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey();

  bool singleVendor = false;


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }
  @override
  void initState() {

    super.initState();

    beActive(context);
    WidgetsBinding.instance.addObserver(this);
    singleVendor = Provider.of<SplashProvider>(context, listen: false)
            .configModel!
            .businessMode ==
        "single";

    _screens = [
      const HomePage(),
      singleVendor
          ? const OrderScreen(isBacButtonExist: false)
          : const InboxScreen(isBackButtonExist: false),
      singleVendor
          ? const NotificationScreen(isBacButtonExist: false)
          : const OrderScreen(isBacButtonExist: false),
      singleVendor
          ? const MoreScreen()
          : const NotificationScreen(isBacButtonExist: false),
      singleVendor ? const SizedBox() : const MoreScreen(),
    ];

    NetworkInfo.checkConnectivity(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_pageIndex != 0) {
          _setPage(0);
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Theme.of(context).textTheme.bodyLarge!.color,
          showUnselectedLabels: true,
          currentIndex: _pageIndex,
          type: BottomNavigationBarType.fixed,
          items: _getBottomWidget(singleVendor),
          onTap: (int index) {
            _setPage(index);
          },
        ),
        body: PageView.builder(
          controller: _pageController,
          itemCount: _screens.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return _screens[index];
          },
        ),
      ),
    );
  }

  BottomNavigationBarItem _barItem(String icon, String? label, int index) {
    return BottomNavigationBarItem(
      icon: Image.asset(
        icon,
        color: index == _pageIndex
            ? Theme.of(context).primaryColor
            : Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.5),
        height: 25,
        width: 25,
      ),
      label: label,
    );
  }

  void _setPage(int pageIndex) {
    setState(() {
      _pageController.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
    });
  }

  List<BottomNavigationBarItem> _getBottomWidget(bool isSingleVendor) {
    List<BottomNavigationBarItem> list = [];

    if (!isSingleVendor) {
      list.add(_barItem(Images.homeImage, getTranslated('home', context), 0));
      list.add(
          _barItem(Images.messageImage, getTranslated('inbox', context), 1));
      list.add(
          _barItem(Images.shoppingImage, getTranslated('orders', context), 2));
      list.add(_barItem(
          Images.notification, getTranslated('notification', context), 3));
      list.add(_barItem(Images.moreImage, getTranslated('more', context), 4));
    } else {
      list.add(_barItem(Images.homeImage, getTranslated('home', context), 0));
      list.add(
          _barItem(Images.shoppingImage, getTranslated('orders', context), 1));
      list.add(_barItem(
          Images.notification, getTranslated('notification', context), 2));
      list.add(_barItem(Images.moreImage, getTranslated('more', context), 3));
    }

    return list;
  }

// edit by almohsen
// void setUserState (bool isOnLine )async {
//   UserInfoModel? user  = await Provider.of<ProfileProvider>(context, listen: false)
//       .getUserAllInfo(context);
//   AuthRepo.
//   ProfileRepo(dioClient: null, sharedPreferences: null).updateProfileIsOnline(userInfoModel, )
//
//
// }
}
