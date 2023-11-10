// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'store.dart';
import 'actions.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

List<Listing> initialListings =
    []; // Declare initialListings outside the main function

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initialListings = await loadListings(); // Initialize initialListings

  store.dispatch(SetItemsAction(initialListings));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: store,
      child: MaterialApp(
        title: 'Computer Hardware Ads',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Computer Hardware Ads'),
      ),
      body: StoreConnector<List<Listing>, List<Listing>>(
        converter: (store) => store.state,
        builder: (context, listings) {
          return ListView.builder(
            itemCount: listings.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(listings[index].name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Description: ${listings[index].description}'),
                    Text('Phone Number: ${listings[index].phoneNumber}'),
                    Text(
                        'Price: \$${listings[index].price.toStringAsFixed(2)}'),
                  ],
                ),
                leading: listings[index].imageFile != null
                    ? Image.file(
                        listings[index].imageFile!,
                        width: 50.0,
                        height: 50.0,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 50.0,
                        height: 50.0,
                        color: Colors.grey,
                      ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        // Open a form to edit the selected listing
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditListingForm(index: index),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        // Get the current listings from the Redux store
                        List<Listing> currentListings =
                            StoreProvider.of<List<Listing>>(context).state;

                        // Get the ID of the listing to be deleted
                        int deletedIndex = index;

                        // Dispatch the DeleteItemAction when the delete button is pressed
                        StoreProvider.of<List<Listing>>(context)
                            .dispatch(DeleteItemAction(deletedIndex));

                        // Remove the deleted listing from the initialListings array
                        initialListings.removeAt(deletedIndex);

                        // Save updated listings to SharedPreferences
                        await saveListings(initialListings);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open a form to add a new listing
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddListingForm()),
          );
        },
        tooltip: 'Add Listing',
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddListingForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Listing'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AddEditForm(),
      ),
    );
  }
}

class EditListingForm extends StatelessWidget {
  final int index;

  EditListingForm({required this.index});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Listing'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AddEditForm(index: index),
      ),
    );
  }
}

class AddEditForm extends StatefulWidget {
  final int? index;

  AddEditForm({this.index});

  @override
  _AddEditFormState createState() => _AddEditFormState();
}

class _AddEditFormState extends State<AddEditForm> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _priceController = TextEditingController();
  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Add an image picker button
        ElevatedButton(
          onPressed: _pickImage,
          child: Text('Select Image'),
        ),
        // Display the selected image
        _selectedImage != null
            ? Image.file(
                _selectedImage!,
                width: 100.0,
                height: 100.0,
                fit: BoxFit.cover,
              )
            : Container(
                width: 100.0,
                height: 100.0,
                color: Colors.grey,
              ),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(labelText: 'Name'),
        ),
        TextField(
          controller: _descriptionController,
          decoration: InputDecoration(labelText: 'Description'),
        ),
        TextField(
          controller: _phoneNumberController,
          decoration: InputDecoration(labelText: 'Phone Number'),
        ),
        TextField(
          controller: _priceController,
          decoration: InputDecoration(labelText: 'Price'),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: () async {
            final newListing = Listing(
              name: _nameController.text,
              description: _descriptionController.text,
              phoneNumber: _phoneNumberController.text,
              price: double.parse(_priceController.text),
              imageFile: _selectedImage,
            );

            List<Listing> updatedListings;
            if (widget.index != null) {
              // Edit existing listing
              updatedListings = List.from(store.state)
                ..[widget.index!] = newListing;
            } else {
              // Add new listing
              updatedListings = List.from(store.state)..add(newListing);
            }

            // Save updated listings to SharedPreferences
            await saveListings(updatedListings);

            // Dispatch action to update the store
            store.dispatch(SetItemsAction(updatedListings));

            // Close the form
            Navigator.pop(context);
          },
          child: Text(widget.index != null ? 'Save Changes' : 'Add Listing'),
        ),
      ],
    );
  }

  // Image picker function
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }
}
