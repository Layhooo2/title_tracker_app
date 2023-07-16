import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:title_tracker_app/runs.dart';
import 'dart:io';
import 'add_title.dart';
import 'auth.dart';
import 'dog.dart';

class DogProfile extends StatelessWidget {
  final String dogId;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Auth auth = Auth();

  DogProfile({Key? key, required this.dogId}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    DocumentReference userDoc = firestore.collection('users').doc(auth.getUserId());
    CollectionReference dogCol = userDoc.collection('dogs');
    DocumentReference dogDoc = dogCol.doc(dogId);
    CollectionReference titleCol = dogDoc.collection('titles');

    return FutureBuilder<Dog?>(
      future: getDog(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          Dog? thisDog = snapshot.data;

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              title: Text('${thisDog?.name ?? "Dog"}\'s page!', style: Theme.of(context).textTheme.headlineLarge,),
            ),
            body: Center(
                child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(15),
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CircleAvatar(
                          radius: 80,
                          backgroundImage: FileImage(File(
                              thisDog?.picture ?? 'assets/BlankDogPic.png')),
                        ),
                        Column(
                          children: [
                            Text('${thisDog?.breed}'),
                            Text(
                                'Bday: ${thisDog?.birthdate?.month}-${thisDog?.birthdate?.day}-${thisDog?.birthdate?.year}'),
                            Text(
                                'Start: ${thisDog?.startdate?.month}-${thisDog?.startdate?.day}-${thisDog?.startdate?.year}'),
                          ],
                        )
                      ]),
                ),
                Container(
                  child: Column(
                    children: [
                      //Text('Titles'),
                      StreamBuilder<QuerySnapshot>(
                        stream:
                        titleCol.snapshots(),
                        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasData) {

                            return ListView(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              children: snapshot.data!.docs.map((title) {

                                if (title['count'] == title['needed']) {
                                  DocumentReference tdoc = titleCol.doc(title.id);
                                  tdoc.update({'complete':true});
                                }
                                return Center(
                                  child: Container(
                                    margin: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.secondaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      title: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [Text(title['title'], style: Theme.of(context).textTheme.titleLarge,),
                                        Text(title['complete'] ? 'Earned!' : '${title['count']} out of ${title['needed']}')
                                        ],
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    Runs(dogId: dogId, titleId: title.id)));
                                        print('Runs page');
                                      },
                                      onLongPress: () {
                                        title.reference.delete();
                                      },
                                    ),
                                  )
                                );
                              }).toList(),
                            );
                          } else {
                            return CircularProgressIndicator();
                          }
                        },
                      ),



                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      AddTitle(dogId: dogId)));

                          print('Title added');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          foregroundColor:
                              Theme.of(context).colorScheme.secondary,
                          textStyle: Theme.of(context).textTheme.titleLarge,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          //elevation: 15,
                          shadowColor: Colors.black54
                        ),
                        child: const Text(
                          'Add Title',
                          //style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )
                    ],
                  ),
                )
              ],
            )),
          );
        }
      },
    );
  }

  Future<Dog> getDog() async {
    String userId = auth.getUserId()!;

    try {
      var docSnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('dogs')
          .doc(dogId)
          .get();

      if (docSnapshot.exists) {
        String name = docSnapshot.data()!['name'];
        String breed = docSnapshot.data()!['breed'];
        DateTime birthdate = docSnapshot.data()!['birthdate'].toDate();
        DateTime startdate = docSnapshot.data()!['startdate'].toDate();
        String picture = docSnapshot.data()!['picture'];

        return Dog(
          id: dogId,
          name: name,
          breed: breed,
          birthdate: birthdate,
          startdate: startdate,
          picture: picture,
        );
      } else {
        print('No Dog');
        return Dog(id: 'null');
      }
    } catch (e) {
      print('Error retrieving document: $e');
      return Dog(id: 'null');
    }
  }
}
