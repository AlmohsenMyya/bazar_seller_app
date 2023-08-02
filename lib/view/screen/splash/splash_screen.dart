import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/helper/check_version/updateVersion.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/provider/auth_provider.dart';
import 'package:flutter_sixvalley_ecommerce/provider/profile_provider.dart';
import 'package:flutter_sixvalley_ecommerce/provider/splash_provider.dart';
import 'package:flutter_sixvalley_ecommerce/provider/theme_provider.dart';
import 'package:flutter_sixvalley_ecommerce/utill/color_resources.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/no_internet_screen.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/auth/auth_screen.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/dashboard/dashboard_screen.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/maintenance/maintenance_screen.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/onboarding/onboarding_screen.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/splash/widget/splash_painter.dart';
import 'package:provider/provider.dart';

import '../../../helper/check_version/check_version.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with WidgetsBindingObserver{



  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
      Provider.of<ProfileProvider>(context, listen: false).updateIsActive(
          true,
          Provider.of<AuthProvider>(context, listen: false).getUserToken());

        print("------klaus----resumed-----SplashScreen--- ");

        // TODO: Handle this case.
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      Provider.of<ProfileProvider>(context, listen: false).updateIsActive(
          true,
          Provider.of<AuthProvider>(context, listen: false).getUserToken());

        print("------klaus----paused----SplashScreen----");

        // TODO: Handle this case.
        break;
    }
  }
  final GlobalKey<ScaffoldMessengerState> _globalKey = GlobalKey();
  late StreamSubscription<ConnectivityResult> _onConnectivityChanged;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    bool firstTime = true;
    _onConnectivityChanged = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (!firstTime) {
        bool isNotConnected = result != ConnectivityResult.wifi &&
            result != ConnectivityResult.mobile;
        isNotConnected
            ? const SizedBox()
            : ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: isNotConnected ? Colors.red : Colors.green,
          duration: Duration(seconds: isNotConnected ? 6000 : 3),
          content: Text(
            isNotConnected
                ? getTranslated('no_connection', context)!
                : getTranslated('connected', context)!,
            textAlign: TextAlign.center,
          ),
        ));
        if (!isNotConnected) {
          _route();
        }
      }
      firstTime = false;
    });

    _route();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _onConnectivityChanged.cancel();
  }

  void _route() async {
    final myVersion = await getAppVersion();
    ApiClient apiClient = ApiClient();
    final newVersion = await VersionRepository(apiClient).getVersion();
    List<String> myVersionParts = myVersion.split('.');
    List<String> newVersionParts = newVersion!.split('.');
    double versionD = double.parse('${myVersionParts[0]}.${myVersionParts[1]}');
    double newVersionD = double.parse('${newVersionParts[0]}.${newVersionParts[1]}');

    if (kDebugMode) {

      print(
          "myVersion ${versionD} ************************** newVersionD ${newVersionD}");
    }
    if (myVersion == newVersion) {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (BuildContext context) => UpdatePage()));
    } else {
      Provider.of<SplashProvider>(context, listen: false)
          .initConfig(context)
          .then((bool isSuccess) {
        if (isSuccess) {
          Provider.of<SplashProvider>(context, listen: false)
              .initSharedPrefData();
          Timer(const Duration(seconds: 1), () {
            if (Provider.of<SplashProvider>(context, listen: false)
                .configModel!
                .maintenanceMode!) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) =>
                      const MaintenanceScreen()));
            } else {
              if (Provider.of<AuthProvider>(context, listen: false)
                  .isLoggedIn()) {
                Provider.of<AuthProvider>(context, listen: false)
                    .updateToken(context);
                Provider.of<ProfileProvider>(context, listen: false)
                    .getUserInfo(context);
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (BuildContext context) =>
                        const DashBoardScreen()));
              } else {
                if (Provider.of<SplashProvider>(context, listen: false)
                    .showIntro()!) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (BuildContext context) => OnBoardingScreen(
                            indicatorColor: ColorResources.grey,
                            selectedIndicatorColor:
                                Theme.of(context).primaryColor,
                          )));
                } else {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (BuildContext context) => const AuthScreen()));
                }
              }
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _globalKey,
      body: Provider.of<SplashProvider>(context).hasConnection
          ? Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Provider.of<ThemeProvider>(context).darkTheme
                      ? Colors.black
                      : ColorResources.getPrimary(context),
                  child: CustomPaint(
                    painter: SplashPainter(),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        Images.splashScreenLogo,
                        height: 250.0,
                        fit: BoxFit.scaleDown,
                        width: 250.0,
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const NoInternetOrDataScreen(
              isNoInternet: true, child: SplashScreen()),
    );
  }
}
