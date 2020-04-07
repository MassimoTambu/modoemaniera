import 'package:flutter/material.dart';

import 'models/counters.dart';

class CounterForm extends StatefulWidget {
  @override
  _CounterFormState createState() => _CounterFormState();
}

class _CounterFormState extends State<CounterForm> {
  final _formKey = GlobalKey<FormState>();

  String text = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: const EdgeInsets.all(16),
            elevation: 0,
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    autofocus: true,
                    decoration: InputDecoration(labelText: 'Counter Name'),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter some text!';
                      }
                      text = value;
                      return null;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        RaisedButton(
                          color: Colors.blue,
                          textColor: Colors.white,
                          onPressed: () {
                            // Validate will return true if the form is valid, or false if
                            // the form is invalid.
                            if (_formKey.currentState.validate()) {
                              // Process data.
                              Navigator.of(context).pop(
                                Counter(text, []),
                              );
                            }
                          },
                          child: Text('Submit'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
