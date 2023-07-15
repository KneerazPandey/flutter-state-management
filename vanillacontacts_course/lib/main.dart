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
      home: const HomePage(),
      routes: {
        '/new-contacts': (context) => const NewContactView(),
      },
    );
  }
}

class Contact {
  final String id;
  final String name;

  Contact({
    required this.name,
  }) : id = const Uuid().v4();
}

class ContactBook extends ValueNotifier<List<Contact>> {
  ContactBook._sharedInstance() : super([]);
  static final ContactBook _shared = ContactBook._sharedInstance();

  factory ContactBook() => _shared;

  int get length => value.length;

  void add({required Contact contact}) {
    value.add(contact);
    notifyListeners();
  }

  void remove({required Contact contact}) {
    if (value.contains(contact)) {
      value.remove(contact);
      notifyListeners();
    }
  }

  Contact? contact({required int atIndex}) =>
      value.length > atIndex ? value[atIndex] : null;
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple State Management'),
      ),
      body: ValueListenableBuilder(
        valueListenable: ContactBook(),
        builder: (BuildContext context, List<Contact> value, Widget? child) {
          return ListView.builder(
            itemCount: value.length,
            itemBuilder: (BuildContext context, int index) {
              final Contact contact = ContactBook().contact(atIndex: index)!;
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Dismissible(
                  key: ValueKey(contact.id),
                  onDismissed: (DismissDirection direction) {
                    ContactBook().remove(contact: contact);
                  },
                  child: ListTile(
                    title: Text(
                      contact.name,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).pushNamed('/new-contacts');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NewContactView extends StatefulWidget {
  const NewContactView({super.key});

  @override
  State<NewContactView> createState() => _NewContactViewState();
}

class _NewContactViewState extends State<NewContactView> {
  late TextEditingController _nameController;

  @override
  void initState() {
    _nameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add new contact'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter a new contact name',
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  final contact = Contact(name: _nameController.text);
                  ContactBook().add(contact: contact);
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Add Contact',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
