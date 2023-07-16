class Dog {
  String? id;
  String? name;
  String? breed;
  DateTime? birthdate;
  DateTime? startdate;
  String? picture;

  Dog({required this.id, this.name,this.breed,this.birthdate,this.startdate,this.picture});

  void printDog() {
    print(id);
    print(name);
    print(breed);
    print(birthdate);
    print(startdate);
    print(picture);
  }
}