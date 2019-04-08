
import 'package:angular/angular.dart';
import 'package:attendance_dashboard/app_component.template.dart' as ng;
import 'package:firebase/firebase.dart' as fb;
import 'package:http/browser_client.dart';
import 'package:http/http.dart';
import 'main.template.dart' as self;
import 'secret.dart';

@GenerateInjector([
  ClassProvider(Client, useClass: BrowserClient),
])
final InjectorFactory injector = self.injector$Injector;


void main() {
  fb.initializeApp(
    apiKey: Secrets.apiKey,
    authDomain: "attendance-c43bb.firebaseapp.com",
  );
  runApp(ng.AppComponentNgFactory, createInjector: injector);
}