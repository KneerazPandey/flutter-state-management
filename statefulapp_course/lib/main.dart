import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: ApiProvider(
        api: Api(),
        child: const HomePage(),
      ),
    );
  }
}

class Api {
  String? dateAndTime;

  Future<String> getDateAndTime() async {
    String newDateAndTime =
        await Future.delayed(const Duration(seconds: 1), () {
      return DateTime.now().toIso8601String();
    });
    dateAndTime = newDateAndTime;
    return dateAndTime!;
  }
}

class ApiProvider extends InheritedWidget {
  final Api api;
  final String uuid;

  ApiProvider({
    Key? key,
    required this.api,
    required Widget child,
  })  : uuid = const Uuid().v4(),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(ApiProvider oldWidget) {
    return uuid != oldWidget.uuid;
  }

  static ApiProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType()!;
  }
}

class DateAndTimeWidget extends StatelessWidget {
  const DateAndTimeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Api api = ApiProvider.of(context).api;
    return Text(
      api.dateAndTime ?? 'Please tap to change date and time',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 29,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ValueKey _valueKey = const ValueKey('');

  @override
  Widget build(BuildContext context) {
    Api api = ApiProvider.of(context).api;
    return Scaffold(
      appBar: AppBar(
        title: Text(api.dateAndTime ?? 'No thing to show'),
      ),
      body: GestureDetector(
        onTap: () async {
          var data = await api.getDateAndTime();
          setState(() {
            _valueKey = ValueKey(data);
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          color: Colors.red,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: DateAndTimeWidget(
            key: _valueKey,
          ),
        ),
      ),
    );
  }
}
