import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart';
import 'package:doctor/generate_table.dart';
import 'package:doctor/catagory.dart';
// import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
// import 'package:connectivity/connectivity.dart';

dynamic hasProblem({
  trythis,
  success,
  params,
  error,
  Response response,
}) {
  try {
    if (params == null) {
      trythis(response);
    } else {
      trythis(params);
    }
    return (success);
  } catch (e) {
    print("Which errors?, are: $e");
    return (error);
  }
}

bool hasChild(object, element) {
  try {
    print(object[element]);
    return true;
  } catch (e) {
    return false;
  }
}

class Pages {
  var pages;
  bool needchange = false;

  /// Address data stored here
  /// * address.first.adminArea     // Tamil Nadu
  /// * address.first.addressLine   // Sukkangalpatti Rd, Gandi Nagar. Manthaiyamman Kovil, Cumbum, TamilNadu 625516, India,
  /// * address.first.countryCode   //IN
  /// * address.first.locality      //Cumbum
  /// * address.first.postalCode}   //625516
  /// * address.first.subAdminArea  //Theni
  /// * address.first.subLocality   //Mandhayamman Kovil
  var address;

  Pages({
    bool noconnection: true,
    context,
    language,
    int pageNumber: 0,
    list,
    details,
    Function loadDoctor,
    Function setIndex,
    dld,
    catagories,
    reload,
    Map<String, dynamic> pageState,
    address,
    insertEvent,
  }) {
    this.address = address;
    // print(jsonDecode(catagories.body).runtimeType);
    this.pages = <Widget>[
      /// Handled error for Server problem, and Internet connection problem
      /// page 1
      Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                () {
                  switch (language) {
                    case "EN":
                      return "Internet status page";
                    case "TA":
                      return "இணைய நிலை பக்கம்";
                    case "ML":
                      return "ഇന്റർനെറ്റ് സ്റ്റാറ്റസ് പേജ്";
                    case "KN":
                      return "ಇಂಟರ್ನೆಟ್ ಸ್ಥಿತಿ ಪುಟ";
                    case "TE":
                      return "ఇంటర్నెట్ స్థితి పేజీ";
                    default:
                      return "Internet status page";
                  }
                }(),
                style: Theme.of(context).textTheme.headline5,
              ),
              !noconnection
                  ? details != null
                      ? Text(
                          () {
                            switch (language) {
                              case "EN":
                                return "Internet data status being ok. ${!(this.needchange = false) ? "" : "with some error"}";
                              case "TA":
                                return "இணைய தரவு நிலை சரியாக உள்ளது. ${!(this.needchange = false) ? "" : "சில பிழைகளுடன்."}";
                              case "ML":
                                return "ഇന്റർനെറ്റ് ഡാറ്റ നില ശരിയാണ്. ${!(this.needchange = false) ? "" : "ചില പിശകുകൾക്കൊപ്പം."}";
                              case "KN":
                                return "ಇಂಟರ್ನೆಟ್ ಡೇಟಾ ಸ್ಥಿತಿ ಸರಿಯಾಗಿದೆ. ${!(this.needchange = false) ? "" : "ಕೆಲವು ದೋಷಗಳೊಂದಿಗೆ."}";
                              case "TE":
                                return "ఇంటర్నెట్ డేటా స్థితి సరే. ${!(this.needchange = false) ? "" : "కొన్ని లోపాలతో."}";
                              default:
                                return "Internet data status being ok. ${!(this.needchange = false) ? "" : "with some error"}";
                            }
                          }(),
                        )
                      : Text(
                          () {
                            switch (language) {
                              case "EN":
                                return "loading";
                              case "TA":
                                return "ஏற்றுகிறது";
                              case "ML":
                                return "ലോഡിംഗ്";
                              case "KN":
                                return "ಲೋಡ್ ಆಗುತ್ತಿದೆ";
                              case "TE":
                                return "లోడ్";
                              default:
                                return "loading";
                            }
                          }(),
                        )
                  : Text(
                      () {
                        switch (language) {
                          case "EN":
                            return "Are you in flight. ${(this.needchange == true) ? "" : "with some errors"}";
                          case "TA":
                            return "அதிக நேரம் எடுத்தால், இணைய நிலையை சரிபார்க்கவும்.";
                          case "ML":
                            return "കൂടുതൽ സമയമെടുത്താൽ ദയവായി ഇന്റർനെറ്റ് നില പരിശോധിക്കുക.";
                          case "KN":
                            return "ಇಂಟರ್ನೆಟ್ ಸ್ಥಿತಿಯನ್ನು ಪರಿಶೀಲಿಸಿ, ಅದು ಹೆಚ್ಚು ಸಮಯ ತೆಗೆದುಕೊಂಡರೆ.";
                          case "TE":
                            return "దయచేసి ఇంటర్నెట్ స్థితిని తనిఖీ చేయండి, ఎక్కువ సమయం తీసుకుంటే.";
                          default:
                            return "Are you in flight. ${(this.needchange == true) ? "" : "with some errors"}";
                        }
                      }(),
                    ),
            ],
          ),
        ),
      ),

      /// Dashboard component
      /// page 2
      /// Initial page for patients
      Stack(
        children: <Widget>[
          Container(
            child: (catagories != null)
                ? Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          Colors.black12,
                          Colors.black12,
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).padding.top,
                        ),
                        Container(
                          height: 50,
                          color: Colors.black12,
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.location_pin),
                                onPressed: () => {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: Container(
                                            color: Colors.black45,
                                            child: Center(
                                              child: Container(
                                                color: Colors.grey,
                                                height: 400,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Center(
                                                        child: Text("hello"),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Center(
                                                        child: Text("hello"),
                                                      ),
                                                    ),
                                                    // Expanded(
                                                    //   child: DropdownButton(
                                                    //     items:
                                                    //     ),
                                                    // ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      })
                                },
                              ),
                              Text(
                                (this.address != null)
                                    ? "${this.address.first.locality}, ${this.address.first.subAdminArea}"
                                    : "${language == "EN" ? "location unavailable" : language == "TA" ? "தரவு கிடைக்கவில்லை" : language == "ML" ? "ഡാറ്റ ലഭ്യമല്ല" : language == "KN" ? "ಡೇಟಾ ಲಭ್ಯವಿಲ್ಲ" : language == "TE" ? "స్స్థానం అందుబాటులో లేదు" : "location"}",
                                style: TextStyle(
                                  /// casual cursive monospace san-serif san-serif-condensed -smallcaps
                                  fontFamily: "monospace",
                                  fontSize: 22,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Spacer(
                                flex: 1,
                              ),
                              IconButton(
                                icon: Icon(Icons.menu_outlined),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: Container(
                                            color: Colors.black45,
                                            child: Center(
                                              child: Container(
                                                color: Colors.grey,
                                                height: 400,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Center(
                                                        child: Text("hello"),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Center(
                                                        child: Text("hello"),
                                                      ),
                                                    ),
                                                    // Expanded(
                                                    //   child: DropdownButton(
                                                    //     items:
                                                    //     ),
                                                    // ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                },
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 1.0, horizontal: 10.0),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: language == "EN"
                                  ? "Search for doctors/specialities"
                                  : language == "ML"
                                      ? "ഡോക്ടർ / പ്രത്യേകതകൾക്കായി തിരയുക"
                                      : language == "TA"
                                          ? "மருத்துவர் / சிறப்புகளைத் தேடுங்கள்"
                                          : language == "KN"
                                              ? "ವೈದ್ಯರು / ವಿಶೇಷತೆಗಳಿಗಾಗಿ ಹುಡುಕಿ"
                                              : language == "TE"
                                                  ? "డాక్టర్ / ప్రత్యేకతల కోసం శోధించండి"
                                                  : "Search for doctors/specialities",
                            ),
                            autocorrect: false,
                            style: TextStyle(
                              fontSize: 26,
                              color: Colors.black54,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.start,
                            maxLength: 30,
                            cursorHeight: 26,
                            onChanged: (string) {
                              pageState["templist"].clear();
                              catagories.forEach((element) {
                                // print(element);
                                if (element["name"]
                                        .toString()
                                        .toLowerCase()
                                        .contains(string.toLowerCase()) ||
                                    element["catagory"]
                                        .toString()
                                        .toLowerCase()
                                        .contains(string.toLowerCase())) {
                                  List temp = pageState["templist"];
                                  temp.add(element);
                                  reload(() {
                                    pageState.update(
                                        "templist", (value) => temp);
                                  });
                                  temp = null;
                                }
                              });
                              reload(() {
                                pageState.update(
                                    "show_overlay", (value) => true);
                              });
                            },
                            onEditingComplete: () {
                              reload(() {
                                pageState.update(
                                    "show_overlay", (value) => false);
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            children: [
                              GridView.count(
                                primary: true,
                                physics: ScrollPhysics(),
                                padding: EdgeInsets.all(10),
                                mainAxisSpacing: 10,
                                crossAxisCount: (MediaQuery.of(context)
                                            .size
                                            .height <
                                        MediaQuery.of(context).size.width)
                                    ? (2 * MediaQuery.of(context).size.height <
                                            MediaQuery.of(context).size.width)
                                        ? 4
                                        : 3
                                    : 2,
                                crossAxisSpacing: 10,
                                shrinkWrap: true, //no scroll physics
                                children: (dld != null)
                                    ? Doctors(
                                        doctorlist: dld,
                                        loadList: loadDoctor,
                                        setIndex: setIndex,
                                        reload: reload,
                                        pageState: pageState,
                                        district:
                                            this.address.first.subAdminArea,
                                        language: language,
                                      ).doctorList()
                                    : [
                                        Container(
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.white30,
                                                spreadRadius: 0.0,
                                                blurRadius: 10.0,
                                              ),
                                            ],
                                          ),
                                          child: Card(
                                            elevation: 0.0,
                                            color: Colors.white24,
                                            shape: RoundedRectangleBorder(),
                                            shadowColor: Colors.transparent,
                                            child: Text(
                                              "${(language == "EN") ? "Problem occurred." : language == "ML" ? "പ്രശ്നം സംഭവിച്ചു." : language == "TA" ? "சிக்கல் ஏற்பட்டது." : language == "KN" ? "ಸಮಸ್ಯೆ ಸಂಭವಿಸಿದೆ." : language == "TE" ? "సమస్య సంభవించింది" : "problem occurred."}",
                                            ),
                                          ),
                                        ),
                                      ],
                              ),
                              // SizedBox(
                              //   child: Padding(
                              //     padding: const EdgeInsets.symmetric(
                              //       vertical: 20,
                              //     ),
                              //     child: Column(
                              //       mainAxisAlignment: MainAxisAlignment.end,
                              //       children: [
                              //         ElevatedButton.icon(
                              //           icon: Icon(
                              //             CupertinoIcons
                              //                 .arrow_up_left_arrow_down_right,
                              //             size: 20,
                              //           ),
                              //           onPressed: () {
                              //             setIndex(2);
                              //           },
                              //           label: Text(
                              //             "${(language == "EN") ? "See all specialities" : language == "ML" ? "എല്ലാ സവിശേഷതകളും കാണുക" : language == "TA" ? "அனைத்து சிறப்புகளையும் காண்க" : language == "KN" ? "ಎಲ್ಲಾ ವಿಶೇಷತೆಗಳನ್ನು ನೋಡಿ" : language == "TE" ? "అన్ని ప్రత్యేకతలు చూడండి" : "See all specialities"}",
                              //           ),
                              //         ),
                              //         ElevatedButton.icon(
                              //           icon: Icon(
                              //             CupertinoIcons.bookmark_fill,
                              //             size: 20,
                              //           ),
                              //           onPressed: () {
                              //             setIndex(3);
                              //           },
                              //           label: Text(
                              //             "${(language == "EN") ? "My appointments" : language == "ML" ? "എന്റെ കൂടിക്കാഴ്‌ചകൾ" : language == "TA" ? "எனது நியமனங்கள்" : language == "KN" ? "ನನ್ನ ನೇಮಕಾತಿಗಳು" : language == "TE" ? "నా నియామకాలు" : "My appointments"}",
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    child: Text(
                      "${(language == "EN") ? "Server problem, contact Admin." : language == "ML" ? "സെർവർ പ്രശ്നം, അഡ്‌മിനുമായി ബന്ധപ്പെടുക." : language == "TA" ? "சேவையக சிக்கல், நிர்வாகியைத் தொடர்பு கொள்ளுங்கள்." : language == "KN" ? "ಸರ್ವರ್ ಸಮಸ್ಯೆ, ನಿರ್ವಾಹಕರನ್ನು ಸಂಪರ್ಕಿಸಿ." : language == "TE" ? "సర్వర్ సమస్య, నిర్వాహకుడిని సంప్రదించండి." : "Server problem, contact Admin."}",
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
          ),
          if (pageState['show_overlay'])
            Positioned(
              left: MediaQuery.of(context).size.height * 0.05,
              right: MediaQuery.of(context).size.height * 0.05,
              top: 100 + MediaQuery.of(context).padding.top,
              bottom: MediaQuery.of(context).size.height * 0.05,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white70,
                ),
                child: ListView(
                  children: (pageState["templist"].length > 0)
                      ? pageState["templist"]
                          .map<Widget>((object) => ListTile(
                              // leading: Text("leading"),  /// This can be estabilised if nessesary.
                              title: Text(
                                "${object['name']}", // name
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle:
                                  Text("${object['catagory']}"), // catagory
                              onTap: () async {
                                await loadDoctor('dd',
                                    term: Uri(queryParameters: {
                                      "name": object['name'],
                                      "catagory": object['catagory']
                                    }).query);
                                reload(() {
                                  pageState.update(
                                      "show_overlay", (value) => false);
                                });
                                setIndex(2);
                              }))
                          .toList()
                      : [
                          ListTile(
                            title: Text(
                              "${(language == "EN") ? "No data found." : language == "ML" ? "ഡാറ്റയൊന്നും കണ്ടെത്തിയില്ല." : language == "TA" ? "வேறு தகவல்கள் இல்லை." : language == "KN" ? "ಯಾವುದೇ ಡೇಟಾ ಕಂಡುಬಂದಿಲ್ಲ." : language == "TE" ? "డేటా కనుగొనబడలేదు." : "No data found."}",
                            ),
                          ),
                          ListTile(
                            tileColor: Colors.blueAccent,
                            title: Text(
                              "${(language == "EN") ? "Find specialities" : language == "ML" ? "പ്രത്യേകതകൾ കണ്ടെത്തുക" : language == "TA" ? "சிறப்புகளைத் தேடுங்கள்" : language == "KN" ? "ವಿಶೇಷತೆಗಳನ್ನು ಹುಡುಕಿ" : language == "TE" ? "ప్రత్యేకతలను కనుగొనండి" : "Find specialities"}",
                              style: TextStyle(
                                  color: Colors.lightBlue,
                                  fontWeight: FontWeight.bold),
                            ),
                            onTap: () {
                              setIndex("dlc", key: "catagory");
                            },
                          )
                        ],
                ),
              ),
            ),
        ],
      ),

      // Doctor's profile
      // page 3
      (details != null &&
              () {
                // print(details);
                // print(details.runtimeType);
                return details.isNotEmpty;
              }())
          ? Container(
              color: Colors.grey[300],
              child: ListView(
                children: <Widget>[
                  new UserAccountsDrawerHeader(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      image: new DecorationImage(
                        image: AssetImage('assets/banner.png'),
                        fit: BoxFit.fill,
                      ),
                      color: Colors.blue,
                    ),
                    accountName: (details == null)
                        ? new Text("Unavailable")
                        : new Text("Dr. ${details[0]['name']}"),
                    accountEmail: (details == null)
                        ? new Text("Unavailable")
                        : new Text("${details[0]['catagory']}"),
                    currentAccountPicture: new GestureDetector(
                      onTap: () {
                        new AlertDialog(
                          title: Text("?"),
                        );
                      },
                      child: new CircleAvatar(
                        backgroundImage: AssetImage('assets/banner.png'),
                      ),
                    ),
                  ),
                  Text(
                    "About:",
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  Text(
                    ' \t \t Dr. ${details[0].containsKey('catagory') ? details[0]['name'] : "unavailable"}(${details[0]['catagory']}) ${details[0].containsKey('hospital') ? 'is working in ' + details[0]['hospital'] : ''}${details[0].containsKey('experience') ? ' with the experience of' + details[0]['experience'] + ' years' : ''}.\n ',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    "Details:",
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  Text(
                    '${details[0].containsKey('catagory') ? 'Catagory: ' + details[0]['catagory'] + '\n' : ''}${details[0].containsKey('hospital') ? 'Hospital: ' + details[0]['hospital'] + '\n' : ''}${details[0].containsKey('experience') ? 'Experience: ' + details[0]['experience'] + '\n' : ''}${details[0].containsKey('specialist') ? 'Specialist: ' + details[0]['specialist'] + '\n' : ''}${details[0].containsKey('surgery') ? 'No. of surgeries: ' + details[0]['surgery'] + '\n' : ''}${details[0].containsKey('available') ? 'Availability: ' + (details[0]['available'] ? 'Available' : 'Unavailable') + '\n' : ''}${details[0].containsKey('office') ? 'Branch: ' + details[0]['office'] : ''}\n',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  details[0].containsKey('available')
                      ? ElevatedButton(
                          onPressed: () {
                            setIndex(pageNumber + 1);
                          },
                          child: Text("Book"),
                        )
                      : ElevatedButton(
                          onPressed: () {},
                          child: Text("Book"),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Colors.redAccent[400]),
                          ),
                        ),
                ],
              ),
            )
          : Container(
              child: Center(
                child: Text(
                  language == "EN"
                      ? "Seems to be problem."
                      : language == "ML"
                          ? "പ്രശ്‌നമാണെന്ന് തോന്നുന്നു."
                          : language == "TA"
                              ? "பிரச்சனையாகத் தெரிகிறது."
                              : language == "KN"
                                  ? "ಸಮಸ್ಯೆ ಇದೆ ಎಂದು ತೋರುತ್ತದೆ."
                                  : language == "TE"
                                      ? "సమస్యగా ఉంది."
                                      : "Seems to be problem.",
                ),
              ),
            ),

      //schedule timing
      // page 4
      Container(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).padding.top,
            ),
            Title(
              color: Colors.black,
              child: (details != null && details.isNotEmpty)
                  ? new Text(
                      "Dr. ${details[0]['name']}'s schedule",
                      style: TextStyle(
                        fontSize: 24.0,
                        color: Colors.black38,
                      ),
                    )
                  : new Text(""
                      // "${(language == "EN") ? "Unavailable" : language == "ML" ? "ലഭ്യമല്ല" : language == "TA" ? "கிடைக்கவில்லை" : language == "KN" ? "ಲಭ್ಯವಿಲ್ಲ" : language == "TE" ? "అందుబాటులో లేదు" : "data Unavailable"}",
                      ),
            ),
            SizedBox(
              height: 5,
            ),
            Expanded(
              child: ListView(
                  // color: Colors.blueGrey[600],
                  children: [
                    (details != null && details.isNotEmpty)
                        ? new Schedule(details[0]).create()
                        : new Table(
                            children: [
                              TableRow(children: [
                                TableCell(
                                  child: Text(
                                    "${(language == "EN") ? "Couldn't create schedule" : language == "ML" ? "ഷെഡ്യൂൾ സൃഷ്ടിക്കാൻ കഴിഞ്ഞില്ല" : language == "TA" ? "அட்டவணையை உருவாக்க முடியவில்லை" : language == "KN" ? "ವೇಳಾಪಟ್ಟಿಯನ್ನು ರಚಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ" : language == "TE" ? "షెడ్యూల్‌ను సృష్టించడం సాధ్యం కాలేదు" : "Couldn't create schedule"}",
                                  ),
                                )
                              ])
                            ],
                          ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          String value = "";
                          if (details[0].containsKey('email')) {
                            () async {
                              await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        color: Colors
                                            .black45, // make it for shadow
                                        padding: EdgeInsets.all(10),
                                        child: Center(
                                          child: GestureDetector(
                                            onTap: () {},
                                            child: Container(
                                              decoration: BoxDecoration(
                                                boxShadow: <BoxShadow>[
                                                  BoxShadow(
                                                    color: Colors.white38,
                                                    blurRadius: 5,
                                                    spreadRadius: 3,
                                                  ),
                                                ],
                                              ),
                                              // color: Colors.grey,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  3,
                                              child: Card(
                                                child: Padding(
                                                  padding: EdgeInsets.all(5),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .stretch,
                                                    children: [
                                                      TextField(
                                                        decoration:
                                                            InputDecoration(
                                                          hintText:
                                                              "Purpose/Reason",
                                                        ),
                                                        onChanged: (val) {
                                                          value = val;
                                                        },
                                                      ),
                                                      ElevatedButton(
                                                        child: Text("Submit"),
                                                        onPressed: () {
                                                          if (value != "") {
                                                            insertEvent(
                                                                reason:
                                                                    "$value",
                                                                to: details[0]
                                                                    ['email'],
                                                                startTime: DateTime
                                                                        .now()
                                                                    .add(Duration(
                                                                        seconds:
                                                                            10)));
                                                            showDatePicker(
                                                              context: context,
                                                              firstDate: null,
                                                              initialDate: null,
                                                              lastDate: null,
                                                            );
                                                            Navigator.pop(
                                                                context);
                                                          }
                                                        },
                                                      ),
                                                      // Expanded(
                                                      //   child: DropdownButton(
                                                      //     items:
                                                      //     ),
                                                      // ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  });
                            }();
                          } else {
                            () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Doctor email not found'),
                                ),
                              );
                              print(
                                  "No Doctor email present. Do you want to know more about this issue?");
                              print("${details[0]}");
                            }();
                          }
                          var now = new DateTime.now();
                          print(now.weekday);
                        },
                        // () {
                        //   showDialog(
                        //       context: context,
                        //       builder: (BuildContext context) {
                        //         return GestureDetector(
                        //           onTap: () {
                        //             Navigator.pop(context);
                        //           },
                        //           child: Container(
                        //             color: Colors.black45,
                        //             child: Center(
                        //               child: Container(
                        //                 color: Colors.grey,
                        //                 height: 400,
                        //                 child: Row(
                        //                   children: [
                        //                     Expanded(
                        //                       child: Center(
                        //                         child: Text("hello"),
                        //                       ),
                        //                     ),
                        //                     Expanded(
                        //                       child: Center(
                        //                         child: Text("hello"),
                        //                       ),
                        //                     ),
                        //                     // Expanded(
                        //                     //   child: DropdownButton(
                        //                     //     items:
                        //                     //     ),
                        //                     // ),
                        //                   ],
                        //                 ),
                        //               ),
                        //             ),
                        //           ),
                        //         );
                        //       });
                        // },
                        child: Text("Make Appointment"), //Show digitally
                      ),
                    ),
                  ]),
            )
          ],
        ),
      ),

      /// // Tiles...
      /// // page 5
      Container(
        color: Colors.grey[300],
        padding: EdgeInsets.all(5),
        child: ListView(scrollDirection: Axis.vertical, children:
                // tile.isEmpty()?
                [
          Text(
            language == "EN"
                ? "No doctors available at the moment."
                : language == "ML"
                    ? "ഇപ്പോൾ ഡോക്ടർമാരാരും ലഭ്യമല്ല."
                    : language == "TA"
                        ? "தற்போது மருத்துவர்கள் யாரும் கிடைக்கவில்லை."
                        : language == "KN"
                            ? "ಈ ಸಮಯದಲ್ಲಿ ಯಾವುದೇ ವೈದ್ಯರು ಲಭ್ಯವಿಲ್ಲ."
                            : language == "TE"
                                ? "ప్రస్తుతానికి వైద్యులు అందుబాటులో లేరు."
                                : "No doctors available at the moment.",
          ),
        ]
            // : tile.tiles(),
            ),
      ),
    ];
  }

  createPages() {
    return (this.pages);
  }
}
