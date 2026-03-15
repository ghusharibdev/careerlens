import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/view/login_page.dart';
import 'features/auth/view/signup_page.dart';
import 'features/jobs/view/jobs_page.dart';
import 'features/jobs/view/add_job_page.dart';
import 'features/match/view/job_detail_page.dart';
import 'features/resume/view/resume_page.dart';
import 'features/chat/view/chat_page.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final loggedIn = FirebaseAuth.instance.currentUser != null;
    final onAuth = state.matchedLocation == '/login' || state.matchedLocation == '/signup';
    if (!loggedIn && !onAuth) return '/login';
    if (loggedIn && onAuth) return '/home';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/signup', builder: (_, __) => const SignupPage()),
    GoRoute(path: '/home', builder: (_, __) => const JobsPage()),
    GoRoute(path: '/add-job', builder: (_, __) => const AddJobPage()),
    GoRoute(
      path: '/job/:id',
      builder: (_, state) => JobDetailPage(jobId: state.pathParameters['id']!),
    ),
    GoRoute(path: '/resume', builder: (_, __) => const ResumePage()),
    GoRoute(path: '/chat', builder: (_, __) => const ChatPage()),
  ],
);
