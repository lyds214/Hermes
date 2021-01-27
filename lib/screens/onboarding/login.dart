import 'package:flutter/material.dart';

import '../student/student_tabs.dart';

class Login extends StatefulWidget {
  static const routeName = '/login';
  

  LoginState createState() => LoginState();
}
  
class LoginState extends State<Login> {
  List<String> occupation = ["Student", "Donor"];
  String selectedLocation;

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>
          [
            Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Center(
                child: Container(
                  width: 200,
                  height: 150,
                  child: Icon(
                    Icons.headset_rounded,
                    color: Colors.blue,
                    size: 30,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 0, bottom: 0),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "User",
                  hintText: "User",
                ),
              ),
            ),

            SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 0, bottom: 0),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Password",
                  hintText: "Password",
                ),
              ),
            ),

            SizedBox(height: 20),

           //Drop Down menu
           Container(
             width: 375,
             child: DropdownButton(
              hint: Text(" I am a...                                                                                   ", /*textAlign: TextAlign.center*/),
              value: selectedLocation,
              onChanged: (newValue) {
                setState(() {
                  selectedLocation = newValue;
                });
             },

             items: occupation.map((occupation) {
               return DropdownMenuItem(
                 child: new Text(occupation),
                 value: occupation
               );
             }).toList(),
           ),
           ),
           

          SizedBox(height: 20),

            Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),

              child: FlatButton(
                onPressed: (){
                  Navigator.of(context).pushNamed(StudentTabs.routeName);
                },
                child: Text(
                  "Login",
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
            ),

            //Forgot Password button
            /*FlatButton(
              onPressed: (){},
              child: Text(
                "Forgot Password",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 15,
                ),
              ),
            ),*/

            SizedBox(height: 130),

            Container(
              child: Column(
                children: <Widget>
                [
                  Text("Don't have an account?"),
                  FlatButton(
                    onPressed: (){},
                    child: Text(
                      "Register",
                      style: TextStyle(
                      color: Colors.blue,
                      fontSize: 15,
                    ),
                  ),
                ),
                ],
              ), 
            ),
            

            

          ],
        ),
      ),
        
    );
  }
} 
  
