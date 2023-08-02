import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/src/response.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/body/message_body.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response/base/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:provider/provider.dart';

import '../../provider/auth_provider.dart';

class ChatRepo {
  final DioClient? dioClient;

  ChatRepo({required this.dioClient});

  Future<ApiResponse> getChatList(String type, int offset) async {
    try {
      final response = await dioClient!
          .get('${AppConstants.chatInfoUri}$type?limit=30&offset=$offset');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> searchChat(String type, String search) async {
    try {
      final response = await dioClient!
          .get('${AppConstants.searchChat}$type?search=$search');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> getMessageList(String type, int? id, offset) async {
    try {
      final response = await dioClient!
          .get('${AppConstants.messageUri}$type/$id?limit=300&offset=$offset');
      print(
          "getMessageList \n --------- \n ---+--+--+--+- \n  ${AppConstants.messageUri}$type/$id?limit=300&offset=$offset");
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  // Future<ApiResponse> sendMessage(MessageBody messageBody, String type) async {
  //   print(
  //       '======> Here is response=====${messageBody.id}/${messageBody.message}=====>');
  //   try {
  //     final response = await dioClient!.post(
  //         '${AppConstants.sendMessageUri}$type',
  //         data: messageBody.toJson());
  //     print(
  //         "sendMessage \n --------- \n type = $type --+-+---+---+-- \n  ${AppConstants.sendMessageUri}$type");
  //     return ApiResponse.withSuccess(response);
  //   } catch (e) {
  //     return ApiResponse.withError(ApiErrorHandler.getMessage(e));
  //   }
  // }

  // edite by almohsen sendMessageText + sendMessageMedia

  Future<ApiResponse> sendMessageText(MessageBody messageBody, String type) async {
    try {
      final response = await dioClient!.post(
          '${AppConstants.sendMessageUri}$type',
          data: messageBody.toJson()
      );
      print(
          "sendMessage \n --------- \n type = $type --+-+---+---+-- \n  ${AppConstants.sendMessageUri}$type"
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> sendMessageMedia(MessageBody messageBody, String type, File file) async {
    print("iddd ${messageBody.id.toString()}");
    try {

      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: basename(file.path)),
        'id': messageBody.id.toString(),
        'key': messageBody.messageType!,
        'message': messageBody.message!

      });
      final response = await dioClient!.post(
        '${AppConstants.sendMessageUri}$type',
        data: formData,
        options: Options(
          contentType: 'application/json; charset=UTF-8',
        ),
      );
      return ApiResponse.withSuccess(response);

    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));

    }
  }

  Future<ApiResponse> sendMessageMedia1(MessageBody messageBody, String type, File file) async {
    try {
      print("id ${messageBody.id.toString()}- postman "   );
      var request = http.MultipartRequest(
          'POST', Uri.parse('${AppConstants.sendMessageUri}$type'));
      var length = await file.length();
      var stream = http.ByteStream(file.openRead());
      var multiFile = http.MultipartFile('file', stream, length, filename: basename(file.path));

      request.files.add(multiFile);
      Map<String, String> fields = {};
      fields.addAll(<String, String>{
        'id': messageBody.id.toString(),
        'key': messageBody.messageType!,
        'message':messageBody.message!
      });
      request.fields.addAll(fields);
      http.StreamedResponse response = await request.send();
      // return response;
      return ApiResponse.withSuccess(response as Response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }
}
