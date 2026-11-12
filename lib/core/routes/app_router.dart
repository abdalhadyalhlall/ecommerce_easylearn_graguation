import 'package:clean_arch_session/core/di/dependency_injection.dart';
import 'package:clean_arch_session/core/routes/routes.dart';
import 'package:clean_arch_session/feature/auth/presentation/cubit/auth_cubit.dart';
import 'package:clean_arch_session/feature/auth/presentation/ui/login_screen.dart';
import 'package:clean_arch_session/feature/auth/presentation/ui/otp_screen.dart';
import 'package:clean_arch_session/feature/auth/presentation/ui/register_screen.dart';
import 'package:clean_arch_session/feature/profile/presentation/cubit/profile_cubit.dart';
import 'package:clean_arch_session/feature/store/presentation/cubit/store_cubit.dart';
import 'package:clean_arch_session/feature/store/presentation/ui/screen/store_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppRouter {
  Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case Routes.login:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<AuthCubit>(),
            child: const LoginScreen(),
          ),
        );
      case Routes.register:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<AuthCubit>(),
            child: const RegisterScreen(),
          ),
        );
      case Routes.otp:
        final email = settings.arguments;
        if (email is! String || email.isEmpty) return null;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<AuthCubit>(),
            child: OtpScreen(email: email),
          ),
        );
      case Routes.welcome:
        return MaterialPageRoute(
          builder: (_) => const VerificationSuccessScreen(),
        );
      case Routes.store:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => getIt<AuthCubit>()),
              BlocProvider(create: (_) => getIt<StoreCubit>()),
              BlocProvider(create: (_) => getIt<ProfileCubit>()),
            ],
            child: const StoreScreen(),
          ),
        );
      default:
        return null;
    }
  }
}
