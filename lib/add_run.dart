import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

import 'package:title_tracker_app/auth.dart';

class AddRun extends StatefulWidget {
  final dogId;
  final titleId;

  AddRun({Key? key, required this.dogId, required this.titleId})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return AddRunState();
  }
}

class AddRunState extends State<AddRun> {
  PickedFile? imageFile;
  ImagePicker picker = ImagePicker();

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  Auth auth = Auth();

  bool qual = false;
  DateTime date = DateTime.now();
  String judge = 'none';
  //int temp = 0;

  double lat = 0;
  double lon = 0;

  String temperature = '-';
  String condition = '-';

  //DateTime startdate = DateTime(2023,01,01);

  @override
  Widget build(BuildContext context) {
    DocumentReference userDoc =
        firestore.collection('users').doc(auth.getUserId());
    CollectionReference dogCol = userDoc.collection('dogs');
    DocumentReference dogDoc = dogCol.doc(widget.dogId);
    CollectionReference titleCol = dogDoc.collection('titles');
    DocumentReference titleDoc = titleCol.doc(widget.titleId);
    CollectionReference runs = titleDoc.collection('runs');

    //getCurrentLocation();

    Future<void> setNumberOfQ() async {
      int total = 0;
      runs.where('qual', isEqualTo: true).get().then(
            (querySnapshot) {
          total = querySnapshot.size;
          //print(total);
          titleDoc.update({'count': total});
        },
        onError: (e) => print("Error completing: $e"),
      );
    }

    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text('Add Run'),
          titleTextStyle: Theme.of(context).textTheme.headlineLarge,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(children: [
              Container(
                margin: const EdgeInsets.all(10),
                //color: Theme.of(context).colorScheme.secondaryContainer,
                child: Column(
                  children: [const Text('Qualified?'),
                    Checkbox(
                      value: qual,
                      onChanged: (bool? value) {
                        setState(() {
                          qual = value ?? false;
                        });
                      },
                    ),],
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
                      Text('${date.month}-${date.day}-${date.year}',
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
                          setState(() => date = newDate);
                        },

                      ),],
                  )
              ),
              Container(
                margin: const EdgeInsets.all(10),
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Judge',
                    ),
                    onChanged: (val) {
                      judge = val;
                    }),
              ),
              Container(
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
                //color: Theme.of(context).colorScheme.secondaryContainer,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //children: [Text('hi')],
                  children: [
                    Text(temperature.toString(), style: Theme.of(context).textTheme.headlineSmall,),
                    Text(condition.toString(), style: Theme.of(context).textTheme.headlineSmall,),
                    ElevatedButton(
                      onPressed: () async {
                        getCurrentLocation();
                        getCurrentWeather();
                      },
                      child: const Icon(Icons.cloud),
                    ),
                  ],
                )
              ),
              TextButton(
                onPressed: () async {
                  addRun(runs);
                  setNumberOfQ();
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
              ),
            ]),
          ),
        ));
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Disabled');
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      print('Denied');
      return;
    }
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        print('Denied');
        return;
      }
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      lat = position.latitude;
      lon = position.longitude;
    });
    //print(lat);
    //print(lon);

  }

  Future<void> getCurrentWeather() async {
    while (lat == 0) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    String apiKey = '5ff2939855904c8aa7e44538231507';
    String url = 'https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$lat,$lon&aqi=no';

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);

      var temp = jsonResponse['current']['temp_f'];
      var cond = jsonResponse['current']['condition']['text'];

      print(temp);
      print(cond);
      //if (temperature != '-') {
        setState(() {
          temperature = temp.toString();
          condition = cond.toString();
        });
      //}
      print('Temperature: $temperature °F');
      print('Condition: $condition');
    } else {
      // Request failed
      print('Request failed with status: ${response.statusCode}');
    }
  }


  Future<void> addRun(runs) async {
    Map<String, dynamic> runData = {
      'qual': qual,
      'date': date,
      'judge': judge,
      'temp': temperature,
      'cond': condition
    };
    await runs.add(runData);
  }
}
