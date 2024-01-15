import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'parier.dart';
import 'login.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'STUDI ECF',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
      // Reste sur la page actuelle (HomePage)
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()), 
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ParierPage()), 
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'JOUER COMPORTE DES RISQUES\nPOUR ÊTRE AIDÉ APPELER LE 09 74 75 13 13',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 16), 
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Image.asset('assets/img1.jpg', width: MediaQuery.of(context).size.width),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Description du Super Bowl...",
                style: TextStyle(fontSize: 20),
              ),
            ),
            SizedBox(height: 10),
            Container(
              height: 200,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('matchs').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  return ListView(
                    scrollDirection: Axis.horizontal,
                    children: snapshot.data!.docs.map((document) {
                      Timestamp timestamp = document['datedumatch'] as Timestamp; 
                      DateTime dateTime = timestamp.toDate(); // Convertir en DateTime
                      String dateString = DateFormat('yyyy-MM-dd – kk:mm').format(dateTime); 

                      return GestureDetector(
                        onTap: () {
                 
                        },
                        child: Card(
                          child: Container(
                            width: 160,
                            child: Column(
                              children: <Widget>[
                                Image.asset('assets/logomin.png', height: 60),
                                Text(dateString), 
                                Text('${document['equipe1']} vs ${document['equipe2']}'),
                                Text('${document['cote1']} - ${document['cote2']}'),
                                Text(document['statut']),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            SizedBox(height: 20), 
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.orange, 
                onPrimary: Colors.black, 
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ParierPage()),
                );
              },
              child: Text('Parier en ligne'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.login),
            label: 'Se Connecter',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Parier',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
