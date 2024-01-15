import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'login.dart';
import 'package:intl/intl.dart';

class ParierPage extends StatefulWidget {
  @override
  _ParierPageState createState() => _ParierPageState();
}

class _ParierPageState extends State<ParierPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyApp()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
        break;
      case 2:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Connexion nécessaire'),
            content: Text('Vous devez être connecté pour parier.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
              ),
            ],
          ),
        );
      });
      return Container(); 
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'PARIER EN LIGNE',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white),

            onPressed: () async {
              // Logique de déconnexion
              await _auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MyApp()),
              );
            },
            tooltip: 'Déconnexion', 
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('users').doc(user.uid).get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;

                    return Text('Bonjour ${userData['prenom']}', style: TextStyle(fontSize: 20));
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
              StreamBuilder<QuerySnapshot>(
                stream: _firestore.collectionGroup('paris')
                    .where('parieur', isEqualTo: user!.uid)
                    .where('statut', isEqualTo: 'À venir')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasError) {
                      return Text("Erreur lors de la récupération des paris: ${snapshot.error}");
                    }
                    if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                      return Text("Vous n'avez aucun pari enregistré");
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot document = snapshot.data!.docs[index];
                        Map<String, dynamic> pariData = document.data() as Map<String, dynamic>;
                        DateTime dateDuPari = (pariData['datedupari'] as Timestamp).toDate();
                        String formattedDate = DateFormat('dd/MM/yyyy hh:mm').format(dateDuPari);


                        return Card(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Numéro du pari: ${pariData['numeroPari']}'),
                                Text('Date du pari: $formattedDate'),
                                Text('Mise: ${pariData['misechoisie']} - Gain: ${pariData['gainpossible']}'),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: pariData['resultat'] == 'gagnant' ? Colors.green : pariData['resultat'] == 'perdant' ? Colors.red : Colors.grey,
                                  ),
                                  onPressed: () {},
                                  child: Text(pariData['resultat'] ?? 'En cours de validation'),
                                ),
                                if (pariData['statut'] == 'À venir') Row(
                                  children: [
                                    Expanded( 
                                      child: ElevatedButton.icon(
                                        icon: Icon(Icons.edit),
                                        label: Text('Modifier ma mise'),
                                        onPressed: () {
                                     
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded( 
                                      child: ElevatedButton.icon(
                                        icon: Icon(Icons.delete),
                                        label: Text('Annuler mon pari'),
                                        onPressed: () {
                                    
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );



                      },
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ],
          ),
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
