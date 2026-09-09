import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotfit/app.dart';
import 'package:spotfit/player/player_controller.dart';
import 'package:spotfit/state/auth_controller.dart';
import 'package:spotfit/state/catalog_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('entra no modo demo e vê a home de treino', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final auth = AuthController();
    await auth.bootstrap();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider(create: (_) => PlayerController()),
          ChangeNotifierProvider(
            create: (_) => CatalogController(userId: 'demo-user'),
          ),
        ],
        child: const SpotFitApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('SpotFit'), findsWidgets);

    await tester.tap(find.text('Entrar no modo treino (demo)'));
    await tester.pumpAndSettle();

    expect(find.text('Início'), findsOneWidget);
    expect(find.text('Playlists oficiais'), findsOneWidget);
    expect(find.text('Cardio Endurance'), findsOneWidget);

    await tester.tap(find.text('Biblioteca'));
    await tester.pumpAndSettle();
    expect(find.text('Sua biblioteca'), findsOneWidget);
    expect(find.text('Criar playlist'), findsOneWidget);
  });
}
