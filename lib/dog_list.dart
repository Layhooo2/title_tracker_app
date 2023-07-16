import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:title_tracker_app/dog_profile.dart';
import 'dart:io';
import 'auth.dart';

import 'dog.dart';


class ImageData {
  final String documentId;
  final String imagePath;

  ImageData({required this.documentId, required this.imagePath});
}

class DogList extends StatelessWidget {
  DogList({super.key});

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Auth auth = Auth();

  Future<void> checkUserDBEntry(firestore, auth) async {
    String userId = auth.getUserId();

    CollectionReference collection = firestore.collection('users');
    DocumentSnapshot snapshot = await collection.doc(userId).get();
    bool exists = snapshot.exists;
    if (exists) {
      print(snapshot.data());
      //print(auth.getUserId);
    } else {
      //print('Not there');
      Map<String, dynamic> data = {
        'email': auth.getUserEmail(),
        // Add more fields as needed
      };
      await collection.doc(userId).set(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    checkUserDBEntry(firestore, auth);

    var users_collection = firestore.collection('users');
    var user_dog_collection =
        users_collection.doc(auth.getUserId()).collection('dogs');

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Active Dogs'),
        //titleTextStyle: Theme.of(context).textTheme.headlineMedium,
        titleTextStyle: Theme.of(context).textTheme.headlineLarge,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
        child: Center(
            child: Column(
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: user_dog_collection.snapshots(),
                  builder:
                      (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    final List<ImageData> imageList = snapshot.data!.docs.map((doc) {
                      final documentId = doc.id;
                      final imagePath = (doc.data() as Map<String, dynamic>)['picture'] as String?;
                      return ImageData(documentId: documentId, imagePath: imagePath ?? '');
                    }).toList();

                    return Expanded(
                        child: Column(
                          children: [
                            Flexible(
                              child: GridView.builder(
                                gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, // Set the number of columns here
                                  crossAxisSpacing:
                                  10.0, // Set the spacing between columns
                                  mainAxisSpacing: 10.0, // Set the spacing between rows
                                ),
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: imageList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final imageData = imageList[index];
                                  return CircleAvatar(
                                      radius: 80,
                                      backgroundImage: FileImage(File(imageData.imagePath)),
                                      child: SizedBox(
                                          height: 160,
                                          width: 160,
                                          child: Visibility(
                                            visible: false,
                                            maintainState: true,
                                            maintainAnimation: true,
                                            maintainSize: true,
                                            maintainInteractivity: true,
                                            child: IconButton(
                                              onPressed: () {
                                                Navigator.push(context,
                                                    MaterialPageRoute(builder: (context) => DogProfile(dogId: imageData.documentId)));
                                              },
                                              icon: const Icon(Icons.abc),),
                                          )
                                      )
                                  );
                                },
                              ),
                            ),
                          ],
                        ));
                  },
                ),

                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/add_dog');
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                      foregroundColor: Colors.black54,

                      textStyle: Theme.of(context).textTheme.titleLarge,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                  ),
                  child: const Text('Add Dog'),
                ),
              ],
            )
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () { auth.signOut(); },
        child: const Icon(Icons.logout),
      ),
    );
  }
}
