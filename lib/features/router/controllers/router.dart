import 'package:go_router/go_router.dart';
import 'package:pumpkin_app/features/pumpkin/views/server_home.dart';

final routerController = GoRouter(
  /*
   TODO: Handle multiple servers
  
  Idea: Handle servers with UUIDs. When creating a new server, 
  change the working directory to the existing one + the uuid.
  */
  initialLocation: '/server',
  routes: [
    GoRoute(
      path: "/server",
      pageBuilder: (context, state) => NoTransitionPage(
        child: ConsoleView(),
      ),
    ),
  ],
);

class NoTransitionPage<T> extends CustomTransitionPage<T> {
  NoTransitionPage({
    required super.child,
    super.key,
  }) : super(
          transitionsBuilder: (_, __, ___, child) => child,
        );
}
