class ChatModel {
  int? totalSize;
  String? limit;
  String? offset;
  List<Chat>? chat;

  ChatModel({this.totalSize, this.limit, this.offset, this.chat});

  ChatModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    if (json['chat'] != null) {
      chat = <Chat>[];
      json['chat'].forEach((v) {
        chat!.add(Chat.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (chat != null) {
      data['chat'] = chat!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Chat {
  int? id;
  int? userId;
  int? sellerId;
  int? adminId;
  int? deliveryManId;
  String? message;
  int? sentByCustomer;
  int? sentBySeller;
  int? sentByAdmin;
  int? sentByDeliveryMan;
  int? seenByCustomer;
  int? status;
  String? createdAt;
  String? updatedAt;
  SellerInfo? sellerInfo;
  DeliveryMan? deliveryMan;

  Chat({
    this.id,
    this.userId,
    this.sellerId,
    this.adminId,
    this.deliveryManId,
    this.message,
    this.sentByCustomer,
    this.sentBySeller,
    this.sentByAdmin,
    this.sentByDeliveryMan,
    this.seenByCustomer,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.sellerInfo,
    this.deliveryMan,
  });

  Chat.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    sellerId = json['seller_id'];
    adminId = json['admin_id'];
    if (json['delivery_man_id'] != null) {
      deliveryManId = int.parse(json['delivery_man_id'].toString());
    }

    message = json['message'];
    sentByCustomer = json['sent_by_customer'];
    sentBySeller = json['sent_by_seller'];
    sentByAdmin = json['sent_by_admin'];
    sentByDeliveryMan = json['sent_by_delivery_man'];
    seenByCustomer = json['seen_by_customer'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    sellerInfo = json['seller_info'] != null
        ? SellerInfo.fromJson(json['seller_info'])
        : null;
    deliveryMan = json['delivery_man'] != null
        ? DeliveryMan.fromJson(json['delivery_man'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['seller_id'] = sellerId;
    data['admin_id'] = adminId;
    data['delivery_man_id'] = deliveryManId;
    data['message'] = message;
    data['sent_by_customer'] = sentByCustomer;
    data['sent_by_seller'] = sentBySeller;
    data['sent_by_admin'] = sentByAdmin;
    data['sent_by_delivery_man'] = sentByDeliveryMan;
    data['seen_by_customer'] = seenByCustomer;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (deliveryMan != null) {
      data['delivery_man'] = deliveryMan!.toJson();
    }
    if (sellerInfo != null) {
      data['seller_info'] = sellerInfo!.toJson();
    }
    return data;
  }
}

class SellerInfo {
  String? isActive;

  List<Shops>? shops;

  SellerInfo({
    this.shops,
    this.isActive,
  });

  SellerInfo.fromJson(Map<String, dynamic> json) {
    if (json['shops'] != null) {
      shops = <Shops>[];
      json['shops'].forEach((v) {
        shops!.add(Shops.fromJson(v));
      });
    }
    isActive = (json['is_active']).toString() ;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (shops != null) {
      data['shops'] = shops!.map((v) => v.toJson()).toList();
    }
    data['is_active']= isActive ;

    return data;
  }
}

class Shops {
  int? id;
  int? sellerId;
  String? name;
  String? image;

  Shops({
    this.id,
    this.sellerId,
    this.name,
    this.image,
  });

  Shops.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    if (json['seller_id'] != null) {
      sellerId = int.parse(json['seller_id'].toString());
    }

    name = json['name'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['seller_id'] = sellerId;
    data['name'] = name;
    data['image'] = image;
    return data;
  }
}

class DeliveryMan {
  int? id;
  String? fName;
  String? lName;
  String? image;

  DeliveryMan({
    this.id,
    this.fName,
    this.lName,
    this.image,
  });

  DeliveryMan.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fName = json['f_name'];
    lName = json['l_name'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['f_name'] = fName;
    data['l_name'] = lName;
    data['image'] = image;
    return data;
  }
}
