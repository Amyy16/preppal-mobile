import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Data layer
import 'package:prepal2/data/datasources/auth/auth_remote_datasource.dart';
import 'package:prepal2/data/datasources/inventory/inventory_remote_datasource.dart';
import 'package:prepal2/data/repositories/auth_repository_impl.dart';
import 'package:prepal2/data/repositories/inventory_repository_impl.dart';

// Domain layer
import 'package:prepal2/domain/usercases/login_usercase.dart';
import 'package:prepal2/domain/usercases/signup_usercase.dart';
import 'package:prepal2/domain/usecases/inventory_usecases.dart';

// Presentation layer
import 'package:prepal2/presentation/providers/auth_provider.dart';
import 'package:prepal2/presentation/providers/inventory_provider.dart';
import 'package:prepal2/presentation/screens/splash/splash_screen.dart';

void main() async {
  // Required when calling async code before runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences - needed before building the widget tree
  final sharedPreferences = await SharedPreferences.getInstance();

  // --- Wire up the dependency chain (bottom to top) ---

  // 1. DataSource (innermost - talks to API/mock)
  final authDataSource = MockAuthDataSource();

  // 2. Repository (takes datasource + local storage)
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authDataSource,
    sharedPreferences: sharedPreferences,
  );

  // 3. UseCase (takes repository)
  final loginUseCase = LoginUseCase(repository: authRepository);
  final signupUseCase = SignupUseCase(repository: authRepository);

  // Inventory dependency chain
  final inventoryDataSource = MockInventoryRemoteDataSource();
  final inventoryRepository = InventoryRepositoryImpl(
    remoteDataSource: inventoryDataSource,
  );

  runApp(
    // MultiProvider makes our providers available to the entire widget tree
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            loginUseCase: loginUseCase,
            signupUseCase: signupUseCase,
            authRepository: authRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => InventoryProvider(
            getAllProducts: GetAllProductsUseCase(repository: inventoryRepository),
            addProduct: AddProductUseCase(repository: inventoryRepository),
            updateProduct: UpdateProductUseCase(repository: inventoryRepository),
            deleteProduct: DeleteProductUseCase(repository: inventoryRepository),
          ),
        ),
      ],
      child: const PrepPalApp(),
    ),
  );
}
class PrepPalApp extends StatelessWidget {
  const PrepPalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PrePal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xf1f032f),
          primary: const Color(0xf1f032f),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        // Global input decoration theme - all textfields inherit this
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xf1f032f), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xffff0000)),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xf1f032f),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      // Show WelcomeScreen first
      home: const WelcomeScreen(),

      // go_router approach (commented) - uncomment to switch
      // routerConfig: AppRouter.router,
    );
  }
}