import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
//Gerekli paketleri import ediyoruz
void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _temaModu = ThemeMode.light;

  void _temaDegistir() {
    setState(() {
      _temaModu = _temaModu == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To Do App',
      //Tema Bilgisi
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: _temaModu,
      debugShowCheckedModeBanner: false,
      home: MyHomePage(
        title: 'To-Do Uygulaması',
        temaModu: _temaModu,
        temaDegistir: _temaDegistir,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.temaModu, required this.temaDegistir});
  final String title;
  final ThemeMode temaModu;
  final VoidCallback temaDegistir;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class Task {
  String title;
  bool isDone;

  Task({required this.title, this.isDone = false});
}

class _MyHomePageState extends State<MyHomePage> {
  //Görevleri tutmak için bir liste oluşturuyoruz
 final List<Task> _tasks = [];
 //Görev eklemek için bir text editing controller oluşturuyoruz
  final TextEditingController _controller = TextEditingController();

  //Uygulama açıldığında görevleri yüklemek için initState metodunu override ediyoruz
    @override
  void initState() {
    super.initState();
    _gorevleriYukle();
  }

  //Görevleri kaydetmek için bir fonksiyon oluşturuyoruz
  Future<void> _gorevleriKaydet() async {
    final prefs = await SharedPreferences.getInstance();
    final gorevListesi = _tasks.map((gorev) => '${gorev.title}|${gorev.isDone}').toList();
    await prefs.setStringList('gorevler', gorevListesi);
  }

  //Görevleri yüklemek için bir fonksiyon oluşturuyoruz
  Future<void> _gorevleriYukle() async {
    final prefs = await SharedPreferences.getInstance();
    final gorevListesi = prefs.getStringList('gorevler') ?? [];
    setState(() {
      _tasks.clear();
      _tasks.addAll(gorevListesi.map((e) {
        final parcalar = e.split('|');
        return Task(title: parcalar[0], isDone: parcalar.length > 1 ? parcalar[1] == 'true' : false);
      }));
    });
  }

  //Görev eklemek için bir fonksiyon oluşturuyoruz
  void _addTask(String title) {
    if (title.isNotEmpty) {
      setState(() {
        _tasks.add(Task(title: title));
      });
      _controller.clear();
      _gorevleriKaydet();
    }
  }
  //Görev tamamlanıp tamamlanmadığını değiştirmek için bir fonksiyon oluşturuyoruz
    void _toggleTask(int index) {
    setState(() {
      _tasks[index].isDone = !_tasks[index].isDone;
    });
    _gorevleriKaydet();
  }

  //Görev silmek için bir fonksiyon oluşturuyoruz
  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _gorevleriKaydet();
  }

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(widget.temaModu == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
            onPressed: widget.temaDegistir,
            tooltip: widget.temaModu == ThemeMode.dark ? 'Açık Tema' : 'Karanlık Tema',
          ),
        ],
      ),
      //Görevleri listelemek için bir Column oluşturuyoruz
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            //Görev eklemek için bir Row oluşturuyoruz
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Yeni görev ekle',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                //Görev eklemek için bir ElevatedButton oluşturuyoruz
                ElevatedButton.icon(
                  onPressed: () => _addTask(_controller.text),
                  icon: const Icon(Icons.add),
                  label: const Text('Ekle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          //Görevleri listelemek için bir Expanded oluşturuyoruz
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    //Görev tamamlanıp tamamlanmadığını değiştirmek için bir Checkbox oluşturuyoruz
                    leading: Checkbox(
                      value: task.isDone,
                      onChanged: (val) => _toggleTask(index),
                      activeColor: Colors.deepPurple,
                    ),
                    //Görev silmek için bir IconButton oluşturuyoruz
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteTask(index),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}