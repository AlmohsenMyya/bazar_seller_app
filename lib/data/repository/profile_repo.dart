import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response/address_model.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response/base/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response/user_info_model.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfileRepo {
  final DioClient? dioClient;
  final SharedPreferences? sharedPreferences;
  ProfileRepo({required this.dioClient, required this.sharedPreferences});

  Future<ApiResponse> getAddressTypeList() async {
    try {
      List<String> addressTypeList = [
        'Select Address type',
        'Permanent',
        'Home',
        'Office',
      ];
      Response response = Response(requestOptions: RequestOptions(path: ''), data: addressTypeList, statusCode: 200);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> getUserInfo() async {
    try {
      final response = await dioClient!.get(AppConstants.customerUri);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> deleteUserAccount(int? customerId) async {
    try {
      final response = await dioClient!.get('${AppConstants.deleteCustomerAccount}/$customerId');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> getAllAddress() async {
    try {
      final response = await dioClient!.get(AppConstants.addressListUri);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> removeAddressByID(int? id) async {
    try {
      final response = await dioClient!.delete('${AppConstants.removeAddressUri}$id');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> addAddress(AddressModel addressModel) async {
    try {
      Response response = await dioClient!.post(
        AppConstants.addAddressUri,
        data: addressModel.toJson(),
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }






  Future<http.StreamedResponse> updateProfile(UserInfoModel userInfoModel, String pass, File? file, String token) async {
    //

    http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse('${AppConstants.baseUrl}${AppConstants.updateProfileUri}'));
    request.headers.addAll(<String,String>{'Authorization': 'Bearer $token'});
    print({'Authorization': 'Bearer $token'});
    if(file != null){
      request.files.add(http.MultipartFile('image', file.readAsBytes().asStream(), file.lengthSync(), filename: file.path.split('/').last));
    }
     Map<String, String> fields = {};
    if(pass.isEmpty) {
      fields.addAll(<String, String>{
        '_method': 'put', 'f_name': userInfoModel.fName!, 'l_name': userInfoModel.lName!, 'phone': userInfoModel.phone!
      });
    }else {
      fields.addAll(<String, String>{
        '_method': 'put', 'f_name': userInfoModel.fName!, 'l_name': userInfoModel.lName!, 'phone': userInfoModel.phone!, 'password': pass
      });
    }
    request.fields.addAll(fields);
    if (kDebugMode) {
      print('====almohsen====>${fields.toString()}');
    }
    http.StreamedResponse response = await request.send();
    print("response=======almohsen=>${response}");
    return response;
  }

// edit by almohsen
  Future<http.Response> updateIsActive(bool isActive, String token) async {

    // Construct the API endpoint URL
    String apiUrl = '${AppConstants.baseUrl}/api/v1/customer/update-isActive?is_active=${isActive ? 1 : 0}';
    print('endy user token : $token  +-+');
    // Create the HTTP request
    http.Response response = await http.put(Uri.parse(apiUrl), headers: <String, String>{'Authorization': 'Bearer $token'});
    // Return the response
    return response;
  }

  // for save home address
  Future<void> saveHomeAddress(String homeAddress) async {
    try {
      await sharedPreferences!.setString(AppConstants.homeAddress, homeAddress);
    } catch (e) {
      rethrow;
    }
  }

  String getHomeAddress() {
    return sharedPreferences!.getString(AppConstants.homeAddress) ?? "";
  }

  Future<bool> clearHomeAddress() async {
    return sharedPreferences!.remove(AppConstants.homeAddress);
  }

  // for save office address
  Future<void> saveOfficeAddress(String officeAddress) async {
    try {
      await sharedPreferences!.setString(AppConstants.officeAddress, officeAddress);
    } catch (e) {
      rethrow;
    }
  }

  String getOfficeAddress() {
    return sharedPreferences!.getString(AppConstants.officeAddress) ?? "";
  }

  Future<bool> clearOfficeAddress() async {
    return sharedPreferences!.remove(AppConstants.officeAddress);
  }
}
