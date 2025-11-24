import 'package:go_router/go_router.dart';
import '../screens/home_page.dart';
import '../screens/diet_plans_page.dart';
import '../screens/diet_category_page.dart';
import '../screens/meal_details_page.dart';
import '../screens/workouts_page.dart';
import '../screens/workout_category_page.dart';
import '../screens/exercise_timer_page.dart';
import '../screens/profile_page.dart';
import '../screens/progress_tracker_page.dart';
import '../screens/settings_page.dart';
import '../screens/welcome_page.dart';
import '../screens/login_page.dart';
import '../screens/register_page.dart';
import '../screens/user_details_page.dart';
import '../screens/splash_page.dart';
import '../screens/motivation_page.dart';
import '../screens/age_selection_page.dart';
import '../screens/height_selection_page.dart';
import '../screens/weight_selection_page.dart';
import '../screens/strength_plan_selection_page.dart';
import '../screens/strength_workout_page.dart';
// breathing_exercise_page imported below (avoid duplicate)
import '../screens/goals_selection_page.dart';
import '../screens/yoga_page.dart';
import '../screens/firebase_test_page.dart';
import '../screens/workout_timer_page.dart';
import '../screens/plan_page.dart';
import '../screens/meditation_page.dart';
import '../screens/breathing_exercise_page.dart';
import '../screens/strength_days_list_page.dart';
import '../screens/cardio_plan_selection_page.dart';
import '../screens/cardio_days_list_page.dart';
import '../screens/cardio_workout_page.dart';
import '../screens/home_plan_selection_page.dart';
import '../screens/home_days_list_page.dart';
import '../screens/home_workout_page.dart';
import '../screens/yoga_workout_page.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashPage()),
    GoRoute(
      path: '/motivation',
      builder: (context, state) => const MotivationPage(),
    ),
    GoRoute(path: '/welcome', builder: (context, state) => const WelcomePage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/strength-plan-selection',
      builder: (context, state) => const StrengthPlanSelectionPage(),
    ),
    GoRoute(
      path: '/strength-days/:days',
      builder: (context, state) => StrengthDaysListPage(
        totalDays: int.parse(state.pathParameters['days'] ?? '7'),
      ),
    ),
    GoRoute(
      path: '/strength-workout/:days/:currentDay',
      builder: (context, state) => StrengthWorkoutPage(
        totalDays: int.parse(state.pathParameters['days'] ?? '7'),
        currentDay: int.parse(state.pathParameters['currentDay'] ?? '1'),
      ),
    ),

    // Cardio workout routes
    GoRoute(
      path: '/cardio-plan-selection',
      builder: (context, state) => const CardioPlanSelectionPage(),
    ),
    GoRoute(
      path: '/cardio-days/:days',
      builder: (context, state) => CardioDaysListPage(
        totalDays: int.parse(state.pathParameters['days'] ?? '7'),
      ),
    ),
    GoRoute(
      path: '/cardio-workout/:days/:currentDay',
      builder: (context, state) => CardioWorkoutPage(
        totalDays: int.parse(state.pathParameters['days'] ?? '7'),
        currentDay: int.parse(state.pathParameters['currentDay'] ?? '1'),
      ),
    ),

    // Home workout routes
    GoRoute(
      path: '/home-plan-selection',
      builder: (context, state) => const HomePlanSelectionPage(),
    ),
    GoRoute(
      path: '/home-days/:days',
      builder: (context, state) => HomeDaysListPage(
        totalDays: int.parse(state.pathParameters['days'] ?? '7'),
      ),
    ),
    GoRoute(
      path: '/home-workout/:days/:currentDay',
      builder: (context, state) => HomeWorkoutPage(
        totalDays: int.parse(state.pathParameters['days'] ?? '7'),
        currentDay: int.parse(state.pathParameters['currentDay'] ?? '1'),
      ),
    ),

    GoRoute(
      path: '/user-details',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return UserDetailsPage(
          email: extra?['email'] ?? '',
          password: extra?['password'] ?? '',
        );
      },
    ),
    GoRoute(
      path: '/age-selection',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return AgeSelectionPage(
          email: extra?['email'] ?? '',
          password: extra?['password'] ?? '',
          name: extra?['name'] ?? '',
          gender: extra?['gender'] ?? 'Male',
        );
      },
    ),
    GoRoute(
      path: '/height-selection',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return HeightSelectionPage(
          email: extra?['email'] ?? '',
          password: extra?['password'] ?? '',
          name: extra?['name'] ?? '',
          age: extra?['age'] ?? 25,
          gender: extra?['gender'] ?? 'Male',
        );
      },
    ),
    GoRoute(
      path: '/weight-selection',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return WeightSelectionPage(
          email: extra?['email'] ?? '',
          password: extra?['password'] ?? '',
          name: extra?['name'] ?? '',
          age: extra?['age'] ?? 25,
          gender: extra?['gender'] ?? 'Male',
          height: (extra?['height'] ?? 170.0).toDouble(),
        );
      },
    ),
    GoRoute(
      path: '/goals-selection',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return GoalsSelectionPage(
          email: extra?['email'] ?? '',
          password: extra?['password'] ?? '',
          name: extra?['name'] ?? '',
          age: extra?['age'] ?? 25,
          gender: extra?['gender'] ?? 'Male',
          height: (extra?['height'] ?? 170.0).toDouble(),
          weight: (extra?['weight'] ?? 70.0).toDouble(),
        );
      },
    ),
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    GoRoute(
      path: '/diet-plans',
      builder: (context, state) => const DietPlansPage(),
    ),
    GoRoute(
      path: '/diet-category/:categoryId',
      builder: (context, state) {
        final categoryId = state.pathParameters['categoryId']!;
        return DietCategoryPage(categoryId: categoryId);
      },
    ),
    GoRoute(
      path: '/meal-details/:mealId',
      builder: (context, state) {
        final mealId = state.pathParameters['mealId']!;
        return MealDetailsPage(mealId: mealId);
      },
    ),
    GoRoute(
      path: '/workouts',
      builder: (context, state) => const WorkoutsPage(),
    ),
    GoRoute(
      path: '/workout-category/:categoryId',
      builder: (context, state) {
        final categoryId = state.pathParameters['categoryId']!;
        return WorkoutCategoryPage(categoryId: categoryId);
      },
    ),
    GoRoute(
      path: '/exercise-timer/:exerciseId',
      builder: (context, state) {
        final exerciseId = state.pathParameters['exerciseId']!;
        return ExerciseTimerPage(exerciseId: exerciseId);
      },
    ),
    GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
    GoRoute(
      path: '/progress-tracker',
      builder: (context, state) => const ProgressTrackerPage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/home-workout',
      builder: (context, state) {
        final totalDays = int.tryParse(state.uri.queryParameters['totalDays'] ?? '7') ?? 7;
        final currentDay = int.tryParse(state.uri.queryParameters['currentDay'] ?? '1') ?? 1;
        return HomeWorkoutPage(totalDays: totalDays, currentDay: currentDay);
      },
    ),
    GoRoute(path: '/yoga', builder: (context, state) => const YogaPage()),
    GoRoute(
      path: '/firebase-test',
      builder: (context, state) => const FirebaseTestPage(),
    ),
    GoRoute(
      path: '/meditation',
      builder: (context, state) => const MeditationPage(),
    ),
    GoRoute(
      path: '/plan',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final planType = extra?['planType'] as String? ?? 'home_workouts';
        return PlanPage(planType: planType);
      },
    ),
    GoRoute(
      path: '/breathing-exercise',
      builder: (context, state) {
        final exercise = state.extra as Map<String, dynamic>;
        return BreathingExercisePage(exercise: exercise);
      },
    ),
    GoRoute(
      path: '/workout-timer/:workoutId',
      builder: (context, state) {
        final workoutId = state.pathParameters['workoutId']!;
        return WorkoutTimerPage(workoutId: workoutId);
      },
    ),
    GoRoute(
      path: '/yoga-workout',
      builder: (context, state) => const YogaWorkoutPage(),
    ),
  ],
);
