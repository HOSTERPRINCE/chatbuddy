import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firebase=FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form=GlobalKey<FormState>();
  var _enteredEmail="";
  var _enteredPassword="";
  var _isLogin=true;
  var _enteredUsername="";
  var _isAuthenticating=false;
  void _submit() async{
    final isValid=_form.currentState!.validate();
    if(!isValid){
      return;
    }
    _form.currentState!.save();
    try{
      setState(() {
        _isAuthenticating=true;
      });
      if(_isLogin){

        final userCredentials= await _firebase.signInWithEmailAndPassword(email: _enteredEmail, password: _enteredPassword);



      }
      else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
        await FirebaseFirestore.instance.collection("users").doc(userCredentials.user!.uid).set({
          "username":_enteredUsername,
          "email":_enteredEmail,
        });
      }

    }on FirebaseAuthException catch(error){
        if(error.code=="email-already-in-use"){
          
        }
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message?? "Authentication failed")));
        setState(() {
          _isAuthenticating=false;
        });
    }


    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 30,left: 20,right: 20,bottom: 20),
                width: 200,
                child: Image.asset("assets/images/chat.png"),
              ),
              Card(
                margin: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  padding:EdgeInsets.all(16),
                  child: Form(
                    key: _form,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if(!_isLogin)
                          Container(width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child:Icon(Icons.account_circle_sharp,size: 70,color: Theme.of(context).colorScheme.primary,),
                            ) ,


                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Email address",

                          ),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          validator: (value){
                            if(value==null || value.trim().isEmpty || !value.contains("@")){
                              return "Please enter a valid email address";
                            }
                            return null;
                          },
                          onSaved: (value){
                            _enteredEmail=value!;
                          },

                        ),
                        if(!_isLogin)
                          TextFormField(
                          decoration: InputDecoration(
                            labelText: "Username"
                          ),
                          enableSuggestions: false,
                          onSaved: (value){
                            _enteredUsername=value!;
                          },
                          validator: (value){
                            if(value==null||value.trim().length<4 || value.isEmpty){
                              return "Please entre at least 4 characters.";
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Password",

                          ),
                          obscureText: true,
                          validator: (value){
                            if(value==null || value.trim().length<6 ){
                              return "Password must be at least 6 characters long";
                            }
                            return null;
                          },
                          onSaved: (value){
                            _enteredPassword=value!;
                          },

                        ),
                        SizedBox(height: 12,),
                        if(_isAuthenticating)
                          const CircularProgressIndicator(),
                        if(!_isAuthenticating)
                          ElevatedButton(style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer
                        ),onPressed: _submit, child: Text(_isLogin ? "Login":"Signup")),
                        if(!_isAuthenticating)
                          TextButton(onPressed: (){
                          setState(() {
                            _isLogin=!_isLogin;
                          });
                        }, child: Text(_isLogin? "Create an account" : "I already have an account"))
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
