import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/chat/almohsen_widget/video_player.dart';
import 'package:provider/provider.dart';

import '../../../../data/model/response/message_model.dart';
import '../../../../provider/chat_provider.dart';
import '../../../../utill/custom_themes.dart';
import '../../../../utill/dimensions.dart';
import 'myVoicePlayer.dart';

class MessagReply extends StatefulWidget {

  final Function? onDelete;

  const MessagReply({Key? key,  this.onDelete})
      : super(key: key);

  @override
  State<MessagReply> createState() => _MessagState();
}

class _MessagState extends State<MessagReply> {

  // @override
  // void initState() {
  //   Provider.of<ChatProvider>(context, listen: false)
  //       .getMessageList(context, widget.id, 1);
  //
  //   super.initState();
  // }
  @override
  Widget build(BuildContext context) {
    bool isMe = Provider.of<ChatProvider>(context, listen: false).messageReply!.sentByCustomer == 1;
    String? name = Provider.of<ChatProvider>(context, listen: false)
                .userTypeIndex ==
            0
        ? Provider.of<ChatProvider>(context, listen: false).messageReply!.sellerInfo != null
            ? Provider.of<ChatProvider>(context, listen: false).messageReply!.sellerInfo?.shops![0].name
            : ''
        : " ${Provider.of<ChatProvider>(context, listen: false).messageReply!.deliveryMan!.fName} "
        "${Provider.of<ChatProvider>(context, listen: false).messageReply!.deliveryMan!.fName} ";

     return Consumer<ChatProvider>(builder: (context, chatProvider, child) {return
       Container(
         margin:EdgeInsets.only(right: 15,left: 15) ,

           decoration: BoxDecoration(
             color: Colors.white,
             borderRadius: BorderRadius.circular(20.0),
             boxShadow:  [
               BoxShadow(
                 color: Colors.grey.withOpacity(0.5),
                 spreadRadius: 5,
                 blurRadius: 7,
                 offset: Offset(0, 3), // changes position of shadow
               ),
             ],
           ),
           child: // your child widget(s) here
        Column(
        children: [
          Row(
            children: [

              SizedBox(width: 15,),
              Expanded(
                  child: Text(
                    isMe ? "me" : "$name",
                    textDirection: TextDirection.ltr,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),

              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    chatProvider.deleteReplyMessage();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.grey.withOpacity(0.1)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                    iconColor: MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 25,
                  ),
                ),
              ),
              SizedBox(width: 15,),
            ],
          ),
          const Divider(thickness: 6),
          const SizedBox(
            height: 8,
          ),

          Container(
            width: double.infinity, // Set the width to fill the screen
            height: 300, // Set the height to a fixed value
            color: Colors.grey[200],
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(11.0),
                child: Center(child:

                chatProvider.messageReply!.fileUrl != null
                    ? chatProvider.messageReply!.messageType == "audio"
                    ? VoicePlayer(
                  audioUrl: chatProvider.messageReply!.fileUrl,
                )
                    : chatProvider.messageReply!.messageType == "video"
                    ? Center(
                    child: VideoPlayerWithControls(
                      timestamp: "",
                      videoUrl: chatProvider.messageReply!.fileUrl!,
                    ))
                    : CachedNetworkImage(
                  imageUrl: chatProvider.messageReply!.fileUrl!,
                  placeholder: (context, url) =>
                      CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      Icon(Icons.error),
                )

                    : const SizedBox.shrink(),

                  ),


              ),
            ),
          ),
          chatProvider.messageReply!.message!.isNotEmpty
              ? Container(color: Colors.red,
            child: Text(
              chatProvider.messageReply!.message!,
              textAlign: TextAlign.justify,
              style: titilliumRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
              ),
            ),
          ): const SizedBox.shrink(),

          SizedBox(height: 15,)

        ],
      ),
    );});
  }
}
