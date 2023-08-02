import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/chat/almohsen_widget/video_player.dart';

import '../../../../helper/date_converter.dart';

class MediaViewerPage extends StatefulWidget {
  final String? imageUrl;
  final String? videoUrl;
  final String? timestamp;

  MediaViewerPage({this.imageUrl, this.videoUrl, this.timestamp});

  @override
  _MediaViewerPageState createState() => _MediaViewerPageState();
}

class _MediaViewerPageState extends State<MediaViewerPage>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    _animationController.reverse();
    await Future.delayed(const Duration(milliseconds: 700));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    String dateTime = DateConverter.localDateToIsoStringAMPM(DateTime.parse( widget.timestamp?? " "));
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.blueGrey[50],
        body: Stack(
          children: [
            InteractiveViewer(
              child: Center(
                child: widget.videoUrl != null
                    ? VideoPlayerWithControls(videoUrl: widget.videoUrl!, timestamp: "",)
                    : Hero(
                  tag: widget.imageUrl!,
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrl!,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(

                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 5,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.black,
                          size: 20,
                          weight: 40,
                        ),
                        onPressed: () {
                          _animationController.reverse();
                          Future.delayed(const Duration(milliseconds: 300), () {
                            Navigator.pop(context);
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: FadeTransition(
                opacity: _animation,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dateTime,
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}