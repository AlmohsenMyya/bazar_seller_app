import 'dart:async';
import 'dart:io';

// import 'package:_video_player/_video_player.dart';
// import 'package:_video_player/_video_player.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../helper/date_converter.dart';
import 'media_viewer_page.dart';

class VideoPlayerWithControls extends StatefulWidget {
  final String? videoUrl;
  final String? timestamp;

  final bool? toBig;

  final File? videoFile;

  const VideoPlayerWithControls(
      {Key? key,
        this.toBig,
        this.videoFile,
        this.timestamp,
        this.videoUrl})
      : super(key: key);

  @override
  _VideoPlayerWithControlsState createState() =>
      _VideoPlayerWithControlsState();
}

class _VideoPlayerWithControlsState extends State<VideoPlayerWithControls> {
  late final VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _showControls = true;
  Timer? _hideTimer;
  double _sliderValue = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.videoFile != null) {
      _controller = VideoPlayerController.file(widget.videoFile!)
        ..initialize().then((_) {
          setState(() {});
        });
    } else {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!))
        ..initialize().then((_) {
          setState(() {});
        });
    }
    _controller.addListener(() {
      setState(() {
        _isPlaying = _controller.value.isPlaying;
        _sliderValue = _controller.value.position.inSeconds.toDouble();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
    setState(() {
      _isPlaying = _controller.value.isPlaying;
    });
  }

  void _startHideTimer() {
    _hideTimer = Timer(Duration(seconds: 5), () {
      setState(() {
        _showControls = false;
      });
    });
  }

  void _cancelHideTimer() {
    if (_hideTimer != null) {
      _hideTimer!.cancel();
      _hideTimer = null;
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideTimer();
    } else {
      _cancelHideTimer();
    }
  }

  void _onTapSeek(double value) {
    final position = Duration(seconds: value.toInt());
    setState(() {
      _controller.seekTo(position);
      _sliderValue = value;
    });
  }

  Widget _buildPlayPauseButton() {
    return GestureDetector(
      onTap: _togglePlay,
      child: Icon(
        _isPlaying ? Icons.pause : Icons.play_arrow,
        color: Colors.white,
        size: 50.0,
      ),
    );
  }

  Widget _buildTimeLabel(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Text(
      '$minutes:$seconds',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12.0,
      ),
    );
  }

  Widget _buildProgressBar() {
    final position = _controller.value.position;
    final duration = _controller.value.duration;
    return Expanded(

      child: Slider(
        value: _sliderValue,
        max: duration.inSeconds.toDouble(),
        onChanged: _onTapSeek,
        activeColor: Colors.white,
        inactiveColor: Colors.grey[300],
      ),
    );
  }

  Widget _buildControlsOverlay() {
    final duration = _controller.value.duration;
    final position = _controller.value.position;
    return GestureDetector(
      onTap: _toggleControls,
      child: AnimatedOpacity(
        opacity: _showControls ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildPlayPauseButton(),
                  _buildProgressBar(),
                  Padding(
                    padding: const EdgeInsets.only(right: 0.0),
                    child: FutureBuilder<Duration?>(
                      future: _controller.position,
                      builder: (BuildContext context,
                          AsyncSnapshot<Duration?> snapshot) {
                        if (snapshot.hasData) {
                          return _buildTimeLabel(snapshot.data!);
                        } else {
                          return _buildTimeLabel(position);
                        }
                      },
                    ),
                  ),
                  widget.toBig != null && widget.toBig!
                      ? Padding(
                    padding: const EdgeInsets.only(left: 3.0, right: 3.0),
                    child: IconButton(
                      icon: const Icon(
                        Icons.fullscreen,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: () {
                        if (widget.videoFile == null){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MediaViewerPage(
                                videoUrl: widget.videoUrl,
                                timestamp: widget.timestamp,
                              ),
                            ),
                          );}
                      },
                    ),
                  )
                      : const SizedBox(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        children: [
          VideoPlayer(_controller),
          _buildControlsOverlay(),
        ],
      ),
    );
  }
}
