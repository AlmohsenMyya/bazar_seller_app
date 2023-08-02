import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/provider/theme_provider.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdatePage extends StatelessWidget {
  const UpdatePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Provider.of<ThemeProvider>(context).darkTheme
              ? const SizedBox()
              : SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Image.asset(Images.background, fit: BoxFit.fill),
                ),
          ListView(
            children: [
              SizedBox(
                height: height * 0.7,
                child: Column(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      child:
                          Image.asset(Images.logoImage, height: height * 0.3),
                    ),
                    Text(
                      'Time to UPDATE',
                      style: titilliumBold.copyWith(
                          fontSize: height * 0.045,
                          color: Theme.of(context).primaryColor),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Text(
                        ''' Upgrade your app for new features and improved performance. Please update now for seamless service. Thank you for your loyalty!''',
                        textAlign: TextAlign.center,
                        style: titilliumRegular.copyWith(
                          fontSize: height * 0.017,
                          height: 3, // Increase the line spacing by setting the height to 1.5
                        ),
                      ),
                    ),

                    // Text(getTranslated('UPDATE_TITLE', context)!, style: titilliumBold.copyWith(fontSize: height * 0.035), textAlign: TextAlign.center),
                    // Text(getTranslated('UPDATE_MESSAGE', context)!, textAlign: TextAlign.center, style: titilliumRegular.copyWith(fontSize: height * 0.015)),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              Column(
                children: [
                  Container(
                    height: 45,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 70, vertical: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        gradient: LinearGradient(colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor,
                        ])),
                    child: TextButton(
                      onPressed: () async {
                        // Close the current screen and launch the update URL
                        Navigator.of(context).pop();
                        String updateUrl =
                            "https://www.google.com/"; // TODO: Add the update URL here
                        await launch(updateUrl);
                      },
                      child: Text('UPDATE NOW',
                          style:
                              titilliumSemiBold.copyWith(color: Colors.white)),
                      // Text(getTranslated('UPDATE_NOW', context)!, style: titilliumSemiBold.copyWith(color: Colors.blue)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 45,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 70, vertical: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        gradient: const LinearGradient(colors: [
                          Colors.red,
                          Colors.redAccent,
                          Colors.red,
                        ])),
                    child: TextButton(
                      onPressed: () {
                        // Close the current screen and exit the app
                        if (Platform.isAndroid) {
                          SystemNavigator.pop();
                        } else if (Platform.isIOS) {
                          exit(0);
                        }
                      },
                      child: Text(' EXIT and update later ',
                          style:
                              titilliumSemiBold.copyWith(color: Colors.white)),
                      // Text(getTranslated('EXIT', context)!, style: titilliumSemiBold.copyWith(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
