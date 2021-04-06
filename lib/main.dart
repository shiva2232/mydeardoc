import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:doctor/tiles.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:http/http.dart';
import 'package:doctor/pages.dart';
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:file_picker/file_picker.dart';
import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';
import 'package:url_launcher/url_launcher.dart';

// import 'dart:math';
// import 'package:doctor/authentication_service.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:provider/provider.dart';
// import 'package:file/file.dart';
// import 'package:doctor/doctors_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  // add this "SystemUiOverlay.values" to below to get rid of ui custom overlays
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  await FlutterSecureStorage().read(key: 'term').then((value) {
    runApp(DoctorApp());
  });
}

class DoctorApp extends StatelessWidget {
  /// This widget is the root of your application.
  /// LoginPage loginPage = new LoginPage();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: 'Asthra',
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      // home: _loggedIn ? HomePage() : LoginPage(),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// These data are provided to the general application details this does not contain user specific data
  /// i.e routes, tab structure, schema(application) and page numbers.

  /// **Secure Storage block**
  /// This data does not mean runtime data options it stores permanent data which can be altered at any time in future
  /// deals with auth(Google) credential.
  final storage = new FlutterSecureStorage();

  /// tab data
  var tabs;
  var manLoc = '';

  /// is it signed as a Doctor?
  bool isDoctor = false;

  /// does the app is signed in using google account?
  bool isSignIn = false;

  /// This index route only available for the doctor.
  /// * Patients routes are stored in current index
  int doctorIndex = 0;

  /// Always 0
  int _initIndex = 0;

  Map<String, String> lang = {
    'ENGLISH': 'EN',
    'KANNADA': 'KN',
    'MALAYALAM': 'ML',
    'TAMIL': 'TA',
    'TELUGU': 'TE',
  };

  /// *** Current Index is the indexing service for application ***
  /// * 0 => Internet status check
  /// * 1 => LoginPage (Welcome doctor)
  /// * 3 => Search panel
  /// * 4 => Tiles...
  /// * 5 => About MyDearDoc
  /// * 6 => profile Asthra
  /// * 7 => profile doctor
  /// * 8 => doctor schedule(Appointment activity)
  /// **************************************************************
  int _currentIndex = 1;

  /// Internet Status[bool]
  bool noConnection = true;

  /// blanck tiles to reduce error
  Tile tile = new Tile();

  /// form key used for doctor forms.
  final _formKey = GlobalKey<FormState>();

  /// *EditMode Available only for doctor*
  ///
  /// **To Do:**
  /// * In future it should be available to patient
  bool _editMode = false;

  /// **For initial screen for swiping page**
  /// Features display page
  changeIndex(_index) {
    return new IconButton(
      icon: Icon(
        _initIndex != _index
            ? Icons.radio_button_off_rounded
            : Icons.radio_button_on_rounded,
        size: 14.0,
      ),
      onPressed: () {
        pageController.animateToPage(_index,
            duration: Duration(seconds: 1), curve: Curves.easeInCubic);
      },
    );
  }

  /// **This page controller is used for navigate among patient's pages**
  /// * initial index is 0
  /// * don't use it for doctor's app
  final pageController = new PageController(
    initialPage: 0,
  );

  /// These below variables are used to store temprovery data that is stored in gc.
  /// Fully retrivied from account(google) and user specific data and modified to store remove in future.

  ///
  ///  **Google SignIn**
  ///
  ///  This contains user specific data retrieved by the google authentication.
  ///
  ///  This contains Schema of the user data
  GoogleSignInAccount acc;

  /// ***User informations***
  /// * user['uname']
  /// * user['email']
  /// * user['photoUrl']
  /// * user['specialist']
  /// * user['isDoctor']
  /// * user['id']
  /// * user['specialist']
  /// * user['schedule']
  /// * user['hospital']
  /// * user['address']
  /// * user['phone']
  /// * user['address']
  /// * user['workdays']
  Map<String, String> user;

  ///  SignIn activity
  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [
    'email',
    'profile',
    // 'https://www.googleapis.com/auth/contacts.readonly',
    'https://www.googleapis.com/auth/calendar.events',
  ]);

  /// function: ()=> SignIn s everytime when entering application
  ///
  /// *To do:*
  ///  * Store the credential on first run
  ///  * Get secure storage details when entering
  ///  * If not exists on secure storage loop every time if not exist.
  Future<void> _handleSignIn({
    bool isDoc = false,
  }) async {
    try {
      // print("\n\n\n\n\n\n\nGoing to sign in ...");
      acc = await _googleSignIn.signIn();
      // print("\n\n\n\n\n\n\nSign in process wait...");
      // GoogleSignInAuthentication _auth =
      await acc.authentication;
      // print(_auth.toString());

      // print("\n\n\n\n\nWhat to do?\n\n\\n\n\n\n\n");
      await acc.authentication.whenComplete(() async {
        if (acc != null) {
          // print("\n\n\n\n\nUser Account:\n");
          // print(acc.runtimeType);
          // print(acc);
          await storage.write(key: 'isSignIn', value: "true");
          await storage.write(key: 'isDoctor', value: isDoc.toString());
          await storage.write(key: 'uname', value: acc.displayName);
          await storage.write(key: 'id', value: acc.id);
          await storage.write(key: 'email', value: acc.email);
          await storage.write(key: 'photoUrl', value: acc.photoUrl);
          await storage.write(key: 'language', value: this._language);
        }
      }).then((value) {
        storage.readAll().then((value) {
          this.setState(() {
            isSignIn = true;
            isDoctor = isDoc;
            user.addAll(value);
          });
          if (!isDoc) {
            _loadDoctors('dll', location: address.first.subAdminArea);
          } else {}
        });
      });
    } catch (error) {
      print("\n\n\n\n\n\n\n\nErrors");
      // print(error);
    }
  }

  /// *Version Check controls*
  /// App version check actions.
  ///
  /// **Fetches version data json from git repository.**
  ///
  /// To do:
  /// * init git build
  /// * setup future updates
  /// * setup doctor app page
  /// * setup app rename
  /// * get update information json from latest and beta channel
  /// * setup app new features page on Application
  Future<String> fetchVertion() async {
    Response versionControl =
        await get(Uri.parse("https://versioncheck.url/vc"));
    return (jsonDecode(versionControl.body));
  }

  /// /// **Schema pattern for doctor**
  /// * dynamic schema = json.encode({
  /// * * "granded": false,
  /// * * 'name': "nick johnson",
  /// * * 'hospital': "apollo hospital",
  /// * * 'age': 0,
  /// * * 'catagory': "general",
  /// * * 'experience': 3,
  /// * * 'surgeries': <String, int>{
  /// * * * 'major': 3,
  /// * * * 'minor': 5
  /// * * },
  /// * * 'specialist': "appedix surgery specialist",
  /// * * 'timing': <String, Object>{
  /// * * * 'morning': <String, String>{
  /// * * * *  'from': '8.00AM',
  /// * * * *  'to': '12.00PM'},
  /// * * * 'afternoon': <String, String>{
  /// * * * *  'from': '2.00PM',
  /// * * * *  'to': '4.30PM',
  /// * * * },
  /// * * * 'evening': <String, String>{
  /// * * * *  'from': '5.00PM',
  /// * * * *  'to': '7.30PM',
  /// * * * },
  /// * * * 'work_days': <String, bool>{
  /// * * * *  "monday": true,
  /// * * * *  "tuesday": true,
  /// * * * *  "wednessday": true,
  /// * * * *  "thursday": true,
  /// * * * *  "friday": true,
  /// * * * *  "saturday": false,
  /// * * * *  "sunday": false,
  /// * * * }
  /// * * },
  /// * * 'available': true,
  /// * * 'phone_number': 1234567890,
  /// * * 'office': "mgm colony, indhira nagar, manoor",
  /// * * 'schedule': <Map<String, Object>>[
  /// * * * {
  /// * * * *  'accepted': false,
  /// * * * *  'time': 12783612873,
  /// * * * *  'patient_name': 'matharasi',
  /// * * * *  'reason': 'appendix sergery',
  /// * * * },
  /// * * ],
  /// * });
  dynamic schema = json.encode({
    "granded": false,
    'name': "nick johnson",
    'hospital': "apollo hospital",
    'age': 0,
    'catagory': "general",
    'experience': 3,
    'surgeries': <String, int>{'major': 3, 'minor': 5},
    'specialist': "appedix surgery specialist",
    'timing': <String, Object>{
      'morning': <String, String>{'from': '8.00AM', 'to': '12.00PM'},
      'afternoon': <String, String>{
        'from': '2.00PM',
        'to': '4.30PM',
      },
      'evening': <String, String>{
        'from': '5.00PM',
        'to': '7.30PM',
      },
      'work_days': <String, bool>{
        "monday": true,
        "tuesday": true,
        "wednessday": true,
        "thursday": true,
        "friday": true,
        "saturday": false,
        "sunday": false,
      }
    },
    'available': true,
    'phone_number': 1234567890,
    'office': "mgm colony, indhira nagar, manoor",
    'schedule': <Map<String, Object>>[
      {
        'accepted': false,
        'time': 12783612873,
        'patient_name': 'matharasi',
        'reason': 'appendix sergery',
      },
    ],
  });

  /// * variable(Supplier) **[dd, dlc, dll]** are destributes the variable values to pages for patients
  /// * **[dd]** <Response> has details of a single doctor with a schedule data.
  /// * **[dlc]** <Response> has list of details in a particular catagory. i.e General.
  /// * **[dll]** <Response> has list of details in a particular catagory. i.e General.
  dynamic dd, dlc, dll, dld, notification;

  /// Address data stored here
  /// * address.first.adminArea     // Tamil Nadu
  /// * address.first.addressLine   // Sukkangalpatti Rd, Gandi Nagar. Manthaiyamman Kovil, Cumbum, TamilNadu 625516, India,
  /// * address.first.countryCode   //IN
  /// * address.first.locality      //Cumbum
  /// * address.first.postalCode}   //625516
  /// * address.first.subAdminArea  //Theni
  /// * address.first.subLocality   //Mandhayamman Kovil
  var address;

  /// Location data stored here
  LocationData _locationData;

  getLocation() async {
    Location location = new Location();
    bool _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return false;
      }
    }
    PermissionStatus _permissionGranded = await location.hasPermission();
    if (_permissionGranded == PermissionStatus.denied) {
      _permissionGranded = await location.requestPermission();
      if (_permissionGranded != PermissionStatus.granted) {
        return false;
      }
    }
    _locationData = await location.getLocation();
    return true;
  }

  /// ***Constructor***
  _HomePageState() {
    initFunction();
    // print("$user is user");
  }

  initFunction() async {
    await storage.readAll().then((value) {
      try {
        getLocation().then((val) async {
          if (val) {
            final coordinates = new Coordinates(
                _locationData.latitude, _locationData.longitude);
            // address = await Geocoder.google(apiKey)
            address =
                await Geocoder.local.findAddressesFromCoordinates(coordinates);
            this.setState(() {
              if (user != null) {
                user.addAll(value);
                if (value.containsKey("language")) {
                  this._language = value["language"];
                }
                // print(value);
              } else {
                user = value;
                if (value.containsKey("language")) {
                  this._language = value["language"];
                }
                isSignIn = value.containsKey('isSignIn');
                if (value.containsKey('isDoctor')) {
                  if (value["isDoctor"] == "true") {
                    isDoctor = true;
                    _loadDoctors('dn');
                    _currentIndex = 0;
                  } else {
                    isDoctor = false;
                    _loadDoctors('dll', location: address.first.subAdminArea);
                  }
                }
              }
            });
          }
        });
      } catch (err) {
        print(err);
      }
      // this.setState(() {
      //   if (user != null)
      //     user.addAll(value);
      //   else
      //     user = value;
      //   isSignIn = value.containsKey('isSignIn');
      //   if (value.containsKey('isDoctor')) {
      //     if (value["isDoctor"] == "true") {
      //       isDoctor = true;
      //       _loadDoctors('dn');
      //       _currentIndex = 0;
      //     } else {
      //       isDoctor = false;
      //       _loadDoctors('dll', location: address.first.subAdminArea);
      //     }
      //   }
      // })
      // .then((value) => print(user))
    }).then((value) {
      // print(user);
    });
    tile.setEmpty();
  }
  // /// **This converts response to Tiles**
  // List<ListTile> r2lt(response) {
  //   return response != null
  //       ? (jsonDecode(response.body)
  //           .map<ListTile>((tiledata) => new ListTile(
  //                 hoverColor: Colors.white10,
  //                 focusColor: Colors.red,
  //                 selectedTileColor: Colors.white60,
  //                 tileColor: Colors.white30,
  //                 enabled: true,
  //                 onTap: () {
  //                   _loadDoctors('dd', key: '_id', value: tiledata['_id']);
  //                   _currentIndex = 4;
  //                 },
  //                 // selected: true,
  //                 leading: Icon(Icons.supervised_user_circle_rounded),
  //                 title: Text(
  //                   "Dr. ${tiledata['name']}",
  //                   style: Theme.of(context).textTheme.headline5,
  //                 ),
  //                 subtitle: Text("catagory: ${tiledata['catagory']}"),
  //                 // subtitle: Text("catagory: " + tiledata['catagory']),
  //               ))
  //           .toList())
  //       : [
  //           ListTile(
  //               title: Text(
  //             "No records found",
  //             style: Theme.of(context).textTheme.headline5,
  //           ))
  //         ].toList();
  // }

  var _language = "EN";

  // I'm not an organization to create workspace account
  // final _credentials = new ServiceAccountCredentials.fromJson({
  //   "type": "service_account",
  //   "project_id": "doctor-assent",
  //   "private_key_id": "9c4fee28b84a475a21365d34254a677be6d5d6f0",
  //   "private_key":
  //       "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC1a/RF+auOHlV0\nbMSQPnrn7MGNGbgpycj7rscO+Hr7U2xhn3gtTOOMOCk5/DfoeiUmX8wMte2bNKqI\n2fm9VN1i8MD3+OdxWeF7SnUEtXCea7jGHgBwDmvXN3LSFg+xf0YhwDE/kJG2t/Tc\nRHM9mxwJLv64XdI7sqK6S6qdrTADqyN5qi8uDtS+otu+gdKiMyksx/e9edPJPFH+\nqMMFoYmPZgBPkVSlpOZnYPmm1seFbZnD1JYZUIf2Lqra3VobMRwnV1Tw2yWhWUsj\nlOzkdv+JgJX8Qj+xSlxPgdeBZZYrKDBYBgeO3Pd12SQkAoVVRxmCuFkXLLGkwyV9\nrleQ9AozAgMBAAECggEAIXuwpD+NrZeknu26I4McjPRxznhqOHAxA16BB57Nl9gQ\nPz4+4GF597Wfyj9mFCaC97+jec8T8Nq6BLLyOELS70FO5BVQped4SZh2220fQWXR\nPuNnokbPGXP24ZZHxDMgvvbpP/mPIyF1dDe/6yVW+czuHxnVxMXV6bswXJSLsYlS\nnihf8/KbAbeANuDYg98GHr7B78ymDpIQZjc64PgmefSix8+zPEa32pdlW8xpcO+F\n7NF6jvq8x/pa3+VfEgMYwWrzyeLW+7l2SfHUSyNvJma8S46xSFR2wAApfg0J1/Zu\n93Fdyo3EItZc9Ex6UBHsw8CCCBer5fFW2IA5t/hhAQKBgQD3at3FF1O4ubC9gYty\nWoKGB2ZKRCqoVXzS2CdObGS235XvPQwboMg7Du1n4Jpeu5TuBoSOklKmyrBOw80J\n04yAwi3yknwxCaufx1jZeIboB1+IXf8j6OlZEuP36J83LycaekgljV8Z6Cd2eT8k\n6Gm2/rLFnGyDMPKiFdUQveN3AQKBgQC7twcfnP/wS+E4Ku27hG6yv9srvg/F+O+o\ndVeZkca+xLM8L7ULN/nn5v3iEeJY/fnsgeegJfR6EjWQ8bEgDCqFsLSSIXHuunw3\nofMH4HpACuYrFYmEVjtAtgKDPT8j4aMzDiDS4pxhlqhL0XxdtxMQACihNqCPsS1W\nIHKMViBVMwKBgQCwxYG9l3URvlowi6X+BfzLle3XkeyIaMvOOPGcboVmw0h0rcFA\n3BczWu70EN06Yft+NNnwo0q6MIbXP733D1aLiDEb5t0kjCw69Ere1eZNUTdITyBD\nn91Y7s5CCcn3u5DMsiFp8x/Her73PpmG3Sbqv/8qgSBme0pf1Alu9LzYAQKBgF0y\nf+zoLAIICmeymJmTJMrGinBrSrWF5KcEq1tpjv1D96EYJpDNV9wVSVOmgXShlCYi\nUPeoIHtC8ylldgVtROdfVid/R2u5VtbgJyNwBgIp5yDY7o+vqHd2ZkT2cZTFABvn\nFdDeBbpF7ITIGzEEJgi5q3JvBsSQuOub7INUd3UVAoGAXHUjv+FWPk+KPh33Hryd\nYataIMHxtyvXEPy9pe59sCM6Vqd2DNyZ4GTdHf67Ywy0dH3p8Fdat1zMhWinh+jD\ni34zSlRWZZ09KhsFLG7bNOUrph1s8TP8S0yMdO6NvVED0vsct5BfukJXsS7uC0jX\n9ysMIF9OIwoQjB1LXpw3ntQ=\n-----END PRIVATE KEY-----\n",
  //   "client_email": "doctor-assent@appspot.gserviceaccount.com",
  //   "client_id": "107863583225200140782",
  //   "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  //   "token_uri": "https://oauth2.googleapis.com/token",
  //   "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  //   "client_x509_cert_url":
  //       "https://www.googleapis.com/robot/v1/metadata/x509/doctor-assent%40appspot.gserviceaccount.com"
  // });

  /// ***** _loadDoctor **************************************************
  /// *  Execute only when isDoc<bool> false. Otherwise patient's data vice versa
  /// *  *  case "dd": doctor details.
  /// *  *  case "dll": doctor list of list.
  /// *  *  case "dlc": doctor list on a specific catagory or name.
  /// *  *  case 3: doctor details[personal].
  /// *  It has three variables.
  /// *  [dlc, dd, resctmp]
  /// *  load's loads patients details only.
  /// *  To do:
  /// *  Establish patientData too in this function while [isDoc<bool>] variable is true
  /// ********************************************************************

  void _loadDoctors(
    String action, {
    String term = "",
    String key = "",
    String value = "",
    String location = "",
  }) async {
    Response dlc, dd, dll, info;
    this.setState(() {
      this.loading = true;
    });
    try {
      /// Try non indices method to understatnd well stop using switch case in theis case.
      /// use dll <List<List>>[[],[],[]] to retrieve clients details.
      /// ie. Use [[name, ], ]

      switch (action) {

        /// Below is for global user and it can be accessed by anybody in this world...
        /// Be careful with data retraival
        case "dll":
          dll = await get(Uri.parse("https://asthra.herokuapp.com/dll"));
          if (address != null) {
            dld = await get(Uri.parse(
                "https://asthra.herokuapp.com/dld/location/?district=$location"));
          } else {
            dld = await get(Uri.parse("https://asthra.herokuapp.com/dld"));
          }

          /// this data is array value retrived from the server
          this.setState(() {
            if (dll != null) {
              this.dll = jsonDecode(dll.body);
            }
            if (dld != null) {
              this.dld = jsonDecode(dld.body);
            }
          });
          break;

        case "dlc":

          /// should not be empty
          dlc = await get(
              Uri.parse("https://asthra.herokuapp.com/dlc?key=$term"));
          if (dlc != null) {
            this.setState(() {
              this.dlc = jsonDecode(dlc.body);
              // this.tile.setTiles(r2lt(dlc));
            });
          }
          break;

        case "dd":
          dd = await get(Uri.parse("https://asthra.herokuapp.com/dd?$term"));
          // dd = await get("https://asthra.herokuapp.com/dd?$key=$value");
          if (dd != null) {
            this.setState(() {
              this.dd = jsonDecode(dd.body);
            });
          }
          break;

        /// Below is for doctors personal information
        /// Don't mix up it with normal normal person details...
        case "profile":
          dd = await get(
              Uri.parse("https://asthra.herokuapp.com/dd?$key=$value"));
          if (dd != null) {
            this.setState(() {
              this.dd = jsonDecode(dd.body);
            });
          }
          break;

        case "setprofile":
          dd = await post(
              Uri.parse("https://asthra.herokuapp.com/dd?$key=$value"));
          if (dd != null) {
            this.setState(() {
              this.dd = jsonDecode(dd.body);
            });
          }
          break;

        case "schedule":
          info = await post(Uri.parse(
              "https://asthra.herokuapp.com/schedule/$term?$key=$value"));
          if (info != null) {
            this.setState(() {
              this.notification = jsonDecode(info.body);
            });
          }
          break;
        default:
          print("Testing?");
      }

      this.setState(() {
        this.loading = false;
        this.noConnection = false;
        // connection.dispose;
      });
    } catch (e) {
      this.noConnection = true;
      Connectivity().onConnectivityChanged.listen((event) {
        _loadDoctors(action, key: key, value: value, term: term);
      });
      print(e);
    }
  }

  // List<ListTile> loader() {
  //   if (this.dlc != null) {
  //     this.tile.addTiles(r2lt(dlc));
  //   }
  //   return tile.tiles();
  // }

  ///  for testing purpose to increament to page
  void _incrementCounter() {
    setState(() {
      ++_currentIndex;
    });
  }

  /// for patients page remote access
  bool setIndex(int index) {
    this.setState(() {
      _currentIndex = index;
      _pageState['templist'] = [];
    });
    return (true);
  }

  /// For future reference of an application...
  /// This will help for custom loading
  bool loading = true;

  ///  This function has following terms now.
  ///  * "show_overlay": false,
  ///  * "suggestion": "",
  ///  * "edit_complete": false,
  ///  * "templist": [],
  Map<String, dynamic> _pageState = {
    "show_overlay": false,
    "suggestion": "",
    "edit_complete": false,
    "templist": [],
  };

  int keyUpdate(String key, {String value = ""}) {
    if (this.user != null && this.user.containsKey('''$key''') && value != "") {
      this.setState(() {
        this.user.update(
          '''$key''',
          (val) => (value),
          ifAbsent: () => value,
        );
      });
      return 0;
    } else if (this.user != null &&
        !this.user.containsKey('''$key''') &&
        value != "") {
      this.setState(() {
        this.user.putIfAbsent('''$key''', () => value);
      });
      return 1;
    } else {
      return -1;
      // no key no value
    }
  }

  /// Required parameters
  /// reason => String
  /// to => String (email)
  /// startTime => event StartTime
  /// duration => Duration instance
  insertEvent(
      {String reason,
      String to,
      DateTime startTime,
      Duration duration = const Duration(milliseconds: 1)}) {
    calendar.Event event = calendar.Event();
    // event.summary = "Appointment to doctor(MyDearDoc App)";
    calendar.EventDateTime start = new calendar.EventDateTime();
    start.dateTime = startTime;
    start.timeZone = "GMT+5.30";
    event.start = start; // need

    calendar.EventDateTime end = new calendar.EventDateTime();
    DateTime endTime = startTime.add(duration);
    end.dateTime = endTime;
    end.timeZone = "GMT+5.30";
    event.end = end; // need
    event.description =
        "I'm(${user['uname']}) in the need of your appointment. \nReason:\n\t$reason "; // no need
    event.summary = "MyDearDoc appointment"; // need

    calendar.EventAttendee patient = new calendar.EventAttendee();
    patient.email = "shiva.v2232@gmail.com";
    patient.displayName = "patient";

    calendar.EventAttendee doctor = new calendar.EventAttendee();
    doctor.email = to;
    doctor.displayName = "Doctor";

    event.attendees = [doctor, patient];
    var _clientId = new ClientId(
        "64671891498-fr8bmtj4kab8ibj4kptsfa8orrfb4gn0.apps.googleusercontent.com",
        "");
    clientViaUserConsent(_clientId, _scopes, prompt).then((AuthClient client) {
      // clientViaServiceAccount(_credentials, _scopes).then((AuthClient client) { // Problem with OAuth service account permission to account client
      var _calendar = calendar.CalendarApi(client);
      String calendarId = "primary";
      _calendar.events.insert(event, calendarId).then((value) {
        print("EVENT ADDEDDD.....${value.status}");
        if (value.status == "confirmed") {
          print("Event added successfully.");
        } else {
          print("Event can't add successfully.");
        }
      });
    });
  }

  prompt(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw "can't launch $url";
    }
  }

  static const _scopes = const [calendar.CalendarApi.calendarScope];

  /// action cases:
  /// * add
  /// * remove
  /// * verify
  ///
  ///
  // editEvent({action: ""}) {
  //   switch (action) {
  //     case "add":
  //       if (Platform.isAndroid) {
  //         _credentials = new ClientId(_authId, "mydeardocsec");
  //       } else if (Platform.isIOS) {
  //         // _credentials = new ClientId(); # i don't need...
  //       }
  //       print("event added");
  //       break;
  //     default:
  //   }
  // }

  // var animate = 0;
  // var clock = 1;
  // element() {
  //   if (loading) {
  //     Future.delayed(Duration(milliseconds: 50), () {
  //       setState(() {
  //         if (animate >= 100) {
  //           clock = -1;
  //         } else if (animate <= 1) {
  //           clock = 1;
  //         }
  //         animate = animate + clock;
  //       });
  //     });
  //   }
  //   return Text("Returned successfully");
  // }

  @override
  Widget build(BuildContext context) {
    if (!isDoctor) {
      this.tabs = Pages(
        language: this._language,
        address: this.address,
        noconnection: this.noConnection,
        context: context,
        // tile: tile,
        pageNumber: _currentIndex,
        loadDoctor: this._loadDoctors,
        catagories: this.dll,
        list: this.dlc,
        dld: this.dld,
        details: this.dd,
        setIndex: this.setIndex,
        reload: this.setState,
        pageState: _pageState,
        insertEvent: this.insertEvent,
      ).createPages();
    }

    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 1 || _currentIndex != 0) {
          setState(() {
            _currentIndex = --_currentIndex;
          });
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: (!noConnection && isDoctor)
            ? AppBar(
                toolbarHeight: 1.5 * MediaQuery.of(context).padding.top,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black38,
                title: Text(
                  "MyDearDoc",
                  style: TextStyle(
                    color: Colors.black38,
                  ),
                ),
                leading: (isDoctor)
                    ? Builder(
                        builder: (BuildContext context) {
                          return IconButton(
                            icon: Icon(
                              (this.doctorIndex == 0)
                                  ? Icons.menu
                                  : Icons.chevron_left_rounded,
                              color: Colors.black54,
                            ),
                            onPressed: () {
                              Scaffold.of(context).openDrawer();
                              this.setState(() {
                                doctorIndex = (doctorIndex == 1) ? 0 : 1;
                              });
                            },
                          );
                        },
                      )
                    : null,
              )
            : null,
        body: !isSignIn
            ? (user != null)
                ? Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          Colors.blueAccent[200], // for students
                          Colors.purpleAccent[100],
                          Color.fromRGBO(190, 190, 215, 1),
                          // Colors.black12,
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).padding.top,
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height / 4,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white30,
                                blurRadius: 30.0,
                              ),
                            ],
                            color: Colors.white10,
                            shape: BoxShape.rectangle,
                            image: new DecorationImage(
                                image: AssetImage('assets/banner.png'),
                                fit: BoxFit.fitHeight),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical:
                                    MediaQuery.of(context).size.height / 42),
                            child: Text(
                              "WELCOME TO",
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height / 42,
                                color: Colors.blueGrey,
                                fontFamily: "casual",
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Expanded(
                          child: PageView(
                            controller: pageController,
                            onPageChanged: (_index) {
                              this.setState(() {
                                _initIndex = _index;
                              });
                            },
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        () {
                                          switch (this._language) {
                                            case "EN":
                                              return "Select language";
                                            case "ML":
                                              return "ഭാഷ തിരഞ്ഞെടുക്കുക";
                                            case "TA":
                                              return "மொழியைத் தேர்ந்ததெடு";
                                            case "KN":
                                              return "ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ";
                                            case "TE":
                                              return "భాషను ఎంచుకోండి";
                                            default:
                                              return "Select language";
                                          }
                                        }(),
                                        softWrap: true,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          height: 1.5,
                                          fontSize: 18,
                                        ),
                                      ),
                                      new DropdownButton<String>(
                                        value: this._language,
                                        items: <String>[
                                          "ENGLISH",
                                          "MALAYALAM",
                                          "TAMIL",
                                          "KANNADA",
                                          "TELUGU"
                                        ]
                                            .map((e) =>
                                                new DropdownMenuItem<String>(
                                                  child: new Text(e),
                                                  value: lang[e],
                                                ))
                                            .toList(),
                                        onChanged: (la) => {
                                          this.setState(() {
                                            _language = la;
                                          })
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        this._language == "EN"
                                            ? "Are you Doctor?"
                                            : this._language == "ML"
                                                ? "നിങ്ങൾ ഡോക്ടറാണോ?"
                                                : this._language == "TA"
                                                    ? "நீங்கள் மருத்துவரா?"
                                                    : this._language == "KN"
                                                        ? "ನೀವು ವೈದ್ಯರಾಗಿದ್ದೀರಾ?"
                                                        : this._language == "TE"
                                                            ? "మీరు డాక్టర్?"
                                                            : "Are you doctor?",
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        this._language == "EN"
                                            ? "Are you Doctor?"
                                            : this._language == "ML"
                                                ? "നിങ്ങൾ ഡോക്ടറാണോ?"
                                                : this._language == "TA"
                                                    ? "நீங்கள் மருத்துவரா?"
                                                    : this._language == "KN"
                                                        ? "ನೀವು ವೈದ್ಯರಾಗಿದ್ದೀರಾ?"
                                                        : this._language == "TE"
                                                            ? "మీరు డాక్టర్?"
                                                            : "Are you doctor?",
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        this._language == "EN"
                                            ? "Are you Doctor?"
                                            : this._language == "ML"
                                                ? "നിങ്ങൾ ഡോക്ടറാണോ?"
                                                : this._language == "TA"
                                                    ? "நீங்கள் மருத்துவரா?"
                                                    : this._language == "KN"
                                                        ? "ನೀವು ವೈದ್ಯರಾಗಿದ್ದೀರಾ?"
                                                        : this._language == "TE"
                                                            ? "మీరు డాక్టర్?"
                                                            : "Are you doctor?",
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        this._language == "EN"
                                            ? "Are you Doctor?"
                                            : this._language == "ML"
                                                ? "നിങ്ങൾ ഡോക്ടറാണോ?"
                                                : this._language == "TA"
                                                    ? "நீங்கள் மருத்துவரா?"
                                                    : this._language == "KN"
                                                        ? "ನೀವು ವೈದ್ಯರಾಗಿದ್ದೀರಾ?"
                                                        : this._language == "TE"
                                                            ? "మీరు డాక్టర్?"
                                                            : "Are you doctor?",
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width >
                                            MediaQuery.of(context).size.height
                                        ? MediaQuery.of(context).size.height
                                        : MediaQuery.of(context).size.width,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            _handleSignIn();
                                          },
                                          child: Text("I am a Patient"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            _handleSignIn(isDoc: true);
                                          },
                                          child: Text("I am a Doctor"),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ButtonBar(
                          buttonHeight: 14,
                          buttonPadding: EdgeInsets.all(0),
                          alignment: MainAxisAlignment.center,
                          children: () {
                            var val = <Widget>[];
                            for (int i = 0; i < 5; i++) {
                              val.add(changeIndex(i));
                            }
                            return (val);
                          }(),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width - 20,
                          color: Colors.white12,
                          padding: EdgeInsets.all(2),
                          child: GestureDetector(
                            onTap: () async {
                              await canLaunch(
                                      "https://aayudha-aio.web.app/terms")
                                  ? await launch(
                                      "https://aayudha-aio.web.app/terms")
                                  : print("can't launch url.");
                            },
                            child: Text(
                              this._language == "TA"
                                  ? "இந்த பயன்பாட்டைப் பயன்படுத்துவதன் மூலம் விதிமுறைகளையும் நிபந்தனைகளையும் ஒப்புக்கொள்கிறேன்."
                                  : this._language == "ML"
                                      ? "ഈ അപ്ലിക്കേഷൻ ഉപയോഗിക്കുന്നതിലൂടെ ഞാൻ നിബന്ധനകളും വ്യവസ്ഥകളും അംഗീകരിക്കുന്നു."
                                      : this._language == "KN"
                                          ? "ಈ ಅಪ್ಲಿಕೇಶನ್ ಬಳಸುವ ಮೂಲಕ ನಾನು ನಿಯಮಗಳು ಮತ್ತು ಷರತ್ತುಗಳನ್ನು ಒಪ್ಪುತ್ತೇನೆ."
                                          : this._language == "TE"
                                              ? "ఈ అనువర్తనాన్ని ఉపయోగించడం ద్వారా నేను నిబంధనలు మరియు షరతులను అంగీకరిస్తున్నాను."
                                              : "By using this app, I agree terms and conditions.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15.0,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).padding.bottom,
                        )
                      ],
                    ),
                  )
                : Center(
                    child: Text(
                      this._language == "TA"
                          ? "ஏற்றுகிறது"
                          : this._language == "ML"
                              ? "ലോഡിംഗ്"
                              : this._language == "KN"
                                  ? "ಲೋಡ್ ಆಗುತ್ತಿದೆ"
                                  : this._language == "TE"
                                      ? "లోడ్"
                                      : "loading",
                    ),
                  )
            : (this.noConnection && tabs != null)
                ? tabs[0]
                : Stack(
                    children: <Widget>[
                      isDoctor
                          ? new Container(
                              child: <Widget>[
                                Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).padding.top,
                                      ),
                                      Text(
                                        "Notifications: ",
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (!_editMode)
                                        UserAccountsDrawerHeader(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            image: new DecorationImage(
                                                image: AssetImage(
                                                    'assets/banner.png'),
                                                fit: BoxFit.fitHeight),
                                            color: Colors.blue,
                                          ),
                                          accountName: (this.user == null)
                                              ? new Text('name')
                                              : new Text(user['uname']),
                                          accountEmail: (this.user == null)
                                              ? new Text('Email Id')
                                              : new Text(user['email']),
                                          currentAccountPicture:
                                              new GestureDetector(
                                            onTap: () {},
                                            child: new CircleAvatar(
                                              backgroundImage: AssetImage(
                                                  'assets/banner.png'),
                                              foregroundImage: user == null
                                                  ? AssetImage(
                                                      'assets/banner.png')
                                                  : NetworkImage(
                                                      user['photoUrl']),
                                            ),
                                          ),
                                        ),
                                      if (_editMode)
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                              .padding
                                              .top,
                                        ),
                                      Form(
                                          key: _formKey,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(
                                                "Your Details: ",
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              IconButton(
                                                icon: !_editMode
                                                    ? Icon(Icons.edit)
                                                    : Icon(Icons.save),
                                                onPressed: () async {
                                                  if (_editMode) {
                                                    if (_formKey.currentState
                                                        .validate()) {
                                                      HttpClient httpClient =
                                                          new HttpClient();
                                                      HttpClientRequest
                                                          request =
                                                          await httpClient
                                                              .postUrl(Uri.parse(
                                                                  'https://asthra.herokuapp.com/admin/createdoctor'));
                                                      request.headers.set(
                                                          "content-type",
                                                          "application/json");
                                                      request.add(utf8
                                                          .encode(json.encode({
                                                        "granded": false,
                                                        'name': user != null &&
                                                                user.containsKey(
                                                                    'uname')
                                                            ? user['uname']
                                                            : "unavailable",
                                                        'hospital': user !=
                                                                    null &&
                                                                user.containsKey(
                                                                    'hospital')
                                                            ? user['hospital']
                                                            : "unavailable",
                                                        'age': user != null &&
                                                                user.containsKey(
                                                                    'age')
                                                            ? user['age']
                                                            : null,
                                                        'catagory': user !=
                                                                    null &&
                                                                user.containsKey(
                                                                    'catagory')
                                                            ? user['catagory']
                                                            : "general",
                                                        'experience': user !=
                                                                    null &&
                                                                user != null &&
                                                                user.containsKey(
                                                                    'experience')
                                                            ? user['experience']
                                                            : null,
                                                        'surgeries':
                                                            <String, int>{
                                                          'major': user !=
                                                                      null &&
                                                                  user.containsKey(
                                                                      'major_suregeries')
                                                              ? user[
                                                                  'major_suregeries']
                                                              : 0,
                                                          'minor': user !=
                                                                      null &&
                                                                  user.containsKey(
                                                                      'minor_suregeries')
                                                              ? user[
                                                                  'minor_suregeries']
                                                              : 0
                                                        },
                                                        'specialist': user !=
                                                                    null &&
                                                                user.containsKey(
                                                                    'specialist')
                                                            ? user['specialist']
                                                            : "unavailable",
                                                        'timing':
                                                            <String, Object>{
                                                          'morning':
                                                              <List<String>>[
                                                            user != null &&
                                                                    user.containsKey(
                                                                        'morning')
                                                                ? user[
                                                                    'morning']
                                                                : [
                                                                    '8.00AM-11.59AM'
                                                                  ],
                                                          ],
                                                          'afternoon':
                                                              <List<String>>[
                                                            user != null &&
                                                                    user.containsKey(
                                                                        'afternoon')
                                                                ? user[
                                                                    'afternoon']
                                                                : [
                                                                    '12.30PM-4.30PM'
                                                                  ],
                                                          ],
                                                          'evening':
                                                              <List<String>>[
                                                            user != null &&
                                                                    user.containsKey(
                                                                        'evening')
                                                                ? user[
                                                                    'evening']
                                                                : [
                                                                    '5.00PM-7.59PM'
                                                                  ],
                                                          ],
                                                          'night':
                                                              <List<String>>[
                                                            user != null &&
                                                                    user.containsKey(
                                                                        'night')
                                                                ? user['night']
                                                                : [
                                                                    '8.00PM-10.30PM'
                                                                  ],
                                                          ],
                                                          'work_days':
                                                              <String, bool>{
                                                            "monday": true,
                                                            "tuesday": true,
                                                            "wednessday": true,
                                                            "thursday": true,
                                                            "friday": true,
                                                            "saturday": true,
                                                            "sunday": false,
                                                          }
                                                        },
                                                        'available': true,
                                                        'phone_number': user !=
                                                                    null &&
                                                                user.containsKey(
                                                                    'phone_number')
                                                            ? user['phone']
                                                            : 'unavailable',
                                                        'mobile_number': user !=
                                                                    null &&
                                                                user.containsKey(
                                                                    'phone_number')
                                                            ? user[
                                                                'phone_number']
                                                            : 'unavailable',
                                                        'office': user !=
                                                                    null &&
                                                                user.containsKey(
                                                                    'office')
                                                            ? user['office']
                                                            : "mgm colony, indhira nagar, manoor",
                                                        'schedule': <
                                                            Map<String,
                                                                Object>>[]
                                                        //     <Map<String, Object>>[
                                                        //   {
                                                        //     'accepted': false,
                                                        //     'time': 12783612873,
                                                        //     'patient_name': 'matharasi',
                                                        //     'reason':
                                                        //         'appendix sergery',
                                                        //   },
                                                        // ],
                                                      })));
                                                      print(json.encode({
                                                        "granded": false,
                                                        'name': user != null &&
                                                                user.containsKey(
                                                                    'uname')
                                                            ? user['uname']
                                                            : "unavailable",
                                                        'hospital': user !=
                                                                    null &&
                                                                user.containsKey(
                                                                    'hospital')
                                                            ? user['hospital']
                                                            : "unavailable",
                                                        'age': user != null &&
                                                                user.containsKey(
                                                                    'age')
                                                            ? user['age']
                                                            : null,
                                                        'catagory': user !=
                                                                    null &&
                                                                user.containsKey(
                                                                    'catagory')
                                                            ? user['catagory']
                                                            : "general",
                                                        'experience': user !=
                                                                    null &&
                                                                user.containsKey(
                                                                    'experience')
                                                            ? user['experience']
                                                            : null,
                                                        'surgeries':
                                                            <String, int>{
                                                          'major': user !=
                                                                      null &&
                                                                  user.containsKey(
                                                                      'major_suregeries')
                                                              ? user[
                                                                  'major_suregeries']
                                                              : 0,
                                                          'minor': user !=
                                                                      null &&
                                                                  user.containsKey(
                                                                      'minor_suregeries')
                                                              ? user[
                                                                  'minor_suregeries']
                                                              : 0
                                                        },
                                                        'specialist': user !=
                                                                    null &&
                                                                user.containsKey(
                                                                    'specialist')
                                                            ? user['specialist']
                                                            : "unavailable",
                                                        'timing':
                                                            <String, Object>{
                                                          'morning':
                                                              <List<String>>[
                                                            user != null &&
                                                                    user.containsKey(
                                                                        'morning')
                                                                ? user[
                                                                    'morning']
                                                                : [
                                                                    '8.00AM-11.59AM'
                                                                  ],
                                                          ],
                                                          'afternoon':
                                                              <List<String>>[
                                                            user != null &&
                                                                    user.containsKey(
                                                                        'afternoon')
                                                                ? user[
                                                                    'afternoon']
                                                                : [
                                                                    '12.30PM-4.30PM'
                                                                  ],
                                                          ],
                                                          'evening':
                                                              <List<String>>[
                                                            user != null &&
                                                                    user.containsKey(
                                                                        'evening')
                                                                ? user[
                                                                    'evening']
                                                                : [
                                                                    '5.00PM-7.59PM'
                                                                  ],
                                                          ],
                                                          'night':
                                                              <List<String>>[
                                                            user != null &&
                                                                    user.containsKey(
                                                                        'night')
                                                                ? user['night']
                                                                : [
                                                                    '8.00PM-10.30PM'
                                                                  ],
                                                          ],
                                                          'work_days':
                                                              <String, bool>{
                                                            "monday": true,
                                                            "tuesday": true,
                                                            "wednessday": true,
                                                            "thursday": true,
                                                            "friday": true,
                                                            "saturday": true,
                                                            "sunday": false,
                                                          }
                                                        },
                                                        'available': true,
                                                        'phone_number': user !=
                                                                    null &&
                                                                user.containsKey(
                                                                    'phone_number')
                                                            ? user['phone']
                                                            : 'unavailable',
                                                        'mobile_number': user !=
                                                                    null &&
                                                                user.containsKey(
                                                                    'phone_number')
                                                            ? user[
                                                                'phone_number']
                                                            : 'unavailable',
                                                        'office': user !=
                                                                    null &&
                                                                user.containsKey(
                                                                    'office')
                                                            ? user['office']
                                                            : "mgm colony, indhira nagar, manoor",
                                                        'schedule': <
                                                            Map<String,
                                                                Object>>[]

                                                        /// It can have like this schema
                                                        ///     <Map<String, Object>>[
                                                        ///   {
                                                        ///     'accepted': false,
                                                        ///     'time': 12783612873,
                                                        ///     'patient_name': 'matharasi',
                                                        ///     'reason':
                                                        ///         'appendix sergery',
                                                        ///   },
                                                        /// ],
                                                      }));
                                                      HttpClientResponse res =
                                                          await request.close();
                                                      if (res.statusCode ==
                                                              404 ||
                                                          res.statusCode ==
                                                              500) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                                'check mobile number.'),
                                                          ),
                                                        );
                                                      } else {
                                                        String reply = await res
                                                            .transform(
                                                                utf8.decoder)
                                                            .join();
                                                        httpClient.close();
                                                        print(reply);
                                                        // print(schema);
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                                'update success.'),
                                                          ),
                                                        );
                                                      }
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              'validation error.'),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                  setState(() {
                                                    _editMode = !_editMode;
                                                  });
                                                },
                                              )
                                            ],
                                          )),
                                      _editMode
                                          ? Expanded(
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: <Widget>[
                                                    Text(
                                                      "Name: ",
                                                      textAlign: TextAlign.left,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline5,
                                                    ),
                                                    TextFormField(
                                                      initialValue:
                                                          (this.user == null)
                                                              ? 'unavailable'
                                                              : user['uname'],
                                                      readOnly: true,
                                                      cursorHeight: 25,
                                                      scrollPadding:
                                                          EdgeInsets.symmetric(
                                                        vertical: 0,
                                                      ),
                                                      keyboardType:
                                                          TextInputType.text,
                                                      validator: (value) {
                                                        if (!value.contains(
                                                                new RegExp(
                                                                    r'[+]'),
                                                                0) ||
                                                            value.contains(
                                                                new RegExp(
                                                                    r'[A-Z]')) ||
                                                            value.contains(
                                                                new RegExp(
                                                                    r'[a-z]')) ||
                                                            !value.contains(
                                                                new RegExp(
                                                                    r'[0-9]')) ||
                                                            value.length < 8) {
                                                          return "Please Enter valid name";
                                                        } else {
                                                          keyUpdate("uname",
                                                              value: value);
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                      "Email ID: ",
                                                      textAlign: TextAlign.left,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline5,
                                                    ),
                                                    TextFormField(
                                                      initialValue:
                                                          (this.user == null)
                                                              ? 'unavailable'
                                                              : user['email'],
                                                      readOnly: true,
                                                      cursorHeight: 25,
                                                      scrollPadding:
                                                          EdgeInsets.symmetric(
                                                        vertical: 0,
                                                      ),
                                                      keyboardType:
                                                          TextInputType.text,
                                                      validator: (value) {
                                                        if (!value.contains(
                                                                new RegExp(
                                                                    r'[+]'),
                                                                0) ||
                                                            value.contains(
                                                                new RegExp(
                                                                    r'[A-Z]')) ||
                                                            value.contains(
                                                                new RegExp(
                                                                    r'[a-z]')) ||
                                                            !value.contains(
                                                                new RegExp(
                                                                    r'[0-9]')) ||
                                                            value.length < 8) {
                                                          return "Please Enter valid name";
                                                        } else {
                                                          keyUpdate("email",
                                                              value: value);
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                      "Specialist At: ",
                                                      textAlign: TextAlign.left,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline5,
                                                    ),
                                                    TextFormField(
                                                      initialValue: (this
                                                                  .user ==
                                                              null)
                                                          ? 'unavailable'
                                                          : user['specialist'],
                                                      // readOnly: true,
                                                      cursorHeight: 25,
                                                      scrollPadding:
                                                          EdgeInsets.symmetric(
                                                        vertical: 0,
                                                      ),
                                                      keyboardType:
                                                          TextInputType.text,
                                                      validator: (value) {
                                                        if (!value.contains(
                                                                new RegExp(
                                                                    r'[+]'),
                                                                0) ||
                                                            value.contains(
                                                                new RegExp(
                                                                    r'[A-Z]')) ||
                                                            value.contains(
                                                                new RegExp(
                                                                    r'[a-z]')) ||
                                                            !value.contains(
                                                                new RegExp(
                                                                    r'[0-9]')) ||
                                                            value.length < 8) {
                                                          return "Please Enter valid name";
                                                        } else {
                                                          keyUpdate(
                                                              "specialist",
                                                              value: value);
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                      "Mobile number",
                                                      textAlign: TextAlign.left,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline5,
                                                    ),
                                                    TextFormField(
                                                      cursorHeight: 25,
                                                      scrollPadding:
                                                          EdgeInsets.symmetric(
                                                        vertical: 0,
                                                      ),
                                                      keyboardType:
                                                          TextInputType.phone,
                                                      validator: (value) {
                                                        if (!value.contains(
                                                                new RegExp(
                                                                    r'[+]'),
                                                                0) ||
                                                            value.contains(
                                                                new RegExp(
                                                                    r'[A-Z]')) ||
                                                            value.contains(
                                                                new RegExp(
                                                                    r'[a-z]')) ||
                                                            !value.contains(
                                                                new RegExp(
                                                                    r'[0-9]')) ||
                                                            value.length < 8) {
                                                          return "Please Enter valid mobile number";
                                                        } else {
                                                          keyUpdate("mobile",
                                                              value: value);
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                      "Phone number(Office)",
                                                      textAlign: TextAlign.left,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline5,
                                                    ),
                                                    TextFormField(
                                                      cursorHeight: 25,
                                                      scrollPadding:
                                                          EdgeInsets.symmetric(
                                                        vertical: 0,
                                                      ),
                                                      keyboardType:
                                                          TextInputType.phone,
                                                      onFieldSubmitted:
                                                          (value) {
                                                        if (!value.contains(
                                                                new RegExp(
                                                                    r'[+]'),
                                                                0) ||
                                                            value.contains(
                                                                new RegExp(
                                                                    r'[A-Z]')) ||
                                                            value.contains(
                                                                new RegExp(
                                                                    r'[a-z]')) ||
                                                            !value.contains(
                                                                new RegExp(
                                                                    r'[0-9]')) ||
                                                            value.length < 8) {
                                                          return "Please Enter valid mobile number";
                                                        } else {
                                                          keyUpdate("phone",
                                                              value: value);
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                      "Schedule",
                                                      textAlign: TextAlign.left,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline5,
                                                    ),
                                                    Text(
                                                      "Morning",
                                                      textAlign: TextAlign.left,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline6,
                                                    ),
                                                    TextFormField(
                                                      cursorHeight: 25,
                                                      scrollPadding:
                                                          EdgeInsets.symmetric(
                                                        vertical: 0,
                                                      ),
                                                      keyboardType:
                                                          TextInputType.text,
                                                      validator: (value) {
                                                        if (!value.contains(
                                                                new RegExp(
                                                                    r'[+]'),
                                                                0) ||
                                                            value.contains(
                                                                new RegExp(
                                                                    r'[A-Z]')) ||
                                                            value.contains(
                                                                new RegExp(
                                                                    r'[a-z]')) ||
                                                            !value.contains(
                                                                new RegExp(
                                                                    r'[0-9]')) ||
                                                            value.length < 8) {
                                                          return "Multiple timings can be splitted with space. i.e 10.00AM-12.00PM 12.30PM-4.30PM";
                                                        } else {
                                                          keyUpdate("morning",
                                                              value: value
                                                                  .toString()
                                                                  .split(" ")
                                                                  .toString());
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                    Text(
                                                      "(after)noon",
                                                      textAlign: TextAlign.left,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline6,
                                                    ),
                                                    TextFormField(
                                                      cursorHeight: 25,
                                                      scrollPadding:
                                                          EdgeInsets.symmetric(
                                                        vertical: 0,
                                                      ),
                                                      keyboardType:
                                                          TextInputType.text,
                                                      validator: (value) {
                                                        if (!value.contains(
                                                                new RegExp(
                                                                    r'[+]'),
                                                                0) ||
                                                            value.contains(
                                                                new RegExp(
                                                                    r'[A-Z]')) ||
                                                            value.contains(
                                                                new RegExp(
                                                                    r'[a-z]')) ||
                                                            !value.contains(
                                                                new RegExp(
                                                                    r'[0-9]')) ||
                                                            value.length < 8) {
                                                          return "Multiple timing can be splitted by space";
                                                        } else {
                                                          keyUpdate("afternoon",
                                                              value: value
                                                                  .toString()
                                                                  .split(" ")
                                                                  .toString());
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                    Text(
                                                      "Evening:",
                                                      textAlign: TextAlign.left,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline6,
                                                    ),
                                                    TextFormField(
                                                      cursorHeight: 25,
                                                      scrollPadding:
                                                          EdgeInsets.symmetric(
                                                        vertical: 0,
                                                      ),
                                                      keyboardType:
                                                          TextInputType.text,
                                                      validator: (value) {
                                                        if (!value.contains(
                                                                new RegExp(
                                                                    r'[+]'),
                                                                0) ||
                                                            value.contains(
                                                                new RegExp(
                                                                    r'[A-Z]')) ||
                                                            value.contains(
                                                                new RegExp(
                                                                    r'[a-z]')) ||
                                                            !value.contains(
                                                                new RegExp(
                                                                    r'[0-9]')) ||
                                                            value.length < 8) {
                                                          return "Multiple timing can be splitted by space";
                                                        } else {
                                                          keyUpdate("evening",
                                                              value: value
                                                                  .toString()
                                                                  .split(" ")
                                                                  .toString());
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                    Text(
                                                      "Night:",
                                                      textAlign: TextAlign.left,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline6,
                                                    ),
                                                    TextFormField(
                                                      cursorHeight: 25,
                                                      scrollPadding:
                                                          EdgeInsets.symmetric(
                                                        vertical: 0,
                                                      ),
                                                      keyboardType:
                                                          TextInputType.text,
                                                      validator: (value) {
                                                        if (!value.contains(
                                                                new RegExp(
                                                                    r'[+]'),
                                                                0) ||
                                                            value.contains(
                                                                new RegExp(
                                                                    r'[A-Z]')) ||
                                                            value.contains(
                                                                new RegExp(
                                                                    r'[a-z]')) ||
                                                            !value.contains(
                                                                new RegExp(
                                                                    r'[0-9]')) ||
                                                            value.length < 8) {
                                                          return "Multiple timing can be splitted by space";
                                                        } else {
                                                          keyUpdate("night",
                                                              value: value
                                                                  .toString()
                                                                  .split(" ")
                                                                  .toString());
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                      "Hospital",
                                                      textAlign: TextAlign.left,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline5,
                                                    ),
                                                    TextFormField(
                                                      cursorHeight: 25,
                                                      scrollPadding:
                                                          EdgeInsets.symmetric(
                                                        vertical: 0,
                                                      ),
                                                      keyboardType:
                                                          TextInputType.text,
                                                      validator: (value) {
                                                        if (value.isEmpty) {
                                                          return "Please Enter valid hospital name";
                                                        } else {
                                                          keyUpdate("hospital",
                                                              value: value
                                                                  .toString());
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                      "Address(Office)",
                                                      textAlign: TextAlign.left,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline5,
                                                    ),
                                                    TextFormField(
                                                      cursorHeight: 25,
                                                      scrollPadding:
                                                          EdgeInsets.symmetric(
                                                        vertical: 0,
                                                      ),
                                                      keyboardType:
                                                          TextInputType
                                                              .streetAddress,
                                                      validator: (value) {
                                                        if (!value.contains(
                                                                new RegExp(
                                                                    r'[+]'),
                                                                0) ||
                                                            value.contains(
                                                                new RegExp(
                                                                    r'[A-Z]')) ||
                                                            value.contains(
                                                                new RegExp(
                                                                    r'[a-z]')) ||
                                                            !value.contains(
                                                                new RegExp(
                                                                    r'[0-9]')) ||
                                                            value.length < 8) {
                                                          return "Please Enter valid mobile number";
                                                        } else {
                                                          keyUpdate("address",
                                                              value: value
                                                                  .toString());
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                    Text(
                                                        "Verifcation Document(certificate):"),
                                                    ElevatedButton.icon(
                                                      onPressed: () async {
                                                        FilePickerResult
                                                            result =
                                                            await FilePicker
                                                                .platform
                                                                .pickFiles();
                                                        if (result != null) {
                                                          File file = File(
                                                              result.files
                                                                  .single.path);
                                                          print(file.path);
                                                        } else {}
                                                      },
                                                      icon: Icon(
                                                          Icons.file_upload),
                                                      label: Text("document"),
                                                    ),
                                                    CheckboxListTile(
                                                      value: true, //agreed
                                                      onChanged: (value) {
                                                        // agreed = !this.agreed;
                                                      },
                                                      title: Text(
                                                          "By clicking this you are agreeing that these details are true and not an fradulent"),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            )
                                          : Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: <Widget>[
                                                Text(
                                                  (this.user == null)
                                                      ? 'name'
                                                      : user['uname'],
                                                  style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                                Text(
                                                  (this.user == null)
                                                      ? 'name'
                                                      : user['email'],
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                                Text(
                                                  "{Hospital}",
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                                Text(
                                                  "{Specialist}",
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                                Text(
                                                  "{Address}(office)",
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                                Text(
                                                  "{Phone number}",
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                                Text(
                                                  "{Mobile number}",
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                                Text(
                                                  "{City}-{Pincode}(office)",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ],
                                  ),
                                )
                              ][doctorIndex],
                            )
                          : tabs[_currentIndex % 4],
                      if (this.loading)
                        Container(
                          color: Colors.black38,
                          child: Center(
                            /// Recommended to use .GIF image format
                            child: Text(
                              () {
                                switch (this._language) {
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
                            ),
                            // Transform.rotate(
                            //   angle: 2 * this.animate * pi / 100,
                            //   child: element(),
                            // ),
                          ),
                        ),
                    ],
                  ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black45,
          onPressed: _incrementCounter,
          tooltip: 'Details',
          child: Icon(Icons.feedback),
        ),
      ),
    );
  }
}

/**** TO DO LIST **************************************************
****  CREATE firebase based login either phone number(best) or email [no need]
****  * Update userdata
****  ADD FLUTTER_SECURE_STORAGE plugin to project [done] 
****  STORE user credential with that plugin [done]
****  SAVE state variable for smooth loading [don't want]
****  STORE doctor dd but not appointment dd and availability schedule.
****  CREATE grid view like the screenshot for Schedule timing. [done]
****    |___ * update gridview with card for doctor profile [done] 
****    |___ * remove catagory page. fetch all doctors nearby. [done]
****    
****  CREATE doctor dd page                          50%
****  CREATE Asthra logo to add to it. [no need]
****  PUSH to git repo shiva2232 as a private.abstract 
****  CREATE license to APP and Company(for client) product.
****  CREATE chat feature to doctor if possible [future versions]
****  but client can't chat to doctor in BUSY MODE [no need]
******************************************************************/
