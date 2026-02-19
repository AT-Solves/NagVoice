import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const NagVoiceApp());
}

class NagVoiceApp extends StatelessWidget {
  const NagVoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  final TextEditingController taskController = TextEditingController();

  String selectedPersona = "Friend";
  bool isNagging = false;
  int nagLevel = 0;
  double nagInterval = 20;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.repeat(reverse: true);
  }

  Future<void> speak(String text) async {
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  void startNagging() async {
    if (taskController.text.isEmpty) return;

    setState(() {
      isNagging = true;
      nagLevel = 0;
    });

    while (isNagging) {
      String task = taskController.text;
      String message = generateMessage(task, selectedPersona);


      await speak(message);
      nagLevel++;

      await Future.delayed(Duration(seconds: nagInterval.toInt()));
    }
  }

  void stopNagging() {
    setState(() {
      isNagging = false;
      nagLevel = 0;
    });
  }

 String generateMessage(String task, String persona) {
    switch (persona) {
      case "Friend":
        if (nagLevel == 0) {
          return "Hey, let's finish $task.";
        } else if (nagLevel == 1) {
          return "Come on, $task still needs to be done.";
        } else {
          return "Seriously, stop delaying and complete $task now.";
        }

      case "Mother":
        if (nagLevel == 0) {
          return "Please complete $task when you can.";
        } else if (nagLevel == 1) {
          return "You have been postponing $task. Please do it soon.";
        } else {
          return "I have reminded you several times. Finish $task immediately.";
        }

      case "Father":
        if (nagLevel == 0) {
          return "Complete $task.";
        } else if (nagLevel == 1) {
          return "$task should have been completed by now.";
        } else {
          return "No more excuses. Finish $task right away.";
        }

      case "Well-Wisher":
        if (nagLevel == 0) {
          return "You are capable of achieving great things. Start $task.";
        } else if (nagLevel == 1) {
          return "Your goals depend on completing $task. Please proceed.";
        } else {
          return "Discipline today leads to success tomorrow. Complete $task now.";
        }

      default:
        return "Please complete $task.";
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.lerp(
                      const Color(0xFF1E1E2F), const Color(0xFF302B63),
                      _fadeAnimation.value)!,
                  Color.lerp(
                      const Color(0xFF24243E), const Color(0xFF0F0C29),
                      _fadeAnimation.value)!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Container(
                width: 650,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text(
                        "NagVoice",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Your AI Productivity Companion",
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 40),

                      buildPersonaSection(),
                      const SizedBox(height: 40),
                      buildTaskInput(),
                      const SizedBox(height: 30),
                      buildIntervalSlider(),
                      const SizedBox(height: 40),
                      buildActionButton(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildPersonaSection() {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: [
        buildPersonaCard("Friend"),
        buildPersonaCard("Mother"),
        buildPersonaCard("Father"),
        buildPersonaCard("Well-Wisher"),
      ],
    );
  }

  Widget buildPersonaCard(String persona) {
    bool isSelected = selectedPersona == persona;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPersona = persona;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 130,
        height: 60,
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                )
              : null,
          color: isSelected ? null : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.white.withOpacity(0.2),
          ),
        ),
        child: Center(
          child: Text(
            persona,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTaskInput() {
    return TextField(
      controller: taskController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Enter your task...",
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget buildIntervalSlider() {
    return Column(
      children: [
        const Text(
          "Nagging Interval",
          style: TextStyle(color: Colors.white70),
        ),
        Slider(
          min: 5,
          max: 60,
          divisions: 11,
          value: nagInterval,
          activeColor: Colors.purpleAccent,
          onChanged: (value) {
            setState(() {
              nagInterval = value;
            });
          },
        ),
        Text(
          "${nagInterval.toInt()} seconds",
          style: const TextStyle(color: Colors.white54),
        ),
      ],
    );
  }

  Widget buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        onPressed: () {
          if (!isNagging) {
            startNagging();
          } else {
            stopNagging();
          }
        },
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              isNagging ? "STOP NAGGING" : "START NAGGING",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
