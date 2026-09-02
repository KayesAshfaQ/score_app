import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> addUser() async {
    final fireStore = FirebaseFirestore.instance;

    CollectionReference users = fireStore.collection('users');

    await users.add({'name': 'Jhon', 'age': 35, 'isStudent': false});

    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('User added successfully')));
  }

  Future<void> getUsers() async {
    final fireStore = FirebaseFirestore.instance;

    QuerySnapshot querySnapshot = await fireStore.collection('users').get();
    List<QueryDocumentSnapshot> documents = querySnapshot.docs;

    for (var document in documents) {
      if (kDebugMode) {
        print(document.data());
      }
    }
  }

  Future<void> updateUser() async {
    final fireStore = FirebaseFirestore.instance;
    CollectionReference users = fireStore.collection('users');

    await users.doc('sZMf9LwZ0NmOtm7F4yZS').update({
      'name': 'Kayes',
      'age': 25,
      'isStudent': false,
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('User updated successfully')));
  }

  Future<void> deleteUser() async {
    final fireStore = FirebaseFirestore.instance;
    CollectionReference users = fireStore.collection('users');
    await users.doc('CajHN9NAwotg0dAnHO04').delete();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('User deleted successfully')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            TextButton(
              onPressed: addUser,
              child: Text('Add User to firestore.'),
            ),
            TextButton(
              onPressed: getUsers,
              child: Text('fetch User data from firestore.'),
            ),
            TextButton(onPressed: updateUser, child: Text('Update user')),
            TextButton(onPressed: deleteUser, child: Text('Delete user')),
          ],
        ),
      ),
    );
  }
}
