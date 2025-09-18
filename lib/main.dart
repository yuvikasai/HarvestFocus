import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HarvestFocus',
      debugShowCheckedModeBanner: false,
      home: BorderBackgroundWithPages(),
    );
  }
}

class BorderBackgroundWithPages extends StatefulWidget {
  @override
  _BorderBackgroundWithPagesState createState() =>
      _BorderBackgroundWithPagesState();
}

class _BorderBackgroundWithPagesState extends State<BorderBackgroundWithPages> {
  int currentPage = 0;

  // Calendar state
  DateTime selectedDay = DateTime.now();
  Map<DateTime, List<String>> events = {};
  TextEditingController eventController = TextEditingController();

  // To-do state
  List<String> tasks = [];
  List<bool> completed = [];
  TextEditingController taskController = TextEditingController();

  void goToNextPage() {
    setState(() {
      if (currentPage < 2) currentPage++;
    });
  }

  void goToPreviousPage() {
    setState(() {
      if (currentPage > 0) currentPage--;
    });
  }

  Widget buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.deepOrange,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (currentPage > 0)
            IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: goToPreviousPage,
            )
          else
            SizedBox(width: 48),
          Text(
            'HarvestFocus',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          if (currentPage < 2)
            IconButton(
              icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
              onPressed: goToNextPage,
            )
          else
            SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget buildPageContent() {
    if (currentPage == 0) return PomodoroPage();
    if (currentPage == 1) return buildCalendarPage();
    return buildTodoPage();
  }

  Widget buildCalendarPage() {
    return Center(
      child: Container(
        width: 400,
        height: 450,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: selectedDay,
              selectedDayPredicate: (d) => isSameDay(d, selectedDay),
              onDaySelected: (sel, focus) {
                setState(() => selectedDay = sel);
              },
              eventLoader: (d) => events[d] ?? [],
              calendarStyle: CalendarStyle(
                todayDecoration:
                    BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                selectedDecoration: BoxDecoration(
                    color: Colors.deepOrange, shape: BoxShape.circle),
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: eventController,
              decoration: InputDecoration(
                hintText: 'Add event',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    if (eventController.text.isEmpty) return;
                    setState(() {
                      events.putIfAbsent(selectedDay, () => []);
                      events[selectedDay]!.add(eventController.text);
                      eventController.clear();
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: (events[selectedDay] ?? [])
                    .map((e) => ListTile(
                          leading:
                              Icon(Icons.event, color: Colors.orangeAccent),
                          title: Text(e),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTodoPage() {
    return Center(
      child: Container(
        width: 350,
        height: 400,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'To-Do List',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: taskController,
                    decoration: InputDecoration(hintText: 'Enter task'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle, color: Colors.orangeAccent),
                  onPressed: () {
                    final text = taskController.text.trim();
                    if (text.isNotEmpty) {
                      setState(() {
                        tasks.add(text);
                        completed.add(false);
                        taskController.clear();
                      });
                    }
                  },
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (ctx, i) => GestureDetector(
                  onLongPress: () {
                    setState(() {
                      tasks.removeAt(i);
                      completed.removeAt(i);
                    });
                  },
                  child: ListTile(
                    title: Text(
                      tasks[i],
                      style: TextStyle(
                        decoration: completed[i]
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: completed[i] ? Colors.grey : Colors.orange[800],
                      ),
                    ),
                    trailing: Icon(
                      completed[i]
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: completed[i] ? Colors.green : Colors.orangeAccent,
                    ),
                    onTap: () {
                      setState(() => completed[i] = !completed[i]);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background color
          Container(color: Colors.orange.shade100),

          // Border image overlay
          Positioned.fill(
            child: Image.asset('assets/border.png', fit: BoxFit.cover),
          ),

          // Falling leaves animation
          FallingLeaves(leafCount: 30),

          // App content
          Column(
            children: [
              buildHeader(),
              Expanded(child: buildPageContent()),
            ],
          ),
        ],
      ),
    );
  }
}

// Pomodoro Timer Page
class PomodoroPage extends StatefulWidget {
  @override
  _PomodoroPageState createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage> {
  static const int pomodoroDuration = 25 * 60;
  int timeLeft = pomodoroDuration;
  bool isRunning = false;
  Timer? timer;

  String get timeString {
    final m = timeLeft ~/ 60;
    final s = timeLeft % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (timeLeft > 0) {
        setState(() => timeLeft--);
      } else {
        stopTimer();
      }
    });
    setState(() => isRunning = true);
  }

  void stopTimer() {
    timer?.cancel();
    setState(() => isRunning = false);
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      timeLeft = pomodoroDuration;
      isRunning = false;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 350,
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timer, size: 60, color: Colors.orangeAccent),
            SizedBox(height: 16),
            Text(
              "Pomodoro Timer",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange),
            ),
            SizedBox(height: 20),
            Text(timeString, style: TextStyle(fontSize: 48)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: isRunning ? stopTimer : startTimer,
                  child: Text(isRunning ? "Pause" : "Start"),
                ),
                SizedBox(width: 10),
                ElevatedButton(onPressed: resetTimer, child: Text("Reset")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Falling Leaves Animation
class FallingLeaves extends StatefulWidget {
  final int leafCount;
  const FallingLeaves({Key? key, this.leafCount = 20}) : super(key: key);

  @override
  _FallingLeavesState createState() => _FallingLeavesState();
}

class _FallingLeavesState extends State<FallingLeaves> {
  late Ticker _ticker;
  late List<Leaf> _leaves;
  final Random _rnd = Random();
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initLeaves();
    _ticker = Ticker(_onTick)..start();
  }

  void _initLeaves() {
    _leaves = List.generate(widget.leafCount, (_) {
      return Leaf(
        x: _rnd.nextDouble(),
        y: -_rnd.nextDouble(),
        size: _rnd.nextDouble() * 40 + 20,
        speed: _rnd.nextDouble() * 100 + 50,
        rotation: _rnd.nextDouble() * 2 * pi,
        rotationSpeed: (_rnd.nextDouble() * 2 - 1) * 0.5,
      );
    });
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastElapsed).inMilliseconds / 1000;
    _lastElapsed = elapsed;
    setState(() {
      for (var leaf in _leaves) {
        leaf.y += (leaf.speed * dt) / MediaQuery.of(context).size.height;
        leaf.rotation += leaf.rotationSpeed * dt;
        if (leaf.y > 1.1) {
          leaf.y = -0.1;
          leaf.x = _rnd.nextDouble();
        }
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return IgnorePointer(
      child: Stack(
        children: _leaves.map((leaf) {
          return Positioned(
            left: leaf.x * w,
            top: leaf.y * h,
            child: Transform.rotate(
              angle: leaf.rotation,
              child: Image.asset(
                'assets/leaf.png',
                width: leaf.size,
                height: leaf.size,
                color: Colors.orangeAccent.withOpacity(0.8),
                colorBlendMode: BlendMode.modulate,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class Leaf {
  double x, y, size, speed, rotation, rotationSpeed;
  Leaf({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.rotation,
    required this.rotationSpeed,
  });
}
