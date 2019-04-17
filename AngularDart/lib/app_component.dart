import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:js';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/material_expansionpanel/material_expansionpanel.dart';
import 'package:angular_components/material_expansionpanel/material_expansionpanel_set.dart';
import 'package:attendance_dashboard/src/class.dart';
import 'package:attendance_dashboard/src/sessions.dart';
import 'package:attendance_dashboard/src/user_service.dart';
import 'package:firebase_dart_ui/firebase_dart_ui.dart';
import 'package:firebase/firebase.dart' as fb;

//ignore: implementation_imports
import 'package:firebase/src/interop/firebase_interop.dart';
import 'package:js/js.dart';



@Component(
  selector: 'my-app',
  templateUrl: 'app_component.html',
  styleUrls: <String>['app_component.css'],
  directives: <dynamic> [
    NgIf,
    FirebaseAuthUIComponent,
    coreDirectives,
    MaterialExpansionPanel,
    MaterialExpansionPanelSet,
    MaterialProgressComponent
  ],
  providers: <dynamic> [
    UserService,
    materialProviders
  ]
)
/// Main Component
class AppComponent {
  /// constructor
  AppComponent(this._userService) {
    getUserInfo();
  }
  UIConfig _uiConfig;
  final UserService _userService;
  /// is page loading?
  bool loading = false;
  
  /// download a sheet of a session
  Future<void> downloadSessionSheet(Class aclass, Session session) async {
    loading = true;
    try {
      final String token = await fb.auth().currentUser?.getIdToken();
      final String file = await _userService.getSessionSheet(
        token,
        classKey: aclass.key,
        sessionKey: session.key
      );
      final String encodedFileContents = Uri.encodeComponent(file);
      AnchorElement(href: 'data:text/plain;charset=utf-8,$encodedFileContents')
        ..setAttribute('download', 'file.csv')
        ..click();
      print(file);
    } catch (e) {
      print(e.toString());
      window.alert(e.toString());
    } finally {
      loading = false;
    }
  }

  /// download a sheet of a class
  Future<void> downloadClassSheet(Class aclass) async {
    loading = true;
    try {
      final String token = await fb.auth().currentUser?.getIdToken();
      final String file = await _userService.getSessionSheet(
        token,
        classKey: aclass.key
      );
      final String encodedFileContents = Uri.encodeComponent(file);
      AnchorElement(href: 'data:text/plain;charset=utf-8,$encodedFileContents')
        ..setAttribute('download', 'file.csv')
        ..click();
      print(file);
    } catch (e) {
      print(e.toString());
      window.alert(e.toString());
    } finally {
      loading = false;
    }
  }

  /// download qr
  Future<void> downloadQR(Class aclass, Session session) async {
    final String token = await fb.auth().currentUser?.getIdToken();
    final String response = await _userService.qrCode(
      token,
      aclass.key,
      session.key
    );
    final String url = (json.decode(response))['data'][0];
    AnchorElement(href: url)
    ..setAttribute('download', 'qr.png')
    ..click();
    print(url);
  }

  /// delete a class from db
  Future<void> deleteClass(Class aclass) async {
    final String result = 
      context.callMethod(
      'prompt',
      <dynamic>["Write 'I confirm' to confirm deletion"]
    );
    if(result.toLowerCase()=='I confirm'.toLowerCase()) {
      final String token = await fb.auth().currentUser?.getIdToken();
      final String response = await _userService.delete(
        token,
        classKey: aclass.key
      );
      // ignore: unawaited_futures
      getUserInfo();
      window.alert(response);
    }
  }

  /// delete a session from db
  Future<void> deleteSession(Class aclass, Session session) async {
    final String result = 
      context.callMethod(
      'prompt',
      <dynamic>["Write 'I confirm' to confirm deletion"]
    );
    if(result.toLowerCase()=='I confirm'.toLowerCase()) {
      final String token = await fb.auth().currentUser?.getIdToken();
      final String response = await _userService.delete(
        token,
        classKey: aclass.key,
        sessionKey: session.key
      );
      // ignore: unawaited_futures
      getUserInfo();
      window.alert(response);
    }
  }

  /// logout the user
  Future<void> logout() async {
    await fb.auth().signOut();
  }

  /// sign in failed
  PromiseJsImpl<void>  signInFailure(AuthUIError authUiError) =>
    PromiseJsImpl<void>( () => print('SignIn Failure'));

  /// sigin successed
  bool signInSuccess(fb.UserCredential authResult, String redirectUrl) {
    print(
      'sign in  success. ProviderID = '
      '${authResult.credential.providerId}'
    );
    print('Info= ${authResult.additionalUserInfo}');
    getUserInfo();
    return false;
  }

  /// get the user's info
  Future<void> getUserInfo() async {
    loading = true;
    try {
      await Future<void>.delayed(Duration(seconds: 3));
      final String token = await fb.auth().currentUser?.getIdToken();
      userInfo
      ..clear()
      ..addAll(await _userService.getInfo(token));
    } catch (e) {
      print(e.toString());
      window.alert(e.toString());
    } finally {
      loading = false;
    }
  }

  /// get the ui configurations
  UIConfig getUIConfig() {
    if (_uiConfig == null) {
      final CustomSignInOptions googleOptions = CustomSignInOptions(
          provider: fb.GoogleAuthProvider.PROVIDER_ID,
          scopes: <String>['email', 'https://www.googleapis.com/auth/plus.login'],
          customParameters:
              GoogleCustomParameters(prompt: 'select_account'));


      final Callbacks callbacks = Callbacks(
          uiShown: () => print('UI shown callback'),
          signInSuccessWithAuthResult: allowInterop(signInSuccess),
          signInFailure: signInFailure
      );


      _uiConfig = UIConfig(
          signInSuccessUrl: '/',
          signInOptions: <dynamic>[
            googleOptions
          ],
          signInFlow: 'popup',
          credentialHelper: ACCOUNT_CHOOSER,
          tosUrl: '/tos.html',
          callbacks: callbacks);
    }
    return _uiConfig;
  }

  /// isAuthenticated
  bool isAuthenticated() => fb.auth().currentUser != null;
  /// userEmail
  String get userEmail => fb.auth().currentUser?.email;
  /// displayName
  String get displayName => fb.auth().currentUser?.displayName;
  /// imageURL
  String get imageURL => fb.auth().currentUser?.photoURL;
  /// userJson data
  Map<String, dynamic> get userJson => fb.auth().currentUser?.toJson();
  /// userInfo
  final List<Class> userInfo = <Class>[];
}