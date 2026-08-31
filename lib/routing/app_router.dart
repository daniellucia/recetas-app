import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/auth/auth_session.dart';
import '../data/repositories/menus_repository.dart';
import '../data/repositories/recipes_repository.dart';
import '../ui/core/ui_shell.dart';
import '../ui/features/auth/view_models/auth_view_model.dart';
import '../ui/features/auth/views/login_screen.dart';
import '../ui/features/import/view_models/import_view_model.dart';
import '../ui/features/import/views/import_screen.dart';
import '../ui/features/menu/view_models/menu_view_model.dart';
import '../ui/features/menu/views/menu_screen.dart';
import '../ui/features/recipes/view_models/recipe_detail_view_model.dart';
import '../ui/features/recipes/view_models/recipes_list_view_model.dart';
import '../ui/features/recipes/views/cook_mode_screen.dart';
import '../ui/features/recipes/views/recipe_detail_screen.dart';
import '../ui/features/recipes/views/recipes_list_screen.dart';
import '../ui/features/shopping_list/view_models/shopping_list_view_model.dart';
import '../ui/features/shopping_list/views/shopping_list_screen.dart';

GoRouter buildAppRouter({required AuthSession authSession}) {
  return GoRouter(
    initialLocation: '/recetas',
    refreshListenable: authSession,
    redirect: (context, state) {
      final loggingIn = state.matchedLocation == '/login';
      if (!authSession.isAuthenticated) {
        return loggingIn ? null : '/login';
      }
      if (loggingIn) return '/recetas';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => ChangeNotifierProvider(
          create: (context) => AuthViewModel(
            authRepository: context.read(),
          ),
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/recetas/:slug',
        builder: (context, state) => ChangeNotifierProvider(
          create: (context) => RecipeDetailViewModel(
            recipesRepository: context.read<RecipesRepository>(),
            slug: state.pathParameters['slug']!,
          ),
          child: const RecipeDetailScreen(),
        ),
      ),
      GoRoute(
        path: '/recetas/:slug/modo-cocina',
        builder: (context, state) => CookModeScreen(
          steps: (state.extra as List?)?.cast<String>() ?? const [],
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            UiShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/recetas',
              builder: (context, state) => ChangeNotifierProvider(
                create: (context) => RecipesListViewModel(
                  recipesRepository: context.read<RecipesRepository>(),
                ),
                child: const RecipesListScreen(),
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/menu',
              builder: (context, state) => ChangeNotifierProvider(
                create: (context) => MenuViewModel(
                  menusRepository: context.read<MenusRepository>(),
                ),
                child: const MenuScreen(),
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/lista-compra',
              builder: (context, state) => ChangeNotifierProvider(
                create: (context) => ShoppingListViewModel(
                  menusRepository: context.read<MenusRepository>(),
                ),
                child: const ShoppingListScreen(),
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/compartir',
              builder: (context, state) => ChangeNotifierProvider(
                create: (context) => ImportViewModel(
                  recipesRepository: context.read<RecipesRepository>(),
                ),
                child: const ImportScreen(),
              ),
            ),
          ]),
        ],
      ),
    ],
  );
}
