import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String apiBase = 'http://10.0.2.2:8000';

void main() {
  runApp(const ExamPrepApp());
}

class ExamPrepApp extends StatelessWidget {
  const ExamPrepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Exam Prep',
      theme: ThemeData(primarySwatch: Colors.deepPurple, scaffoldBackgroundColor: Colors.green),
      home: const AuthGate(),
    );
  }
}

/// Simple user model carried around the app after login/register.
class AppUser {
  final int userId;
  final String name;
  final String email;
  double ability;

  AppUser({
    required this.userId,
    required this.name,
    required this.email,
    required this.ability,
  });

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'name': name,
    'email': email,
    'ability': ability,
  };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    userId: json['user_id'] as int,
    name: json['name'] as String,
    email: json['email'] as String,
    ability: (json['ability'] as num).toDouble(),
  );
}

/// Checks SharedPreferences on launch: if a session was saved from a
/// previous run, skip straight to HomePage. Otherwise show LoginPage.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool loading = true;
  AppUser? savedUser;

  @override
  void initState() {
    super.initState();
    loadSession();
  }

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('session_user');

    if (raw != null) {
      savedUser = AppUser.fromJson(jsonDecode(raw));
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (savedUser != null) {
      return HomePage(user: savedUser!);
    }

    return const LoginPage();
  }
}

/// Saves the logged-in user to SharedPreferences so they stay logged in
/// next time the app opens.
Future<void> saveSession(AppUser user) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('session_user', jsonEncode(user.toJson()));
}

Future<void> clearSession() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('session_user');
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String errorMessage = '';

  Future<void> login() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('$apiBase/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text.trim(),
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = AppUser.fromJson(data);
        await saveSession(user);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(user: user)),
        );
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          errorMessage = data['detail'] ?? 'Login failed';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Welcome back',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : login,
              child: Text(isLoading ? 'Logging in...' : 'Login'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                );
              },
              child: const Text("Don't have an account? Sign up"),
            ),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String errorMessage = '';

  Future<void> register() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('$apiBase/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = AppUser.fromJson(data);
        await saveSession(user);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(user: user)),
        );
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          errorMessage = data['detail'] ?? 'Registration failed';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : register,
              child: Text(isLoading ? 'Creating account...' : 'Sign up'),
            ),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final AppUser user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> questions = [];
  bool isLoading = false;
  String errorMessage = '';

  Future<void> fetchQuestions() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse('$apiBase/questions'));

      if (response.statusCode == 200) {
        setState(() {
          questions = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  void startQuiz() {
    if (questions.isEmpty) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            QuizPage(questions: questions, user: widget.user),
      ),
    );
  }

  Future<void> logout() async {
    await clearSession();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Prep'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: logout,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Hi, ${widget.user.name}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 4),
              const Text(
                'Adaptive Quiz',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Prepare smarter. Learn better.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                'Current ability estimate: ${widget.user.ability.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: isLoading ? null : fetchQuestions,
                child: Text(isLoading ? 'Loading...' : 'Load Questions'),
              ),
              const SizedBox(height: 15),
              if (questions.isNotEmpty)
                ElevatedButton(
                  onPressed: startQuiz,
                  child: const Text('Start Quiz'),
                ),
              const SizedBox(height: 20),
              if (questions.isNotEmpty)
                Text(
                  '${questions.length} questions loaded',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// IRT (2-parameter logistic model) helpers
// ---------------------------------------------------------------------
//
// P(correct | theta) = 1 / (1 + exp(-1.7 * a * (theta - b)))
//   theta = examinee ability
//   a     = item discrimination
//   b     = item difficulty
//   1.7   = standard scaling constant so the logistic curve closely
//           matches the normal-ogive model classical IRT is based on
//
// Ability is estimated via EAP (Expected A Posteriori): integrate theta
// against the likelihood of the observed answers times a standard normal
// prior, over a grid of candidate theta values. This is numerically
// stable even early on (unlike raw MLE, which can diverge to +/-infinity
// if someone has answered everything right or everything wrong so far).

double irtProbability(double theta, double a, double b) {
  final z = 1.7 * a * (theta - b);
  return 1 / (1 + math.exp(-z));
}

double estimateAbilityEAP(List<Map<String, dynamic>> answeredItems) {
  if (answeredItems.isEmpty) return 0.0;

  const thetaMin = -4.0;
  const thetaMax = 4.0;
  const steps = 81;
  const dTheta = (thetaMax - thetaMin) / (steps - 1);

  double numerator = 0.0;
  double denominator = 0.0;

  for (int i = 0; i < steps; i++) {
    final theta = thetaMin + i * dTheta;

    // Standard normal prior density (unnormalized constant drops out).
    final prior = math.exp(-0.5 * theta * theta);

    double likelihood = 1.0;
    for (final item in answeredItems) {
      final a = item['a'] as double;
      final b = item['b'] as double;
      final u = item['u'] as int; // 1 = correct, 0 = incorrect
      final p = irtProbability(theta, a, b);
      likelihood *= (u == 1) ? p : (1 - p);
    }

    final weight = prior * likelihood;
    numerator += theta * weight;
    denominator += weight;
  }

  return denominator == 0 ? 0.0 : numerator / denominator;
}

class QuizPage extends StatefulWidget {
  final List<dynamic> questions;
  final AppUser user;

  const QuizPage({super.key, required this.questions, required this.user});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  // Current ability estimate (theta), starts at the user's saved ability.
  late double ability;

  // Every answered item so far, used to recompute the EAP estimate.
  final List<Map<String, dynamic>> answeredItems = [];

  late List<dynamic> remainingQuestions;
  late dynamic currentQuestion;

  int score = 0;
  int answeredCount = 0;

  String? selectedOption;

  @override
  void initState() {
    super.initState();
    ability = widget.user.ability;
    remainingQuestions = List<dynamic>.from(widget.questions);
    currentQuestion = pickNextQuestion();
  }

  // Adaptive selection: out of whatever questions haven't been asked yet,
  // pick the one whose difficulty is closest to the current ability
  // estimate. That's what makes it "harder if you're doing well, easier
  // if you're not" instead of a fixed order.
  dynamic pickNextQuestion() {
    dynamic best;
    double bestDistance = double.infinity;

    for (final q in remainingQuestions) {
      final difficulty = (q['difficulty'] as num).toDouble();
      final distance = (difficulty - ability).abs();
      if (distance < bestDistance) {
        bestDistance = distance;
        best = q;
      }
    }

    return best;
  }

  void selectAnswer(String option) {
    setState(() {
      selectedOption = option;
    });
  }

  Future<void> saveFinalAbility() async {
    try {
      await http.post(
        Uri.parse('$apiBase/update-ability'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': widget.user.userId,
          'ability': ability,
        }),
      );
    } catch (_) {
      // Non-fatal if this fails - the quiz result still shows locally.
    }
  }

  void nextQuestion() {
    if (selectedOption == null) {
      return;
    }

    final isCorrect = selectedOption == currentQuestion['correct_option'];

    answeredItems.add({
      'a': (currentQuestion['discrimination'] as num).toDouble(),
      'b': (currentQuestion['difficulty'] as num).toDouble(),
      'u': isCorrect ? 1 : 0,
    });

    ability = estimateAbilityEAP(answeredItems);

    if (isCorrect) {
      score++;
    }

    answeredCount++;
    remainingQuestions.remove(currentQuestion);

    if (remainingQuestions.isEmpty) {
      widget.user.ability = ability;
      saveFinalAbility();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(
            score: score,
            total: widget.questions.length,
            finalAbility: ability,
          ),
        ),
      );
    } else {
      setState(() {
        currentQuestion = pickNextQuestion();
        selectedOption = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = currentQuestion;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Question ${answeredCount + 1}/${widget.questions.length}',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question['topic_name'],
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              question['question_text'],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            buildOption('A', question['option_a']),
            buildOption('B', question['option_b']),
            buildOption('C', question['option_c']),
            buildOption('D', question['option_d']),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedOption == null ? null : nextQuestion,
                child: Text(
                  remainingQuestions.length == 1
                      ? 'Finish Quiz'
                      : 'Next Question',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOption(String option, String text) {
    final isSelected = selectedOption == option;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(18),
          backgroundColor: isSelected ? Colors.deepPurple : null,
          foregroundColor: isSelected ? Colors.white : null,
        ),
        onPressed: () {
          selectAnswer(option);
        },
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('$option. $text', style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}

class ResultPage extends StatelessWidget {
  final int score;
  final int total;
  final double finalAbility;

  const ResultPage({
    super.key,
    required this.score,
    required this.total,
    required this.finalAbility,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Result')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Quiz Completed!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 25),
            Text(
              '$score / $total',
              style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Text(
              'Score: ${(score / total * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              'IRT ability estimate (theta): ${finalAbility.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
