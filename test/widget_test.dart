import 'package:clean_arch_session/core/di/dependency_injection.dart';
import 'package:clean_arch_session/core/routes/routes.dart';
import 'package:clean_arch_session/feature/auth/presentation/ui/login_screen.dart';
import 'package:clean_arch_session/e_commerce_customer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  setUpAll(() {
    dotenv.loadFromString(
      envString:
          'API_BASE_URL=https://easylearn.devawy.com/api\nAPI_KEY=test-key',
    );
    setupGetIt();
  });

  testWidgets('starts on the login screen', (tester) async {
    await tester.pumpWidget(const MyApp(initialRoute: Routes.login));

    expect(find.byType(LoginScreen, skipOffstage: false), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
