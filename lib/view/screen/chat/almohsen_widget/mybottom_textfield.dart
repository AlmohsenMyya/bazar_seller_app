import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:audioplayers/audioplayers.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response/message_model.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/chat/almohsen_widget/message_reply_preview.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../../data/model/body/message_body.dart';
import '../../../../data/model/response/base/api_response.dart';
import '../../../../helper/api_checker.dart';
import '../../../../provider/auth_provider.dart';
import '../../../../provider/chat_provider.dart';
import '../../../../provider/splash_provider.dart';
import '../../../../utill/app_constants.dart';
import '../../../../utill/color_resources.dart';
import '../../../../utill/custom_themes.dart';
import '../../../../utill/dimensions.dart';
import 'imagePreview.dart';
import 'myVoicePlayer.dart';

class MyBottomSendField extends StatefulWidget {
  final int? id;
  final String? name;

  ScrollController scrollController = ScrollController();

  MyBottomSendField(
      {Key? key, this.id, required this.scrollController, required this.name})
      : super(key: key);

  @override
  State<MyBottomSendField> createState() => _MyBottomSendFieldState();
}

class _MyBottomSendFieldState extends State<MyBottomSendField> {
  final TextEditingController _controller = TextEditingController();

  File? myFile;
  File? audioFILYYYY;
  FocusNode focusNode = FocusNode();
  MessageBody? messageBody;
  FlutterSoundRecorder? soundRecorder;
  bool isplaying = false;
  AudioPlayer audioPlayer = AudioPlayer();
  AudioPlayer audioPlayer1 = AudioPlayer();
  bool isRecorderInt = false;
  bool isRecordering = false;
  bool isShowImojeContainer = false;

  String messageType = "text";

  @override
  void initState() {
    soundRecorder = FlutterSoundRecorder();
    openAudio();
    // Provider.of<ChatProvider>(context, listen: false)
    //     .getMessageList(context, widget.id, 1);
    super.initState();
  }

  @override
  void dispose() {
    soundRecorder!.closeRecorder();
    isRecorderInt = false;
    // TODO: implement dispose
    super.dispose();
  }

  void openAudio() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException("Recording Permission not allowed ");
    }
    await soundRecorder!.openRecorder();
    isRecorderInt = true;
  }

  @override
  Widget build(BuildContext context) {
    bool hasConnection = false;
    setState(() {
      Provider.of<SplashProvider>(context, listen: false).onOff
          ? hasConnection = true
          : hasConnection = false;
    });
    return Column(
      children: [
        Stack(alignment: Alignment.centerRight, children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 70,
                child: (!isRecordering && audioFILYYYY != null)
                    ? Card(
                        color: Theme.of(context).highlightColor,
                        shadowColor: Colors.grey[200],
                        elevation: 2,
                        margin: const EdgeInsets.fromLTRB(
                            Dimensions.paddingSizeSmall,
                            Dimensions.paddingSizeSmall,
                            80,
                            Dimensions.paddingSizeSmall),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeSmall),
                          child: Row(children: [
                            Expanded(
                              child: VoicePlayer(
                                audioFile: audioFILYYYY,
                                onDelete: () {
                                  setState(() {
                                    audioFILYYYY = null;
                                  });
                                },
                              ),
                            )
                          ]),
                        ),
                      )
                    : Card(
                        color: Theme.of(context).highlightColor,
                        shadowColor: Colors.grey[200],
                        elevation: 2,
                        margin: const EdgeInsets.fromLTRB(
                            Dimensions.paddingSizeSmall,
                            Dimensions.paddingSizeSmall,
                            80,
                            Dimensions.paddingSizeSmall),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeSmall),
                          child: Row(children: [
                            IconButton(
                                onPressed: toggalEmojiKeybourd,
                                icon: const Icon(
                                  Icons.emoji_emotions,
                                  color: Colors.grey,
                                )),

                            Expanded(
                              child: Center(
                                child: TextField(
                                  controller: _controller,
                                  onTap: hideEmoje,
                                  focusNode: focusNode,
                                  style: const TextStyle(
                                    fontFamily: 'Ubuntu',
                                    fontSize: 17,
                                  ),
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  expands: true,
                                  decoration: const InputDecoration(
                                    hintText: 'Type here...',
                                    hintStyle: TextStyle(
                                      fontFamily: 'Ubuntu',
                                      fontSize: 14,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (String newText) {
                                    if (newText.isNotEmpty &&
                                        !Provider.of<ChatProvider>(context,
                                                listen: false)
                                            .isSendButtonActive) {
                                      Provider.of<ChatProvider>(context,
                                              listen: false)
                                          .toggleSendButtonActivity();
                                    } else if (newText.isEmpty &&
                                        Provider.of<ChatProvider>(context,
                                                listen: false)
                                            .isSendButtonActive) {
                                      Provider.of<ChatProvider>(context,
                                              listen: false)
                                          .toggleSendButtonActivity();
                                    }
                                  },
                                ),
                              ),
                            ),

                            //attach_file
                            myFile == null
                                ? IconButton(
                                    icon: const Icon(Icons.attach_file),
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return SizedBox(
                                            height: 100,
                                            child: GridView.count(
                                              crossAxisCount: 4,
                                              children: [
                                                Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Container(
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: Colors.green,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: IconButton(
                                                          icon: const Icon(
                                                              Icons.camera),
                                                          onPressed: () async {
                                                            XFile? xFile =
                                                                await ImagePicker()
                                                                    .pickImage(
                                                                        source:
                                                                            ImageSource.camera ,
                                                                    imageQuality: AppConstants.imageQuality);
                                                            if (await checkFileSize(
                                                                xFile,
                                                                "image")) {
                                                              myFile = File(
                                                                  xFile!.path);
                                                              messageBody = MessageBody(
                                                                  id: widget.id,
                                                                  message:
                                                                      "${_controller.text}.",
                                                                  mediaFile:
                                                                      myFile,
                                                                  messageType:
                                                                      'image');
                                                            }
                                                            setState(() {});
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    const Text(
                                                      'Take a picture',
                                                      style: TextStyle(
                                                          fontSize: 8),
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Container(
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: Colors.blue,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: IconButton(
                                                          icon: const Icon(Icons
                                                              .photo_library),
                                                          onPressed: () async {
                                                            XFile? xFile =
                                                                await ImagePicker()
                                                                    .pickImage(
                                                                        source:
                                                                            ImageSource.gallery ,
                                                                imageQuality: AppConstants.imageQuality);
                                                            Navigator.pop(
                                                                context);

                                                            if (await checkFileSize(
                                                                xFile,
                                                                "image")) {
                                                              myFile = File(
                                                                  xFile!.path);
                                                              messageBody = MessageBody(
                                                                  id: widget.id,
                                                                  message:
                                                                      "${_controller.text}.",
                                                                  mediaFile:
                                                                      myFile,
                                                                  messageType:
                                                                      'image');
                                                            }
                                                            setState(() {});
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    const Text(
                                                      'Choose from gallery',
                                                      style: TextStyle(
                                                          fontSize: 8),
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Container(
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: Colors.red,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: IconButton(
                                                          icon: const Icon(
                                                              Icons.videocam),
                                                          onPressed: () async {
                                                            XFile? xFile =
                                                                await ImagePicker()
                                                                    .pickVideo(
                                                                        source:
                                                                            ImageSource.camera);
                                                            if (await checkFileSize(
                                                                xFile,
                                                                "video")) {
                                                              myFile = File(
                                                                  xFile!.path);
                                                              messageBody = MessageBody(
                                                                  id: widget.id,
                                                                  message:
                                                                      "${_controller.text}.",
                                                                  mediaFile:
                                                                      myFile,
                                                                  messageType:
                                                                      'video');
                                                            }

                                                            setState(() {});
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    const Text(
                                                      'Record a video',
                                                      style: TextStyle(
                                                          fontSize: 8),
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Container(
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: Colors.purple,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: IconButton(
                                                          icon: const Icon(Icons
                                                              .video_collection),
                                                          onPressed: () async {
                                                            XFile? xFile =
                                                                await ImagePicker()
                                                                    .pickVideo(
                                                                        source:
                                                                            ImageSource.gallery);
                                                            if (await checkFileSize(
                                                                xFile,
                                                                "video")) {
                                                              myFile = File(
                                                                  xFile!.path);
                                                              messageBody = MessageBody(
                                                                  id: widget.id,
                                                                  message:
                                                                      "${_controller.text}.",
                                                                  mediaFile:
                                                                      myFile,
                                                                  messageType:
                                                                      'video');
                                                              setState(() {});
                                                            }
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    const Text(
                                                      'Choose a video',
                                                      style: TextStyle(
                                                          fontSize: 8),
                                                    ),
                                                  ],
                                                ),
                                                // Add more icons as needed
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  )
                                : messageBody?.messageType == 'image'
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(right: 13.0),
                                        child: ImagePreview(
                                            imageProvider: FileImage(myFile!),
                                            show: myFile == null,
                                            onDelete: () {
                                              setState(() {
                                                myFile = null;
                                              });
                                            }),
                                      )
                                    : Padding(
                                        padding:
                                            const EdgeInsets.only(right: 13.0),
                                        child: ImagePreview(
                                            show: myFile == null,
                                            imageProvider: NetworkImage(
                                                'https://villagesonmacarthur.com/wp-content/uploads/2020/12/video-player-placeholder-very-large.png'),
                                            onDelete: () {
                                              setState(() {
                                                myFile = null;
                                              });
                                            }),
                                      ),

                            myFile == null
                                ? IconButton(
                                    icon: const Icon(Icons.camera_alt),
                                    onPressed: () async {
                                      XFile? xFile = await ImagePicker()
                                          .pickImage(
                                              source: ImageSource.camera);
                                      myFile = File(xFile!.path);
                                      messageBody = MessageBody(
                                          id: widget.id,
                                          message: "${_controller.text}.",
                                          mediaFile: myFile,
                                          messageType: 'image');
                                      setState(() {});
                                    },
                                  )
                                : const SizedBox.shrink(),
                          ]),
                        ),
                      ),
                // -----------------
              ),
            ],
          ),
          (_controller.text.isNotEmpty ||
                  myFile != null ||
                  (audioFILYYYY != null && !isRecordering))
              ? Padding(
                  padding: const EdgeInsets.only(right: 12.0, left: 3),
                  child: InkWell(
                      onTap: () async {
                        Provider.of<ChatProvider>(context, listen: false)
                            .toggleisSendingComplete(false);
                        if (myFile == null && audioFILYYYY == null) {
                          print("whyyyyyyyyy");
                          messageBody = MessageBody(
                              id: widget.id,
                              message: _controller.text,
                              messageType: 'text');
                          Provider.of<ChatProvider>(context, listen: false)
                              .sendMessage(messageBody!, context)
                              .then((response) {
                            _controller.text = '';
                            // widget.scrollController.jumpTo(widget
                            //     .scrollController.position.maxScrollExtent);
                          });

                          // widget.scrollController.jumpTo(widget
                          //     .scrollController.position.maxScrollExtent);
                          _controller.text = '';
                          myFile = null;
                          audioFILYYYY = null;
                          isRecordering = false;
                        } else {
                          _controller.text = '';
                          myFile = null;

                          audioFILYYYY = null;
                          isRecordering = false;
                          await Provider.of<ChatProvider>(context,
                                  listen: false)
                              .sendMessagequeue(messageBody!, context);
                        }
                        // chatProvider.deleteReplyMessage();
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xff25d366),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(Icons.send, color: Colors.white),
                      )),
                )
              : Padding(
                  padding: const EdgeInsets.only(right: 12.0, left: 3),
                  child: InkWell(
                    onTap: () async {
                      audioPlayer1
                          .play(AssetSource('start_recording_sound.mp3'));

                      var temprDir = await getTemporaryDirectory();
                      var path = '${temprDir.path}/flutter_sound.aac';
                      if (!isRecorderInt) {
                        return;
                      }
                      if (isRecordering) {
                        await soundRecorder!.stopRecorder();
                        audioFILYYYY = File(path);
                        messageBody = MessageBody(
                            id: widget.id,
                            mediaFile: audioFILYYYY,
                            message: "${_controller.text}.",
                            messageType: 'audio');
                      } else {
                        // Add a delay before starting the recording
                        await Future.delayed(const Duration(milliseconds: 210));
                        await soundRecorder!.startRecorder(
                          toFile: path,
                        );
                      }
                      setState(() {
                        isRecordering = !isRecordering;
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isRecordering
                            ? Colors.red
                            : const Color(0xff25d366),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: isRecordering
                          ? const Icon(Icons.stop_circle, color: Colors.white)
                          : const Icon(Icons.mic, color: Colors.white),
                    ),
                  ),
                ),
        ]),
        isShowImojeContainer
            ? SizedBox(
                height: 300,
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    setState(() {
                      _controller.text = _controller.text + emoji.emoji;
                    });
                  },
                ),
              )
            : const SizedBox.shrink()
      ],
    );
  }

  Future<bool> checkFileSize(XFile? file, String type) async {
    if (file != null) {
      // Load the image file from disk
      File inputFile = File(file.path);
      File checkFile = File(file.path);
      // Check the size of the file
      print("${checkFile.lengthSync()} file.lengthSync()");
      if (checkFile.lengthSync() > AppConstants.maxVideoSize * 1024 * 1024 && type == 'video') {
        // File is larger than 50MB, return an error response
        print('File size exceeds the limit of 50MB');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('File size exceeds the limit of 50MB'),
            duration: Duration(milliseconds: 2000),
            backgroundColor: Colors.red));
        return false;
      }
      if (checkFile.lengthSync() > AppConstants.maxImageSize * 1024 * 1024 && type == 'image') {
        // File is larger than 2MB, return an error response
        print('File size exceeds the limit of 2MB');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('File size exceeds the limit of 2MB'),
            duration: Duration(milliseconds: 2000),
            backgroundColor: Colors.red));
        return false;
      }
      return true;
    }
    return false;
  }

  void hideEmoje() {
    setState(() {
      isShowImojeContainer = false;
    });
  }

  void showEmoji() {
    setState(() {
      isShowImojeContainer = true;
    });
  }

  void toggalEmojiKeybourd() {
    if (isShowImojeContainer) {
      showKeboard();
      hideEmoje();
    } else {
      hideKeyboard();
      showEmoji();
    }
  }

  void showKeboard() {
    focusNode.requestFocus();
  }

  void hideKeyboard() {
    focusNode.unfocus();
  }
}
