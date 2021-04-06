import 'package:flutter/material.dart';
// import 'package:googleapis/dfareporting/v3_4.dart';

class Catagory {
  List<Widget> catagory;
  int index = 0;
  Catagory({List catagory, Function setIndex, Function loadList}) {
    // print(catagory);
    catagory.length != 0
        ? this.catagory = catagory
            .map<Widget>((cat) => Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white30,
                        spreadRadius: 0.0,
                        // offset: Offset(2, 2),
                        blurRadius: 10.0,
                      ),
                    ],
                  ),
                  child: Card(
                    elevation: 10.0,
                    margin: EdgeInsets.all(8.0),
                    color: Colors.white54,
                    // shape: RoundedRectangleBorder(),24
                    shadowColor: Colors.transparent,
                    child: GestureDetector(
                      onTap: () async {
                        await loadList("", catagory: cat);
                        setIndex(2);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                // color: Colors.grey,
                                border: Border(
                                  left: BorderSide(
                                    width: 10,
                                    color: Colors.black38,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    " ${cat['name']}",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    " ${cat['catagory']}",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.black45,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              // color: Colors.black12,
                              padding: EdgeInsets.symmetric(horizontal: 6.0),
                              child: Column(
                                children: [
                                  Container(
                                    color: Colors.blueAccent,
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Book Now",
                                      textAlign: TextAlign.left,
                                      // textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: NetworkImage(
                                            ("photoUrl".isNotEmpty)
                                                ? "https://i.ibb.co/yg3J9vs/400149000994-35050.jpg"
                                                : "https://i.ibb.co/yg3J9vs/400149000994-35050.jpg",
                                          ),
                                          radius: 18,
                                          foregroundColor: Colors.black,
                                          backgroundColor: Colors.black,
                                        ),
                                        Transform(
                                          transform: Matrix4.translationValues(
                                              -20, 0, -1),
                                          child: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                              "https://i.ibb.co/yg3J9vs/400149000994-35050.jpg",
                                            ),
                                            onBackgroundImageError:
                                                (exception, stackTrace) => null,
                                            radius: 18,
                                            foregroundColor: Colors.black38,
                                          ),
                                        ),
                                        Transform(
                                          transform: Matrix4.translationValues(
                                              -40, 0, -2),
                                          child: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                              "https://i.ibb.co/yg3J9vs/400149000994-35050.jpg",
                                            ),
                                            radius: 18,
                                            foregroundColor: Colors.black12,
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ))
            .toList()
        : this.catagory = <Widget>[
            Text("Some problem occured, please try again"),
          ];
  }

  List<Widget> catagories() {
    return (this.catagory);
  }
}

class Doctors {
  List<Widget> doctor;
  int index = 0;
  Doctors({
    List doctorlist,
    Function setIndex,
    Function loadList,
    String district,
    Map<String, dynamic> pageState,
    reload,
    language,
  }) {
    // print(doctorlist);
    // print(district);
    // print("\n\n\n\n\n\n\n\n\n");
    // print(doctorlist);
    doctorlist.length != 0
        ? this.doctor = doctorlist
            .map<Widget>((doc) => Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white30,
                        spreadRadius: 0.0,
                        // offset: Offset(2, 2),
                        blurRadius: 10.0,
                      ),
                    ],
                  ),
                  child: Card(
                    elevation: 10.0,
                    margin: EdgeInsets.all(0.0),
                    color: Colors.white54,
                    // shape: RoundedRectangleBorder(),24
                    shadowColor: Colors.transparent,
                    child: GestureDetector(
                      onTap: () async {
                        await loadList('dd',
                            term: Uri(queryParameters: {
                              "name": doc['name'],
                              "catagory": doc['catagory']
                            }).query);
                        reload(() {
                          pageState.update("show_overlay", (value) => false);
                        });
                        setIndex(2);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            color: Colors.black12,
                            // flex:1,
                            // decoration: BoxDecoration(
                            // color: Colors.black12,
                            // ),
                            child: ListTile(
                              leading: new CircleAvatar(
                                backgroundImage: doc.containsKey('photoUrl')
                                    ? NetworkImage(doc['photoUrl'])
                                    : AssetImage('assets/banner.png'),
                                maxRadius: 12,
                              ),
                              horizontalTitleGap: 0,
                              title: Text(
                                "${doc['name'].toString().toUpperCase()}",
                                textAlign: TextAlign.left,
                                // textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              trailing: Icon(Icons.favorite_outline, size: 20),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                SingleChildScrollView(
                                  child: Container(
                                    // color: Colors.blueAccent,
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "${doc.containsKey('catagory') ? doc['catagory'] : " unavailable"} \n ${doc.containsKey('office') ? doc['office'] : ""} ",
                                      textAlign: TextAlign.left,
                                      // textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  // crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    ElevatedButton(
                                      onPressed: () async {
                                        await loadList('dd',
                                            term: Uri(queryParameters: {
                                              "name": doc['name'],
                                              "catagory": doc['catagory']
                                            }).query);
                                        reload(() {
                                          pageState.update(
                                              "show_overlay", (value) => false);
                                        });
                                        setIndex(2);
                                      },
                                      child: Text(
                                        "${(language == "EN") ? "Know more" : language == "ML" ? "കൂടുതലറിയാൻ" : language == "TA" ? "மேலும் அறிய" : language == "KN" ? "ಇನ್ನಷ್ಟು ತಿಳಿಯಲು" : language == "TE" ? "ప్మరింత తెలుసుకోవడానికి" : "Know more"}",
                                        style: TextStyle(
                                          fontSize: 8,
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        await loadList('dd',
                                            term: Uri(queryParameters: {
                                              "name": doc['name'],
                                              "catagory": doc['catagory']
                                            }).query);
                                        reload(() {
                                          pageState.update(
                                              "show_overlay", (value) => false);
                                        });
                                        setIndex(2);
                                      },
                                      child: Text(
                                        "${(language == "EN") ? "Appointment" : language == "ML" ? "നിയമനം" : language == "TA" ? "நியமனம்" : language == "KN" ? "ನೇಮಕಾತಿ" : language == "TE" ? "ప్నియామకం" : "Know more"}",
                                        style: TextStyle(
                                          fontSize: 8,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ))
            .toList()
        : this.doctor = <Widget>[
            Text("Some problem occured, please try again"),
          ];
  }

  List<Widget> doctorList() {
    return (this.doctor);
  }
}

// /// Backup
// Container(
//                  decoration: BoxDecoration(
//                    boxShadow: [
//                      BoxShadow(
//                        color: Colors.white30,
//                        spreadRadius: 0.0,
//                        // offset: Offset(2, 2),
//                        blurRadius: 10.0,
//                      ),
//                    ],
//                  ),
//                  child: Card(
//                    elevation: 10.0,
//                    margin: EdgeInsets.all(8.0),
//                    color: Colors.white54,
//                    // shape: RoundedRectangleBorder(),24
//                    shadowColor: Colors.transparent,
//                    child: GestureDetector(
//                      onTap: () async {
//                        await loadList(1, catagory: cat);
//                        setIndex(3);
//                      },
//                      child: Column(
//                        crossAxisAlignment: CrossAxisAlignment.stretch,
//                        children: [
//                          // Expanded(
//                          //   child: Image.network(
//                          //     // "https://i.ibb.co/yg3J9vs/400149000994-35050.jpg",
//                          //     /// Doctor's photo url
//                          //     fit: BoxFit.cover,
//                          //   ),
//                          // ),
//                          Expanded(
//                            child: Container(
//                              decoration: BoxDecoration(
//                                color: Colors.grey,
//                                border: Border(
//                                  left: BorderSide(
//                                    width: 10,
//                                    color: Colors.black38,
//                                  ),
//                                ),
//                              ),
//                              child: Text(
//                                "$cat",
//                                textAlign: TextAlign.left,
//                                // textAlign: TextAlign.center,
//                                style: TextStyle(
//                                  color: Colors.black54,
//                                  fontSize: 18,
//                                  fontWeight: FontWeight.w700,
//                                ),
//                              ),
//                            ),
//                          ),
//                          Expanded(
//                            child: Column(
//                              children: [
//                                Container(
//                                  color: Colors.blueAccent,
//                                  padding: const EdgeInsets.all(8.0),
//                                  child: Text(
//                                    "$cat",
//                                    textAlign: TextAlign.left,
//                                    // textAlign: TextAlign.center,
//                                    style: TextStyle(
//                                      color: Colors.black54,
//                                      fontSize: 18,
//                                      fontWeight: FontWeight.w700,
//                                    ),
//                                  ),
//                                ),
//                                Text("{description}"),
//                              ],
//                            ),
//                          ),
//                        ],
//                      ),
//                    ),
//                  ),
//                ))
