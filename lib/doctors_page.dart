import 'package:flutter/material.dart';

class DoctorView {
  bool _editable = false;
  dynamic context;
  List<Widget> pageView;

  DoctorView({
    Function editMode,
    dynamic context,
  }) {
    this.context = context;
    this._editable = editMode();
    pageView = <Widget>[
      Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                image: new DecorationImage(
                    image: AssetImage('assets/banner.png'),
                    fit: BoxFit.fitHeight),
                color: Colors.blue,
              ),
              accountName: new Text('Sivamani Vanaraj'),
              accountEmail: new Text('shiva.v2232@gmail.com'),
              currentAccountPicture: new GestureDetector(
                onTap: () {},
                child: new CircleAvatar(
                  backgroundImage: AssetImage('assets/banner.png'),
                ),
              ),
            ),
            Text(
              "About: ",
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                image: new DecorationImage(
                    image: AssetImage('assets/banner.png'),
                    fit: BoxFit.fitHeight),
                color: Colors.blue,
              ),
              accountName: new Text('Sivamani Vanaraj'),
              accountEmail: new Text('shiva.v2232@gmail.com'),
              currentAccountPicture: new GestureDetector(
                onTap: () {},
                child: new CircleAvatar(
                  backgroundImage: AssetImage('assets/banner.png'),
                ),
              ),
            ),
            Text(
              "About: ",
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                image: new DecorationImage(
                    image: AssetImage('assets/banner.png'),
                    fit: BoxFit.fitHeight),
                color: Colors.blue,
              ),
              accountName: new Text('name'),
              accountEmail: new Text('Email Id'),
              currentAccountPicture: new GestureDetector(
                onTap: () {},
                child: new CircleAvatar(
                  backgroundImage: AssetImage('assets/banner.png'),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Your Details: ",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: !_editable ? Icon(Icons.edit) : Icon(Icons.save),
                  onPressed: () {
                    editMode(edit: !_editable);
                  },
                )
              ],
            ),
            _editable
                ? Column(
                    children: <Widget>[
                      Text(
                        "mobile number",
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      TextFormField(
                        cursorHeight: 25,
                        scrollPadding: EdgeInsets.symmetric(
                          vertical: 0,
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (!value.contains(new RegExp(r'[+]'), 0) ||
                              value.contains(new RegExp(r'[A-Z]')) ||
                              value.contains(new RegExp(r'[a-z]')) ||
                              !value.contains(new RegExp(r'[0-9]')) ||
                              value.length < 8) {
                            return "Please Enter valid mobile number";
                          }
                          return null;
                        },
                      ),
                      Text(
                        "mobile number",
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      TextFormField(
                        cursorHeight: 25,
                        scrollPadding: EdgeInsets.symmetric(
                          vertical: 0,
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (!value.contains(new RegExp(r'[+]'), 0) ||
                              value.contains(new RegExp(r'[A-Z]')) ||
                              value.contains(new RegExp(r'[a-z]')) ||
                              !value.contains(new RegExp(r'[0-9]')) ||
                              value.length < 8) {
                            return "Please Enter valid mobile number";
                          }
                          return null;
                        },
                      ),
                      Text(
                        "mobile number",
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      TextFormField(
                        cursorHeight: 25,
                        scrollPadding: EdgeInsets.symmetric(
                          vertical: 0,
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (!value.contains(new RegExp(r'[+]'), 0) ||
                              value.contains(new RegExp(r'[A-Z]')) ||
                              value.contains(new RegExp(r'[a-z]')) ||
                              !value.contains(new RegExp(r'[0-9]')) ||
                              value.length < 8) {
                            return "Please Enter valid mobile number";
                          }
                          return null;
                        },
                      ),
                      Text(
                        "mobile number",
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      TextFormField(
                        cursorHeight: 25,
                        scrollPadding: EdgeInsets.symmetric(
                          vertical: 0,
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (!value.contains(new RegExp(r'[+]'), 0) ||
                              value.contains(new RegExp(r'[A-Z]')) ||
                              value.contains(new RegExp(r'[a-z]')) ||
                              !value.contains(new RegExp(r'[0-9]')) ||
                              value.length < 8) {
                            return "Please Enter valid mobile number";
                          }
                          return null;
                        },
                      ),
                    ],
                  )
                : Column(
                    children: <Widget>[
                      Text("not edit"),
                    ],
                  ),
          ],
        ),
      )
    ];
  }
  List<Widget> createView() {
    return (this.pageView);
  }
}
