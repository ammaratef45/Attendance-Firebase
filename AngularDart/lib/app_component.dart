import 'dart:async';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/material_expansionpanel/material_expansionpanel.dart';
import 'package:angular_components/material_expansionpanel/material_expansionpanel_set.dart';
import 'package:attendance_dashboard/src/class.dart';
import 'package:attendance_dashboard/src/user_service.dart';
import 'package:firebase_dart_ui/firebase_dart_ui.dart';
import 'package:firebase/firebase.dart' as fb;


import 'package:firebase/src/interop/firebase_interop.dart';
import 'package:js/js.dart';

import 'dart:js';

@Component(
  selector: 'my-app',
  templateUrl: 'app_component.html',
  styleUrls: ['app_component.css'],
  directives: const[
    NgIf,
    FirebaseAuthUIComponent,
    coreDirectives,
    MaterialExpansionPanel,
    MaterialExpansionPanelSet,
  ],
  providers: const[
    UserService,
    materialProviders
  ]
)
class AppComponent {
  UIConfig _uiConfig;
  final UserService _userService;
  AppComponent(this._userService) {
    getUserInfo();
  }

  save() {

  }

  cancel() {

  }

  Future<Null> logout() async {
    await fb.auth().signOut();
  }
  PromiseJsImpl<void>  signInFailure(AuthUIError authUiError) {
    return new PromiseJsImpl<void>( () => print("SignIn Failure"));
  }

  bool signInSuccess(fb.UserCredential authResult, String redirectUrl) {
    print("sign in  success. ProviderID =  ${authResult.credential.providerId}");
    print("Info= ${authResult.additionalUserInfo}");
    getUserInfo();
    return false;
  }

  void getUserInfo() async {
    await Future.delayed(Duration(seconds: 3));
    String token = await fb.auth().currentUser?.getIdToken();
    print(token);
    this.userInfo =  await _userService.getInfo(token);
    print(this.userInfo);
  }

  UIConfig getUIConfig() {
    if (_uiConfig == null) {
      var googleOptions = new CustomSignInOptions(
          provider: fb.GoogleAuthProvider.PROVIDER_ID,
          scopes: ['email', 'https://www.googleapis.com/auth/plus.login'],
          customParameters:
              new GoogleCustomParameters(prompt: 'select_account'));


      var callbacks = new Callbacks(
          uiShown: () => print("UI shown callback"),
          signInSuccessWithAuthResult: allowInterop(signInSuccess),
          signInFailure: signInFailure
      );


      _uiConfig = new UIConfig(
          signInSuccessUrl: '/',
          signInOptions: [
            googleOptions
          ],
          signInFlow: "popup",
          credentialHelper: ACCOUNT_CHOOSER,
          tosUrl: '/tos.html',
          callbacks: callbacks);
    }
    return _uiConfig;
  }

  bool isAuthenticated() => fb.auth().currentUser != null;
  String get userEmail => fb.auth().currentUser?.email;
  String get displayName => fb.auth().currentUser?.displayName;
  String get imageURL => fb.auth().currentUser?.photoURL;
  Map<String, dynamic> get userJson => fb.auth().currentUser?.toJson();
  List<Class> userInfo = List();
}