// import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:http/http.dart';

class Schedule {
  dynamic timing;
  Table table;
  List days = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday"
  ];
  Schedule(dynamic details) {
    if (details != null) timing = details['timing'];
    // print("\n\n\n\n\n\n\n\n");
    // print("details: $details");
    // && details.body.runtimeType.toString()== ""
    // if (details != null && details.runtimeType.toString() == 'Response') {
    // print("${details.body} :   ${details.runtimeType} \n\n\n\n");
    // this.timing = jsonDecode(details.body)[0]['timing'];
    // print(this.timing['work_days'].runtimeType.toString());
    // print(jsonDecode(details.body)[0]['timing']['work_days']);
    // }
  }

  Table create() {
    this.table = new Table(
      children: [
        TableRow(
          children: days
              .map(
                (day) => Container(
                  height: 100,
                  width: 100,
                  color: (timing != null &&
                          (this.timing['work_days'].runtimeType.toString() ==
                              "_InternalLinkedHashMap<String, dynamic>"))
                      ? ((timing['work_days']['$day'] == true)
                          ? Colors.green
                          : Colors.red)
                      : Colors.grey,
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 12,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        (timing.containsKey("night"))
            ? TableRow(
                children: days
                    .map(
                      (day) => Container(
                        height: 100,
                        width: 100,
                        color: (timing != null &&
                                (this
                                        .timing['work_days']
                                        .runtimeType
                                        .toString() ==
                                    "_InternalLinkedHashMap<String, dynamic>"))
                            ? ((timing['work_days']['$day'] == true)
                                ? Colors.lightGreen
                                : Colors.redAccent[400])
                            : Colors.grey,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(EdgeInsets.zero),
                            textStyle: MaterialStateProperty.all(
                              TextStyle(
                                  // fontSize: 12,
                                  ),
                            ),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.black),
                            backgroundColor: MaterialStateProperty.all(
                              (timing != null &&
                                      (this
                                              .timing['work_days']
                                              .runtimeType
                                              .toString() ==
                                          "_InternalLinkedHashMap<String, dynamic>"))
                                  ? ((timing['work_days']['$day'] == true)
                                      ? Colors.lightGreen
                                      : Colors.redAccent[400])
                                  : Colors.grey,
                            ),
                          ),
                          onPressed: () {},
                          child: Text(
                            "${timing['morning']['from']}\n ${timing['morning']['to']}",
                            style: TextStyle(
                              fontSize: 12,
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              )
            : null,
        (timing.containsKey("night"))
            ? TableRow(
                children: days
                    .map(
                      (day) => Container(
                        height: 100,
                        width: 100,
                        color: (timing != null &&
                                (this
                                        .timing['work_days']
                                        .runtimeType
                                        .toString() ==
                                    "_InternalLinkedHashMap<String, dynamic>"))
                            ? ((timing['work_days']['$day'] == true)
                                ? Colors.lightGreen
                                : Colors.redAccent[400])
                            : Colors.grey,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(EdgeInsets.zero),
                            textStyle: MaterialStateProperty.all(
                              TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.black),
                            backgroundColor: MaterialStateProperty.all(
                              (timing != null &&
                                      (this
                                              .timing['work_days']
                                              .runtimeType
                                              .toString() ==
                                          "_InternalLinkedHashMap<String, dynamic>"))
                                  ? ((timing['work_days']['$day'] == true)
                                      ? Colors.lightGreen
                                      : Colors.redAccent[400])
                                  : Colors.grey,
                            ),
                          ),
                          onPressed: () {},
                          child: Text(
                            "${timing['afternoon']['from']}\n ${timing['afternoon']['to']}",
                            style: TextStyle(
                              fontSize: 12,
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              )
            : null,
        (timing.containsKey("afternoon"))
            ? TableRow(
                children: days
                    .map(
                      (day) => Container(
                        height: 100,
                        width: 100,
                        color: (timing != null &&
                                (this
                                        .timing['work_days']
                                        .runtimeType
                                        .toString() ==
                                    "_InternalLinkedHashMap<String, dynamic>"))
                            ? ((timing['work_days']['$day'] == true)
                                ? Colors.lightGreen
                                : Colors.redAccent[400])
                            : Colors.grey,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(EdgeInsets.zero),
                            textStyle: MaterialStateProperty.all(
                              TextStyle(
                                  // fontSize: 12,
                                  ),
                            ),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.black),
                            backgroundColor: MaterialStateProperty.all(
                              (timing != null &&
                                      (this
                                              .timing['work_days']
                                              .runtimeType
                                              .toString() ==
                                          "_InternalLinkedHashMap<String, dynamic>"))
                                  ? ((timing['work_days']['$day'] == true)
                                      ? Colors.lightGreen
                                      : Colors.redAccent[400])
                                  : Colors.grey,
                            ),
                          ),
                          onPressed: () {},
                          child: Text(
                            "${timing['evening']['from']}\n ${timing['evening']['to']}",
                            style: TextStyle(
                              fontSize: 12,
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              )
            : null,
        (timing.containsKey("night"))
            ? TableRow(
                children: days
                    .map(
                      (day) => Container(
                        height: 100,
                        width: 100,
                        color: (timing != null &&
                                (this
                                        .timing['work_days']
                                        .runtimeType
                                        .toString() ==
                                    "_InternalLinkedHashMap<String, dynamic>"))
                            ? ((timing['work_days']['$day'] == true)
                                ? Colors.lightGreen
                                : Colors.redAccent[400])
                            : Colors.grey,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(EdgeInsets.zero),
                            textStyle: MaterialStateProperty.all(
                              TextStyle(
                                  // fontSize: 12,
                                  ),
                            ),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.black),
                            backgroundColor: MaterialStateProperty.all(
                              (timing != null &&
                                      (this
                                              .timing['work_days']
                                              .runtimeType
                                              .toString() ==
                                          "_InternalLinkedHashMap<String, dynamic>"))
                                  ? ((timing['work_days']['$day'] == true)
                                      ? Colors.lightGreen
                                      : Colors.redAccent[400])
                                  : Colors.grey,
                            ),
                          ),
                          onPressed: () {},
                          child: Text(
                            "${timing['night']['from']}\n ${timing['night']['to']}",
                            style: TextStyle(
                              fontSize: 12,
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              )
            : null,
      ],
    );
    return (this.table);
  }
}
