import 'dart:collection';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/body/message_body.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response/base/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response/chat_model.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response/message_model.dart';
import 'package:flutter_sixvalley_ecommerce/data/repository/chat_repo.dart';
import 'package:flutter_sixvalley_ecommerce/helper/api_checker.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:intl/intl.dart';


class ChatProvider extends ChangeNotifier {
  final ChatRepo? chatRepo;
  ChatProvider({required this.chatRepo});

  bool _isShowReplyMessage = false;
  List<Message>? _oldmessageList = [];
  List<Message>? get oldmessageList => _oldmessageList;
  bool get isShowReplyMessage => _isShowReplyMessage;
  Message? _messageReply ;
  Message? get messageReply => _messageReply ;
  bool _isSendButtonActive = false;
  bool get isSendButtonActive => _isSendButtonActive;
  bool _isloadingActive = false;
  bool get isloadingActive => _isloadingActive;
  List<Chat>? _chatList;
  List<Chat>? get chatList => _chatList;
  bool _isSearching = false;
  bool get isSearching => _isSearching;
  File? _imageFile;
  File? get imageFile => _imageFile;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _userTypeIndex = 0;
  int get userTypeIndex =>  _userTypeIndex;
  ChatModel? chatModel;


  bool _isSendingComplete = true ;
  bool get isSendingComplete => _isSendingComplete;
  ///....
  Queue<MessageBody> messageQueue = Queue();
  bool isProcessingQueue = false;
  ///----------


  sendMessagequeue(MessageBody messageBody, BuildContext context) {

    addFakeMessage(messageBody, context);
    // Add message to queue
    messageQueue.add(messageBody);

    // Process queue if it is not already being processed
    if (!isProcessingQueue) {
      processQueue(context);
    }
  }
  Future processQueue(BuildContext context) async{
    print("processQueue neww isProcessingQueue = $isProcessingQueue");
    if (messageQueue.isEmpty) {
      // Queue is empty, stop processing
      isProcessingQueue = false;
      return;
    }
    isProcessingQueue = true;
    // await Future.delayed(Duration(seconds: 2));
    MessageBody messageBody = messageQueue.removeFirst();
    await sendMessage(messageBody,context).then((value) async {

      if (value.response?.statusCode == 200) {  await updateMessageList( messageBody.id, 1).then((value) {
        if (value.response!.statusCode == 200) {
          print("processQueue neww");
          processQueue(context);
          _isSendingComplete = true ; }

      }); }else if (value.error){

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("value.error.toString()"),
            backgroundColor: Colors.red));
      }
      else {  print("processQueue error"); processQueue(context);}
    });

  }
  Future<ApiResponse> updateMessageList(int? id, int offset) async {
    messageModel!.message =[];
    ApiResponse apiResponse = await chatRepo!.getMessageList(_userTypeIndex == 0? 'seller' : 'delivery-man', id, offset);

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {

      messageModel = MessageModel.fromJson(apiResponse.response!.data);
      // Reverse the order of the message list
      var reversedMessageList = MessageModel.fromJson(apiResponse.response!.data).message!.reversed.toList();
      // Add the reversed message list to the existing list
      messageModel!.message = [];
      messageModel!.message!.insertAll(0, reversedMessageList);

      // Compare the new messages with the old messages
      int newIndex =   messageModel!.message !.length - 1;
      int oldIndex = _oldmessageList!.length - 1;
      print("while start $newIndex // $oldIndex ");


      while (newIndex >= 0 && oldIndex >= 0) {

        final Message newMessage =   messageModel!.message ![newIndex];
        final Message oldMessage = _oldmessageList![oldIndex];



        if (newMessage.message == oldMessage.message) {
          newIndex--;
          oldIndex--;
          print("${newMessage.message}  eqqqqq $newIndex == $oldIndex oldMessage.id");
          // break ;
        } else if
        (newMessage.sentByCustomer == 1  ) {
          print("update message $newIndex = $oldIndex");
          _oldmessageList![oldIndex] = newMessage;
          newIndex--;
          oldIndex--;
        }
        else if  (newMessage.sentByCustomer != 1){
          // Otherwise, add the new message to the old message list
          print("add recive message $newIndex = $oldIndex");
          print("${newMessage.createdAt}");
          _oldmessageList!.insert(0, newMessage);
          newIndex--;
          oldIndex--;
        }
      }

      print("while end");
      /// // If there are any remaining new messages, add them to the beginning of the old message list
      // while (newIndex >= 0) {
      //   final Message newMessage = _messageList![newIndex];
      //   _oldmessageList!.insert(0, newMessage);
      //   newIndex--;
      // }
      messageModel!.message =[];
    }

    else {
      ApiChecker.checkApi(apiResponse);
    }

    notifyListeners();
    return apiResponse ;
  }
  void addFakeMessage(MessageBody fakeMessage, BuildContext context) {
    print("fake");
    messageModel!.message = [] ;
    final DateTime now = DateTime.now().toUtc();
    final String formattedTime = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'").format(now);
    Message ourMessage = Message(

      sentByCustomer: 1,
      createdAt: formattedTime,
      deliveryMan: null,
      fileUrl: null,
      id: fakeMessage.id,
      file: fakeMessage.mediaFile,
      message: "${fakeMessage.message}...",
      messageState: null,
      messageType: fakeMessage.messageType,
      // seenBySeller: null,
      // sentByDeliveryMan: null,
      // sentByCustomer: 1,
      // userId: fakeMessage.sellerId,
      // updatedAt: null,
    );

    // Add the fake message to the message list
    oldmessageList!.insert(0, ourMessage);
    // _messageList!.add(ourMessage);
    // Notify listeners to update the UI
    notifyListeners();
  }

  Future<void> getChatList(BuildContext context, int offset, {bool reload = true}) async {
    _isloadingActive = true ;
    if(reload){
      _chatList = [];
    }
    _isLoading = true;
    ApiResponse apiResponse = await chatRepo!.getChatList(_userTypeIndex == 0? 'seller' : 'delivery-man', offset);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _chatList = ChatModel.fromJson(apiResponse.response!.data).chat;
    } else {
      _isLoading = false;
      ApiChecker.checkApi( apiResponse);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchChat(BuildContext context, String search) async {
    _isLoading = true;
    _chatList = [];
    ApiResponse apiResponse = await chatRepo!.searchChat(_userTypeIndex == 0? 'seller' : 'delivery-man', search);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      chatModel = ChatModel(totalSize: 1, limit: '1', offset: '1', chat: []);
      apiResponse.response!.data.forEach((chat) {
        chatModel!.chat!.add(Chat.fromJson(chat));
      });
      _chatList = chatModel!.chat;

    } else {
      _isLoading = false;
      ApiChecker.checkApi( apiResponse);
    }
    _isLoading = false;
    notifyListeners();
  }
  clearchat () {
    messageModel = null ;
    _oldmessageList =[];
    notifyListeners();

  }

  MessageModel? messageModel;
  Future<void> getMessageList(BuildContext context, int? id,  int offset, {bool reload = true}  ) async {
    if(reload){
      // messageModel = null;
    }
    _isLoading = true;
    ApiResponse apiResponse = await chatRepo!.getMessageList(_userTypeIndex == 0? 'seller' : 'delivery-man', id, offset);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {

      if(offset == 1) {
        // messageModel = null;
        messageModel = MessageModel.fromJson(apiResponse.response!.data);
        // Reverse the order of the message list
        var reversedMessageList = MessageModel.fromJson(apiResponse.response!.data).message!.reversed.toList();
        // Add the reversed message list to the existing list
        messageModel!.message = [];
        messageModel!.message!.insertAll(0, reversedMessageList);
        _oldmessageList =[];
        _oldmessageList =  messageModel!.message ;
        messageModel!.message =[];
      }else {
        // Reverse the order of the message list
        var reversedMessageList = MessageModel.fromJson(apiResponse.response!.data).message!.reversed.toList();
        // Add the reversed message list to the existing list
        messageModel!.message!.insertAll(0, reversedMessageList);

        messageModel!.totalSize = MessageModel.fromJson(apiResponse.response!.data).totalSize;
        messageModel!.offset = MessageModel.fromJson(apiResponse.response!.data).offset;
        // messageModel!.message!.addAll(MessageModel.fromJson(apiResponse.response!.data).message!.reversed);
        _oldmessageList =[];
        _oldmessageList =  messageModel!.message ;
        messageModel!.message =[];
      }


    } else {
      _isLoading = false;
      ApiChecker.checkApi( apiResponse);
    }
    _isLoading = false;
    notifyListeners();
  }

  void toggleisSendingComplete(bool bool) {
    _isSendingComplete = bool ;
    notifyListeners();
  }
// edite by almohsen
  Future<ApiResponse> sendMessage(MessageBody messageBody, BuildContext context) async {
    print("try sending message");
    _isSendingComplete = false ;
    _isSendButtonActive = true;
    String messageType = messageBody.messageType!.toLowerCase();
    ApiResponse apiResponse;


    if (messageType == "text") {
      apiResponse = await chatRepo!.sendMessageText(messageBody, _userTypeIndex == 0? 'seller' : 'delivery-man');
      print("-*/*//*/*/*/*/*/*/*/*/*/*/*/*/*/**/*/***/**/*/*/*/*/*/*/*");
    } else if (messageType == "image" || messageType == "video" || messageType == "audio") {


      print("-*/*//*/*/*/*/*/*/*/*/*/*/*/*/*/**/*/***/**/*/*/*/*/*/*/* file");
      File? file = messageBody.mediaFile;

      if (file != null) {
        apiResponse = await chatRepo!.sendMessageMedia(messageBody, _userTypeIndex == 0? 'seller' : 'delivery-man', file);
      } else {
        apiResponse = ApiResponse.withError("Media file is missing");
        print("-*/*//*/*/*/*/*/*/*/*/*/*/*/*/*/**/*/***/**/*/*/*/*/*/*/*missing");
      }
    } else {
      apiResponse = ApiResponse.withError("Unsupported message type");
      print("-*/*//*/*/*/*/*/*/*/*/*/*/*/*/*/**/*/***/**/*/*/*/*/*/*/*Unsupported");
    }

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      // getMessageList(Get.context!, messageBody.id, 1).then((value) {
      //   _isSendingComplete = true ;
      //
      // });
      print("-*/*//*/*/*/*/*/*/*/*/*/*/*/*/*/**/*/***/**/*/*/*/*/*/*/*200");
    } else {
      ApiChecker.checkApi( apiResponse);
      print("-*/*//*/*/*/*/*/*/*/*/*/*/*/*/*/**/*/***/**/*/*/*/*/*/*/*404");
    }

    _isSendButtonActive = false;
    notifyListeners();
    return apiResponse;
  }


  void yesShowReplyMessage() {
    _isShowReplyMessage = true;
    notifyListeners();
  }
  void deleteReplyMessage() {
    _messageReply = null ;
    _isShowReplyMessage = false;
    notifyListeners();
  }

  void setReplyMessage (Message? replyMessage) {

    _messageReply = replyMessage ;
    _isShowReplyMessage = true ;
    notifyListeners();
  }

   Message ? getReplyMessage () {

    _isShowReplyMessage = true ;

    notifyListeners();
    return _messageReply ;
  }
  void toggleSendButtonActivity() {
    _isSendButtonActive = !_isSendButtonActive;
    notifyListeners();
  }
  void toggleisloadingActive(bool isloadingActive) {
    _isloadingActive = isloadingActive;
    notifyListeners();
  }
  void setImage(File image) {
    _imageFile = image;
    _isSendButtonActive = true;
    notifyListeners();
  }

  void removeImage(String text) {
    _imageFile = null;
    text.isEmpty ? _isSendButtonActive = false : _isSendButtonActive = true;
    notifyListeners();
  }

  void toggleSearch() {
    _isSearching = !_isSearching;
    notifyListeners();
  }
  void setUserTypeIndex(BuildContext context, int index) {
    _userTypeIndex = index;
    getChatList(context, 1);
    notifyListeners();
  }

}
