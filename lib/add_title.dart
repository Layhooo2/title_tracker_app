
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'auth.dart';

class AddTitle extends StatefulWidget {
  final String dogId;

  AddTitle({Key? key, required this.dogId}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AddTitleState();
  }
}
class AddTitleState extends State<AddTitle> {

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Auth auth = Auth();


  List<String> ranks = ['Novice', 'Open', 'Excellent', 'Master'];
  List<String> novice_titles = ['NA', 'NAJ'];
  List<String> open_titles = ['OA', 'OAJ'];
  List<String> excellent_titles = ['AX', 'AXJ'];
  List<String> master_titles = ['MX', 'MXJ'];
  String selectedRank = 'Novice';
  String selectedNoviceTitle = 'NA';
  String selectedOpenTitle = 'OA';
  String selectedExcellentTitle = 'AX';
  String selectedMasterTitle = 'MX';
  bool completed = false;
  late int needed;
  int count = 0;
  late String selectedTitle;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Title', style: Theme.of(context).textTheme.headlineLarge,),
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .primaryContainer,
      ),
      body: Center(
        child: Column(
          children: [
            Text('Class'),
            rankDrop(),
            Text('Title'),
            titleDrop(),
            Text('Earned?'),
            Checkbox(
              value: completed,
              onChanged: (bool? value) {
                setState(() {
                  completed = value ?? false;
                });
              },
            ),
            Text(completed ? 'Yes' : 'No'),
            TextButton(
              onPressed: () {
                setState(() {
                  if (selectedRank == 'Novice') {
                    needed = 3;
                    selectedTitle = selectedNoviceTitle;
                  }
                  else if (selectedRank == 'Open') {
                    needed = 3;
                    selectedTitle = selectedOpenTitle;
                  }
                  else if (selectedRank == 'Excellent') {
                    needed = 3;
                    selectedTitle = selectedOpenTitle;
                  }
                  else if (selectedRank == 'Master') {
                    needed = 10;
                    selectedTitle = selectedOpenTitle;
                  }
                });
                addTitle();
                print('Title added');
                Navigator.pop(context);
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
              ),
              child: const Text(
                'Add!',
                //style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          ],
        )
      ),
    );
  }

  Future<void> addTitle() async {
    String? userId = auth.getUserId();

    DocumentReference userDoc = firestore.collection('users').doc(userId);
    CollectionReference dogCol = userDoc.collection('dogs');
    DocumentReference dogDoc = dogCol.doc(widget.dogId);

    Map<String, dynamic> titleData = {
      //'dogid': widget.dogId,
      'class': selectedRank,
      'title': selectedTitle,
      'count': count,
      'needed': needed,
      'complete': completed,
    };
    await dogDoc.collection('titles').add(titleData);
  }


  Widget completeDrop() {
    return DropdownButton<String>(
        value: selectedRank,
        items: ranks.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: (String? selected) {
          setState(() {
            selectedRank = selected!;
          });
        }
    );
  }

  Widget rankDrop() {
    return DropdownButton<String>(
        value: selectedRank,
        items: ranks.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: (String? selected) {
          setState(() {
            selectedRank = selected!;
          });
        }
        );
  }

  Widget titleDrop() {
    if (selectedRank == 'Novice') {
      return DropdownButton<String>(
          value: selectedNoviceTitle,
          items: novice_titles.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: (String? selected) {
            setState(() {
              selectedNoviceTitle = selected!;
            });
          }
      );
    }
    else if (selectedRank == 'Open') {
      return DropdownButton<String>(
          value: selectedOpenTitle,
          items: open_titles.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: (String? selected) {
            setState(() {
              selectedOpenTitle = selected!;
            });
          }
      );
    }
    else if (selectedRank == 'Excellent') {
      return DropdownButton<String>(
          value: selectedExcellentTitle,
          items: excellent_titles.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: (String? selected) {
            setState(() {
              selectedExcellentTitle = selected!;
            });
          }
      );

    }
    else if (selectedRank == 'Master') {
      return DropdownButton<String>(
          value: selectedMasterTitle,
          items: master_titles.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: (String? selected) {
            setState(() {
              selectedMasterTitle = selected!;
            });
          }
      );
    }
    else {
      return Text('Error');
    }
  }
}