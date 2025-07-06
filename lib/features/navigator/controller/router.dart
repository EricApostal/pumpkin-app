import 'package:go_router/go_router.dart';
import 'package:pumpkin_app/features/console/views/console.dart';
import 'package:pumpkin_app/features/files/views/file_browser.dart';
import 'package:pumpkin_app/features/navigator/views/navigation_scope.dart';

final routerController = GoRouter(
  /*
   TODO: Handle multiple servers
  
  Idea: Handle servers with UUIDs. When creating a new server, 
  change the working directory to the existing one + the uuid.
  */
  initialLocation: '/console',
  routes: [
    GoRoute(
      path: "/",
      redirect: (context, state) {
        return "/console";
      },
    ),
    ShellRoute(
      builder: (context, state, child) => NavigationScope(child: child),
      routes: [
        GoRoute(path: "/console", builder: (context, state) => ConsoleScreen()),
        GoRoute(
          path: "/files",
          builder: (context, state) => FileBrowserScreen(),
        ),
      ],
    ),
  ],
);
