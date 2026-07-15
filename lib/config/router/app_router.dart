import 'package:go_router/go_router.dart';
import '../../Presentation/screens/screens.dart';

final appRouter = GoRouter(
  initialLocation: '/home/0',
  routes: [
    GoRoute(
      path: '/home/:page',
      builder: (context, state) {
        final pageIndex = int.parse(state.pathParameters['page'] ?? '0');
        if (pageIndex < 0) {
          return const HomeScreen(pageIndex: 0);
        }
        return HomeScreen(pageIndex: pageIndex);
      },
    ),
  ],
);
