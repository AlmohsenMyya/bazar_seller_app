import 'dart:io';

class MessageBody {
  int? _id;
  String? _message;
  //  edite by almohsen
  String? _messageType;
  File? _mediaFile; // Add mediaFile property

  MessageBody({int? id, String? message , String? messageType, File? mediaFile}) {
    _id = id;
    _message = message;
    // edite by almohsen
    _messageType = messageType;
    _mediaFile = mediaFile;
  }

  int? get id => _id;
  String? get message => _message;
  // edite by almohsen
  String? get messageType => _messageType;
  File? get mediaFile => _mediaFile; // Add mediaFile getter

  MessageBody.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _message = json['message'];
    // edite by almohsen
    _messageType = json['key'] ;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['message'] = _message;
    // edite by almohsen
    data ['key'] = _messageType;
    return data;
  }
}