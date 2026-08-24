abstract final class AppRoutes {
  // Path Constants
  static const String splash = '/splash';
  static const String login = '/login';
  static const String loginForm = '/login-form';
  static const String forgetPassword = '/forget-password';
  static const String enterPhone = '/enter-phone';
  static const String register = '/register';
  static const String verifyOtp = '/verify-otp';
  static const String home = '/';
  static const String chat = '/chat/:id';
  static const String settings = '/settings';

  // Named Routes
  static const String splashName = 'splash';
  static const String loginName = 'login';
  static const String loginFormName = 'loginForm';
  static const String forgetPasswordName = 'forgetPassword';
  static const String enterPhoneName = 'enterPhone';
  static const String registerName = 'register';
  static const String verifyOtpName = 'verifyOtp';
  static const String homeName = 'home';
  static const String chatName = 'chat';
  static const String settingsName = 'settings';

  // Dynamic Route Builders
  static String chatPath(String id) => '/chat/$id';
}
