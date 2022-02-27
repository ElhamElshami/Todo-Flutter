
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archive_task/archive_task_screen.dart';
import 'package:todo_app/modules/done_task/done_task_screen.dart';
import 'package:todo_app/modules/new_task/new_task_screen.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({Key? key}) : super(key: key);

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  int currentIndex = 0;
  List<Widget> pages = [
    const NewTaskScreen(),
    const DoneTaskScreen(),
    const ArchiveTaskScreen()
  ];
  List<String> titles = ['New Task', 'Done Task', 'Archive Task'];
  late Database database;
  var ScaffoldKey = GlobalKey<ScaffoldState>();
  bool isButtonSheetShow = false;
  IconData iconData = Icons.edit;
  var titleController = TextEditingController();
  //------------
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    createDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: ScaffoldKey,
        appBar: AppBar(
          title: Text(titles[currentIndex]),
        ),
        body: pages[currentIndex],
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (isButtonSheetShow) {
                Navigator.pop(context);
                isButtonSheetShow = false;
                setState(() {
                  iconData = Icons.edit;
                });
              } else {
                ScaffoldKey.currentState!.showBottomSheet((context) =>
                      Column(
                        children: [
                          TextFormField(
                            controller: titleController,
                            decoration: const InputDecoration(
                              labelText: 'Title',
                              hintText: 'Enter title',
                            ),
                            validator: (String? value){
                              if(value!.isEmpty){
                                return 'Please enter title';
                              }
                              return null;
                            },
                            onSaved: (String? value){
                              titleController.text = value!;
                            },
                          ),
                        ],
                      ),
                        );
                isButtonSheetShow = true;
                setState(() {
                  iconData = Icons.close;
                });
              }
            },
            child: Icon(
              iconData,
            )),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          elevation: 50.0,
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Tasks'),
            BottomNavigationBarItem(
                icon: Icon(Icons.check_circle_outline), label: 'Done'),
            BottomNavigationBarItem(
                icon: Icon(Icons.archive_outlined), label: 'Archived')
          ],
        ));
  }

  void createDatabase() async {
    database = await openDatabase('todo.db', version: 1,
        onCreate: (database, version) async {
      print('database created');
      try {
        await database.execute(
          'CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT,title TEXT,description TEXT,date TEXT,time TEXT,isDone INTEGER)',
        );
      } catch (e) {
        print(e);
      }
    }, onOpen: (database) {
      print('database open ');
    });
  }

  void insertIntoDatabase() {
    database.transaction((txn) async {
      await txn
          .rawInsert(
              'INSERT INTO tasks(title,description,date,time,isDone) VALUES("title","description","date","time",0)')
          .then((value) => print('$value added succesfully'))
          .catchError((e) => print(e));
    });

    return;
  }

}




