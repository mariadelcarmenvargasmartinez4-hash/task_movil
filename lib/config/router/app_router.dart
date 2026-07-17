import 'package:go_router/go_router.dart';
import '../../Presentation/screens/screens.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home/:page',
      builder: (context, state) {
        final pageIndex = int.parse(state.pathParameters['page'] ?? '0');
        final role = state.uri.queryParameters['role'] ?? 'hijo';
        final email = state.uri.queryParameters['email'] ?? '';
        
        final safePageIndex = pageIndex < 0 ? 0 : pageIndex;
        return HomeScreen(pageIndex: safePageIndex, role: role, email: email);
      },
    ),
  ],
);
