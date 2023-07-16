import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'add_run.dart';
import 'add_title.dart';
import 'auth.dart';
import 'dog.dart';

class Runs extends StatelessWidget {
  final String dogId;
  final String titleId;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Auth auth = Auth();

  Runs({Key? key, required this.dogId, required this.titleId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    DocumentReference userDoc = firestore.collection('users').doc(
        auth.getUserId());
    CollectionReference dogCol = userDoc.collection('dogs');
    DocumentReference dogDoc = dogCol.doc(dogId);
    CollectionReference titleCol = dogDoc.collection('titles');
    DocumentReference titleDoc = titleCol.doc(titleId);
    CollectionReference runs = titleDoc.collection('runs');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .primaryContainer,
        title: Text('Runs', style: Theme.of(context).textTheme.headlineLarge,),
      ),
      body: Center(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    //Text('Runs'),
                    StreamBuilder<QuerySnapshot>(
                      stream:
                      runs.snapshots(),
                      builder: (context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasData) {

                          return ListView(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            children: snapshot.data!.docs.map((run) {

                              DateTime date = run['date'].toDate();
                              DateFormat formatter = DateFormat('MM-dd-yyyy');
                              String formattedDate = formatter.format(date);

                              return Center(
                                  child: Container(
                                    margin: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Theme
                                          .of(context)
                                          .colorScheme
                                          .secondaryContainer,
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
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [Container(
                                          height: 40,
                                          width: 40,
                                          color: Theme.of(context).colorScheme.primaryContainer,
                                          child: Center(
                                            child: Text(
                                              run['qual'] ? 'Q' : 'NQ',
                                            ),
                                          )
                                        ),
                                          Text(
                                            formattedDate,
                                          ),
                                          Text(
                                            run['judge'],
                                          ),
                                          Text(
                                            run['temp'] == '-' ? 'None' : '${run['temp']}F',
                                          ),
                                          Text(
                                            run['cond'] == '-' ? 'None' : '${run['cond']}',
                                          ),
                                        ],
                                      ),
                                      //onTap: () {
//
                                      //},
                                      onLongPress: () {
                                        run.reference.delete();
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
                                    AddRun(dogId: dogId,titleId: titleId,)));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        Theme
                            .of(context)
                            .colorScheme
                            .primaryContainer,
                        foregroundColor:
                        Theme
                            .of(context)
                            .colorScheme
                            .secondary,
                        textStyle: Theme.of(context).textTheme.titleLarge,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Add Run',
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
}