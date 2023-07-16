import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';

import 'package:title_tracker_app/auth.dart';

class AddDog extends StatefulWidget {
  //const AddDog({super.key});
  @override
  State<StatefulWidget> createState() {
    return AddDogState();
  }

}
class AddDogState extends State<AddDog> {

  PickedFile? imageFile;
  ImagePicker picker = ImagePicker();

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  Auth auth = Auth();

  String name = 'dog';
  DateTime birthdate = DateTime(2023,01,01);
  //String? breed;
  DateTime startdate = DateTime(2023,01,01);

  List<String> breeds = [];
  String selectedBreed = 'border collie';


  @override
  Widget build(BuildContext context) {

    getBreedList();

    return Scaffold(
      resizeToAvoidBottomInset: true,
        appBar: AppBar (
          title: const Text('Add Dog'),
          titleTextStyle: Theme.of(context).textTheme.headlineLarge,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(10),
                    //: Theme.of(context).colorScheme.secondaryContainer,
                    child: imageProfile(picker, context),
                  ),
                  Container(
                    margin: const EdgeInsets.all(10),
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    child: TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Name',
                      ),
                      onChanged: (val) {
                        name = val;
                      },
                    ),
                  ),
                  Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
                      //color: Theme.of(context).colorScheme.secondaryContainer,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Theme.of(context).colorScheme.secondary),
                        borderRadius: BorderRadius.circular(5),
                        color: Theme.of(context).colorScheme.secondaryContainer,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Birthdate',
                            style: Theme.of(context).textTheme.bodyLarge,),
                          Text('${birthdate.month}-${birthdate.day}-${birthdate.year}',
                            style: Theme.of(context).textTheme.bodyLarge,),
                          IconButton(
                            icon: Icon(Icons.calendar_today),
                            onPressed: () async {
                              DateTime? newDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1990),
                                  lastDate: DateTime.now());
                              if (newDate == null) return;
                              setState(() => birthdate = newDate);
                            },

                          ),],
                      )
                  ),
                  Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).colorScheme.secondary),
                      borderRadius: BorderRadius.circular(5),
                      color: Theme.of(context).colorScheme.secondaryContainer,
                    ),
                    //color: Theme.of(context).colorScheme.secondaryContainer,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('Breed:'),
                        breedDrop()],
                    )
                  ),
                  Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(10),
                    //color: Theme.of(context).colorScheme.secondaryContainer,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).colorScheme.secondary),
                      borderRadius: BorderRadius.circular(5),
                      color: Theme.of(context).colorScheme.secondaryContainer,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            'Start Date',
                        style: Theme.of(context).textTheme.bodyLarge,),
                        Text('${startdate.month}-${startdate.day}-${startdate.year}',
                          style: Theme.of(context).textTheme.bodyLarge,),
                        IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () async {
                          DateTime? newDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1990),
                              lastDate: DateTime.now());
                          if (newDate == null) return;
                          setState(() => startdate = newDate);
                        },

                      ),],
                    )
                  ),
                  ElevatedButton(
                    onPressed: () async {

                      addDog();
                      Navigator.pop(context);

                    }, child: const Icon(Icons.check),

                  ),]
            ),
          ),
        )
    );
  }


  Future<List<String>> loadTextFile() async {

    String text = await rootBundle.loadString('assets/dogbreeds.txt');
    List<String> lines = text.split('\n').where((line) => line.trim().isNotEmpty).toList();

    return lines;
  }

  void getBreedList() async {
    List<String> loaded = await loadTextFile();
    setState(() {
      breeds = loaded;
    });
  }

  Widget breedDrop() {
    return DropdownButton<String>(
        value: selectedBreed,
        items: breeds.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: (String? selected) {
          setState(() {
            selectedBreed = selected!;
          });
        }
    );
  }


  Widget imageProfile(picker, context) {
    return Stack(
      children: [
        CircleAvatar(
            radius: 80,
            backgroundImage: imageFile == null
                ? const AssetImage('assets/BlankDogPic.png')
                : FileImage(File(imageFile!.path)) as ImageProvider
        ),
        Positioned(
            bottom: 25,
            right: 25,
            child: InkWell(
              onTap: () {
                showModalBottomSheet(
                    context: context,
                    builder: ((builder) => bottomPopUp())
                );
              },
              child: const Icon(Icons.camera_alt_rounded, size: 32),
            )
        )
      ],
    );
  }

  Widget bottomPopUp() {
    return Container(
        height: 150,
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.all(0),
        child: Column(
          children: [
            const Expanded(
              child: Text("Choose a photo!"),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                    child: TextButton.icon(
                      onPressed: () {
                        takePhoto(ImageSource.camera) as PickedFile?;
                        //Navigator.pop(context);
                      },
                      icon: Icon(Icons.camera), label: Text('Camera'),
                    )
                ),
                Expanded(
                    child: TextButton.icon(
                      onPressed: () {
                        takePhoto(ImageSource.gallery) as PickedFile?;
                        //Navigator.pop(context);
                      },
                      icon: Icon(Icons.photo), label: Text('Gallery'),
                    )
                )
              ],
            )

          ],
        )
    );
  }


  void takePhoto(source) async {
    final pickedFile = await picker.getImage(
      source: source,
    );
    setState(() {
      imageFile = pickedFile;
    });
    Navigator.pop(context);
  }


  Future<void> addDog() async {
    String? userId = auth.getUserId();

    DocumentReference userDoc = firestore.collection('users').doc(userId);

    String? path = imageFile?.path;
    path ??= 'none';

    Map<String, dynamic> dogData = {
      'name': name,
      'birthdate': birthdate,
      'breed': selectedBreed,
      'startdate': startdate,
      'picture' : path,
    };
    await userDoc.collection('dogs').add(dogData);
  }

} //State
