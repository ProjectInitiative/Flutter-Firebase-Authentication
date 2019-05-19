import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:flutterfire_auth/UI/primary_button.dart';
import 'package:flutterfire_auth/utils/auth.dart';
import 'package:flutterfire_auth/utils/static.dart';

import 'home.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.auth, this.snackBarInfo}) : super(key: key);

  final Auth auth;
  final SnackBarInfo snackBarInfo;

  @override
  _LoginPageState createState() => new _LoginPageState();
}

enum FormType { login, register }

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  static final formKey = new GlobalKey<FormState>();
  final _passController = new TextEditingController();
  BuildContext _context;

  String _email;
  String _password;
  FormType _formType = FormType.login;
  String _authHint = '';
  AnimationController _confirmPassCntrl;
  AnimationController _gSignInCntrl;

  @override
  void initState() {
    super.initState();
    _confirmPassCntrl = new AnimationController(
      duration: new Duration(milliseconds: 0),
      vsync: this,
    );
    _gSignInCntrl = new AnimationController(
      duration: new Duration(milliseconds: 0),
      vsync: this,
    );
    _gSignInCntrl.forward();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => Static.showSnackbar(_context, widget.snackBarInfo)); 
  }

  @override
  void dispose() {
    _confirmPassCntrl.dispose();
    _gSignInCntrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomInset: true,
        appBar: new AppBar(
          title: new Text('New App'),
        ),
        //backgroundColor: Colors.grey[300],
        body: new Builder(
          builder: (BuildContext context) {
            _context = context;
            return new SingleChildScrollView(
                child: new Container(
                    padding: const EdgeInsets.all(16.0),
                    child: new Column(children: [
                      new Card(
                          child: new Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                            new Container(
                                padding: const EdgeInsets.all(16.0),
                                child: new Form(
                                    key: formKey,
                                    child: new Column(
                                      // crossAxisAlignment:
                                      //     CrossAxisAlignment.stretch,
                                      children: usernameAndPassword() +
                                          submitWidgets(),
                                    ))),
                          ])),
                      //hintText()
                    ])));
          },
        ));
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        String userId = _formType == FormType.login
            ? await widget.auth.signIn(_email, _password)
            : await widget.auth.createUser(_email, _password);
        setState(() {
          _authHint = 'Signed In\n\nUser id: $userId';
        });
        _signIn();
      } catch (e) {
        setState(() {
          _authHint = 'Sign In Error\n\n${e.toString()}';
        });
        Static.showSnackbar(
            _context,
            new SnackBarInfo('Sign-in error', 3, true,
                action: new SnackBarAction(
                    label: 'Retry', onPressed: validateAndSubmit)));
        print(e);
      }
    } else {
      setState(() {
        _authHint = '';
      });
    }
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void signInWithGoogle() async {
    try {
      String userId = await widget.auth.signInWithGoogle();
      setState(() {
        _authHint = 'Signed In\n\nUser id: $userId';
      });
      _signIn();
    } catch (e) {
      setState(() {
        _authHint = 'Sign In Error\n\n${e.toString()}';
        Static.showSnackbar(
            _context,
            new SnackBarInfo('Sign-in error', 3, true,
                action: new SnackBarAction(
                    label: 'Retry', onPressed: signInWithGoogle)));
      });
      print(e);
    }
  }

  void moveToRegister() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.register;
      _authHint = '';
    });
    _confirmPassCntrl.duration = new Duration(milliseconds: 250);
    _gSignInCntrl.duration = new Duration(milliseconds: 250);
    _confirmPassCntrl.forward();
    _gSignInCntrl.reverse();
  }

  void moveToLogin() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.login;
      _authHint = '';
    });
    _confirmPassCntrl.duration = new Duration(milliseconds: 250);
    _gSignInCntrl.duration = new Duration(milliseconds: 250);
    _gSignInCntrl.forward();
    _confirmPassCntrl.reverse();
  }

  List<Widget> usernameAndPassword() {
    return [
      new AnimatedSize(
        vsync: this,
        duration: new Duration(milliseconds: 250),
        curve: Curves.linear,
        child: padded(
            child: new TextFormField(
          key: new Key('email'),
          keyboardType: TextInputType.emailAddress,
          decoration: new InputDecoration(labelText: 'Email'),
          autocorrect: false,
          validator: (val) => val.isEmpty ? 'Email can\'t be empty.' : null,
          onSaved: (val) => _email = val,
        )),
      ),
      new AnimatedSize(
        vsync: this,
        duration: new Duration(milliseconds: 250),
        curve: Curves.linear,
        child: padded(
            child: new TextFormField(
              key: new Key('password'),
              controller: _passController,
              decoration: new InputDecoration(labelText: 'Password'),
              obscureText: true,
              autocorrect: false,
              validator: (val) =>
                  val.isEmpty ? 'Password can\'t be empty.' : null,
              onSaved: (val) => _password = val,
            )),
      ),
      new SizeTransition(
          sizeFactor:
              CurvedAnimation(parent: _confirmPassCntrl, curve: Curves.linear),
          axisAlignment: 0.0,
          child: new AnimatedSize(
            vsync: this,
            duration: new Duration(milliseconds: 250),
            curve: Curves.linear,
            child: padded(
                child: new TextFormField(
          key: new Key('confirm-password'),
          decoration: new InputDecoration(labelText: 'Confirm password'),
          obscureText: true,
          autocorrect: false,
          enabled: _formType == FormType.register,
          validator: (val) =>
              val != _passController.text && _formType == FormType.register
                  ? 'Passwords must match'
                  : null,
          )))),
    ];
  }

  List<Widget> submitWidgets() {
    String btnText;
    String accntText;
    Function accntFunc;
    switch (_formType) {
      case FormType.login:
        btnText = 'Login';
        accntText = 'Need an account? Register';
        accntFunc = moveToRegister;
        break;
      case FormType.register:
        btnText = 'Create an account';
        accntText = 'Have an account? Login';
        accntFunc = moveToLogin;
        break;
    }
    return [
      padded(
          child: new PrimaryButton(
              key: new Key('button'),
              text: btnText,
              height: 44.0,
              onPressed: validateAndSubmit)),
      new SizeTransition(
        sizeFactor:
            new CurvedAnimation(parent: _gSignInCntrl, curve: Curves.linear),
        axisAlignment: 0.0,
        child: padded(
            child: Center(
          child: new GoogleSignInButton(
              key: new Key('signin-with-google'),
              darkMode: Theme.of(context).brightness == Brightness.dark,
              onPressed: _formType == FormType.login ? signInWithGoogle : null),
        )),
      ),
      new FlatButton(
          key: new Key('account'),
          child: new Text(accntText),
          onPressed: accntFunc),
    ];
  }

  Widget hintText() {
    return new Container(
        //height: 80.0,
        padding: const EdgeInsets.all(32.0),
        child: new Text(_authHint,
            key: new Key('hint'),
            style: new TextStyle(fontSize: 18.0, color: Colors.grey),
            textAlign: TextAlign.center));
  }

  Widget padded({Widget child}) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: child,
    );
  }

  void _signIn() {
    try {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => new HomePage(
                    auth: widget.auth,
                    snackBarInfo:
                        new SnackBarInfo('Logged in Successfully', 3, true),
                  )));
    } catch (e) {
      print(e);
    }
  }
}
