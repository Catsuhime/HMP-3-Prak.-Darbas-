// actions.dart
import 'dart:io';

class FetchItemsAction {}

class Listing {
  final String name;
  final String description;
  final String phoneNumber;
  final double price;
  final File? imageFile;

  Listing({
    required this.name,
    required this.description,
    required this.phoneNumber,
    required this.price,
    required this.imageFile,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'phoneNumber': phoneNumber,
      'price': price,
      'imageFilePath': imageFile?.path,
    };
  }

  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      name: json['name'],
      description: json['description'],
      phoneNumber: json['phoneNumber'],
      price: json['price'],
      imageFile:
          json['imageFilePath'] != null ? File(json['imageFilePath']) : null,
    );
  }
}

class SetItemsAction {
  final List<Listing> items;
  SetItemsAction(this.items);
}

class AddItemAction {
  final Listing newItem;
  AddItemAction(this.newItem);
}

class EditItemAction {
  final int index;
  final Listing updatedItem;
  EditItemAction(this.index, this.updatedItem);
}

class DeleteItemAction {
  final int index;
  DeleteItemAction(this.index);
}