// import 'package:flutter/material.dart';
// import 'package:flutter_sixvalley_ecommerce/data/model/response/message_model.dart';
// import 'package:flutter_sixvalley_ecommerce/provider/chat_provider.dart';
// import 'package:flutter_sixvalley_ecommerce/utill/color_resources.dart';
// import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
// import 'package:flutter_sixvalley_ecommerce/view/basewidget/custom_app_bar.dart';
// import 'package:flutter_sixvalley_ecommerce/view/basewidget/no_internet_screen.dart';
// import 'package:flutter_sixvalley_ecommerce/view/basewidget/paginated_list_view.dart';
// import 'package:flutter_sixvalley_ecommerce/view/screen/chat/widget/chat_shimmer.dart';
// import 'package:flutter_sixvalley_ecommerce/view/screen/chat/widget/message_bubble.dart';
// import 'package:provider/provider.dart';
// import '../../../provider/splash_provider.dart';
// import 'almohsen_widget/message_reply_preview.dart';
// import 'almohsen_widget/mybottom_textfield.dart';
//
// class ChatScreen extends StatefulWidget {
//   final int? id;
//   final String? name;
//   final int? index;
//
//   const ChatScreen({Key? key, this.id, this.index, required this.name})
//       : super(key: key);
//
//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   ScrollController scrollController = ScrollController();
//   bool isActive1 = false;
//   Message? replyMessage;
//
//   @override
//   void initState() {
//     Provider.of<ChatProvider>(context, listen: false).clearchat();
//     Provider.of<ChatProvider>(context, listen: false)
//         .getMessageList(context, widget.id, 1);
//
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//
//     Provider.of<ChatProvider>(context, listen: false).getChatList(context, 1);
//     Provider.of<ChatProvider>(context, listen: false)
//         .getMessageList(context, widget.id, 1);
//     if (widget.index != null) {
//       if (Provider.of<ChatProvider>(context, listen: false)
//               .chatList![widget.index!]
//               .sellerInfo!
//               .isActive ==
//           '1') {
//         isActive1 = true;
//       } else {
//         isActive1 = false;
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     bool hasConnection = false;
//
//     setState(() {
//       Provider.of<SplashProvider>(context, listen: false).onOff
//           ? hasConnection = true
//           : hasConnection = false;
//     });
//
//     return Scaffold(
//       backgroundColor: ColorResources.getIconBg(context),
//       body: Consumer<ChatProvider>(builder: (context, chatProvider, child) {
//         if (widget.index != null) {
//           if (chatProvider.chatList![widget.index!].sellerInfo!.isActive ==
//               '1') {
//             isActive1 = true;
//           } else {
//             isActive1 = false;
//           }
//         }
//
//         return Column(children: [
//           Stack(
//             children: [
//               CustomAppBar(
//                 title: widget.name,
//               ),
//               Positioned(
//                 top: 20,
//                 bottom: 0,
//                 right: 0,
//                 child: IconButton(
//                   onPressed: () async {
//                     // print("996367749 index ${widget.index}");
//
//                     await chatProvider.getChatList(context, 1);
//                     if (widget.index != null) {
//                       String? issactive = await chatProvider
//                           .chatList![widget.index!].sellerInfo!.isActive;
//                       print("$issactive 996367749");
//
//                       if ((chatProvider
//                               .chatList![widget.index!].sellerInfo!.isActive) ==
//                           '0') {
//                         setState(() {
//                           isActive1 = false;
//                           print(
//                               "${chatProvider.chatList![widget.index!].sellerInfo!.isActive} 996367749");
//                         });
//                       } else if (chatProvider
//                               .chatList![widget.index!].sellerInfo!.isActive ==
//                           '1') {
//                         setState(() {
//                           isActive1 = true;
//                           print(
//                               "${chatProvider.chatList![widget.index!].sellerInfo!.isActive} 996367749");
//                         });
//                       }
//                       print("onPressed is_active = $isActive1;");
//                     }
//                   },
//                   icon: isActive1
//                       ? const Icon(Icons.circle, color: Colors.green, size: 12)
//                       : const Icon(Icons.circle, color: Colors.grey, size: 12),
//                 ),
//               ),
//             ],
//           ),
//           Expanded(
//             child: chatProvider.messageModel != null
//                 ? (chatProvider.messageModel!.message != null &&
//                         chatProvider.messageModel!.message!.isNotEmpty)
//                     ? SingleChildScrollView(
//                         controller: scrollController,
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: Dimensions.paddingSizeDefault),
//                           child: StreamBuilder<Object>(
//                               stream: null,
//                               builder: (context, snapshot) {
//                                 return PaginatedListView(
//                                   reverse: true,
//                                   physics: const NeverScrollableScrollPhysics(),
//                                   scrollController: scrollController,
//                                   onPaginate: (int? offset) {
//                                     print("update99636");
//                                     chatProvider.getChatList(context, offset!,
//                                         reload: false);
//                                   },
//                                   totalSize:
//                                       chatProvider.messageModel!.totalSize,
//                                   offset: int.parse(
//                                       chatProvider.messageModel!.offset!),
//                                   enabledPagination:
//                                       chatProvider.messageModel == null,
//                                   itemView: ListView.builder(
//                                     // controller: ,
//                                     itemCount: chatProvider
//                                         .messageModel!.message!.length,
//                                     padding: EdgeInsets.only(top: 15),
//                                     physics:
//                                         const NeverScrollableScrollPhysics(),
//                                     shrinkWrap: true,
//                                     itemBuilder: (context, index) {
//                                       Future.delayed(
//                                               const Duration(milliseconds: 800))
//                                           .then((value) => scrollController
//                                               .jumpTo(scrollController
//                                                   .position.maxScrollExtent));
//
//                                       return MessageBubble(
//                                           onleftSwip: () {},
//                                           message: chatProvider
//                                               .messageModel!.message![index]);
//                                     },
//                                   ),
//                                 );
//                               }),
//                         ))
//                     : const Expanded(
//                         child: NoInternetOrDataScreen(isNoInternet: false))
//                 : const Expanded(child: Center(child: ChatShimmer())),
//           ),
//           MyBottomSendField(
//             name: widget.name,
//             id: widget.id,
//             scrollController: scrollController,
//           )
//         ]);
//       }),
//     );
//   }
// }
