import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response/message_model.dart';
import 'package:flutter_sixvalley_ecommerce/provider/chat_provider.dart';
import 'package:flutter_sixvalley_ecommerce/utill/color_resources.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/custom_app_bar.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/no_internet_screen.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/paginated_list_view.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/chat/widget/chat_shimmer.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/chat/widget/message_bubble.dart';
import 'package:provider/provider.dart';
import '../../../provider/splash_provider.dart';
import 'almohsen_widget/message_reply_preview.dart';
import 'almohsen_widget/mybottom_textfield.dart';

class ChatScreen extends StatefulWidget {
  final int? id;
  final String? name;
  final int? index;

  const ChatScreen({Key? key, this.id, this.index, required this.name})
      : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ScrollController scrollController = ScrollController();
  bool isActive1 = false;
  Message? replyMessage;

  @override
  void initState() {
    // Provider.of<ChatProvider>(context, listen: false).scrollController = scrollController;
    Provider.of<ChatProvider>(context, listen: false).clearchat();
    Provider.of<ChatProvider>(context, listen: false)
        .getMessageList(context, widget.id, 1 );
    scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    Provider.of<ChatProvider>(context, listen: false).getChatList(context, 1);
    Provider.of<ChatProvider>(context, listen: false)
        .getMessageList(context, widget.id, 1);
    if (widget.index != null) {
      if (Provider.of<ChatProvider>(context, listen: false)
              .chatList![widget.index!]
              .sellerInfo!
              .isActive ==
          '1') {
        isActive1 = true;
      } else {
        isActive1 = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasConnection = false;

    setState(() {
      Provider.of<SplashProvider>(context, listen: false).onOff
          ? hasConnection = true
          : hasConnection = false;
    });

    return Scaffold(
      backgroundColor: ColorResources.getIconBg(context),
      body: Consumer<ChatProvider>(builder: (context, chatProvider, child) {
        if (widget.index != null) {
          if (chatProvider.chatList![widget.index!].sellerInfo!.isActive ==
              '1') {
            isActive1 = true;
          } else {
            isActive1 = false;
          }
        }

        return Column(children: [
          Stack(
            children: [
              CustomAppBar(
                title: widget.name,
              ),
              Positioned(
                top: 20,
                bottom: 0,
                right: 0,
                child: IconButton(
                  onPressed: () async {
                    // print("996367749 index ${widget.index}");

                    await chatProvider.getChatList(context, 1);
                    if (widget.index != null) {
                      String? issactive = await chatProvider
                          .chatList![widget.index!].sellerInfo!.isActive;
                      print("$issactive 996367749");

                      if ((chatProvider
                              .chatList![widget.index!].sellerInfo!.isActive) ==
                          '0') {
                        setState(() {
                          isActive1 = false;
                          print(
                              "${chatProvider.chatList![widget.index!].sellerInfo!.isActive} 996367749");
                        });
                      } else if (chatProvider
                              .chatList![widget.index!].sellerInfo!.isActive ==
                          '1') {
                        setState(() {
                          isActive1 = true;
                          print(
                              "${chatProvider.chatList![widget.index!].sellerInfo!.isActive} 996367749");
                        });
                      }
                      print("onPressed is_active = $isActive1");
                    }
                  },
                  icon: Icon(
                    Icons.circle,
                    color: !isActive1 ? const Color(0xFFB0BEC5) : Colors.green,
                  ),
                ),
              ),
            ],
          ),


          Expanded(
            child: (chatProvider.messageModel?.message != null && chatProvider.messageModel!.message!.isNotEmpty) ||
                (chatProvider.oldmessageList != null &&
                    chatProvider.oldmessageList!.isNotEmpty )
                ? ListView.builder(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              itemCount:
              chatProvider.messageModel!.message!.length + chatProvider.oldmessageList!.length,
              reverse: true,
              itemBuilder: (context, index) {
                if (index < chatProvider.oldmessageList!.length) {
                  return MessageBubble(
                    color: false,
                    onleftSwip: () {},
                    message: chatProvider.oldmessageList![index],
                  );
                } else {
                  return MessageBubble(
                    color: true,
                    onleftSwip: () {},
                    message: chatProvider.messageModel!.message![
                    index - chatProvider.oldmessageList!.length],
                  );
                }
              },
            )
                : const ChatShimmer(),
          ),


          // chatProvider.isShowReplyMessage
          //     ? MessagReply()
          //     : const SizedBox.shrink(),
          // Bottom TextField
          MyBottomSendField(
            name: widget.name,
            id: widget.id,
            scrollController: scrollController,
          )
        ]);
      }),
    );
  }
}

/*

       Expanded(
                        child: (chatProvider.messageModel != null && chatProvider.messageModel!.message != null &&
                                    chatProvider
                                        .messageModel!.message!.isNotEmpty) ||
                                (chatProvider.oldmessageList != null &&
                                    chatProvider.oldmessageList!.isNotEmpty)
                            ? ListView.builder(
                                controller: scrollController,
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.all(
                                    Dimensions.paddingSizeSmall),
                                itemCount:
                                    chatProvider.messageModel!.message!.length +
                                        chatProvider.oldmessageList!.length,
                                reverse: true,
                                itemBuilder: (context, index) {
                                  if (index <
                                      chatProvider.oldmessageList!.length) {
                                    return MessageBubble(
                                      onleftSwip: () {},
                                      message:
                                          chatProvider.oldmessageList![index],
                                    );
                                  } else {
                                    return MessageBubble(
                                      onleftSwip: () {},
                                      message:
                                          chatProvider.messageModel!.message![
                                              index -
                                                  chatProvider
                                                      .oldmessageList!.length],
                                    );
                                  }
                                },
                              )
                            : const ChatShimmer(),
                      ),
 */
