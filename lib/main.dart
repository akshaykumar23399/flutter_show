import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:note_app/SharedPreferenceUser.dart';
import 'package:note_app/Note.dart';
import 'package:intl/intl.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.lightBlue, fontFamily: 'Ubuntu'),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    var controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));

    var tween1 = Tween(begin: 1.0, end: 0.0).animate(controller);

    return Scaffold(
      appBar: AppBar(
        title: Text("Notes"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FadeTransition(
              opacity: tween1,
              child: RaisedButton(
                color: Colors.deepOrangeAccent,
                textColor: Colors.white,
                padding: EdgeInsets.all(0),
                onPressed: () {
                  Navigator.push(context, _createRoute());
                },
                child: Text(
                  'Go',
                  style: TextStyle(fontFamily: 'Ubuntu'),
                ),
              ),
            ),
            RaisedButton(
              color: Colors.blueGrey,
              textColor: Colors.white,
              padding: EdgeInsets.all(0),
              onPressed: () {
                controller.forward().then((value) {
                  controller.reverse();
                });
              },
              child: Text("Hide 'Go'"),
            ),
          ],
        ),
      ),
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => Page2(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var curve = Curves.linearToEaseOut;
          var tween = Tween(begin: Offset(0.0, 1.0), end: Offset.zero)
              .chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        });
  }
}

class Page2 extends StatefulWidget {
  @override
  _Page2State createState() => _Page2State();
}

class _Page2State extends State<Page2> with TickerProviderStateMixin {
  final SharedPref sharedPref = new SharedPref();
  final GlobalKey<FormState> key = new GlobalKey();
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        title: Text(
          "Page 2",
          style: TextStyle(fontFamily: 'Ubuntu'),
        ),
      ),
      body: FutureBuilder(
          future: sharedPref.read(),
          builder: (BuildContext context, AsyncSnapshot<List<Note>> snapshot) {
            if (snapshot.hasData) {
              print("snapshot length is : ${snapshot.data.length}");
              return ListView(
                children: snapshot.data.map((item)=>buildWidget(item)).toList()

              );
            }
            return Center(
              child: Text('No data'),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _showBottomSheet(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget buildWidget(Note e) {
    final date = new DateFormat('h:m aa | MMM dd');
    return Dismissible(
      key: Key(e.id.toString()),
      onDismissed: (value) {
        removeLastItem(e);
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 12.0, right: 10, left: 10),
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.blueAccent,
                Colors.lightBlueAccent,
              ]),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(5)),
          child: ListTile(
            title: Text(
              e.title,
              style: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w400),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(date.format(new DateTime.fromMillisecondsSinceEpoch(e.id)),
                style: TextStyle(
                    fontFamily: 'Ubuntu',
                    fontSize: 17,
                    color: Colors.white,
                    fontWeight: FontWeight.w400),
              ),
            ),
            trailing: AnimatedContainer(
                key: Key(e.id.toString()),
                duration: Duration(milliseconds: 800),
                height: 50,
                width: e.isDone ? 50 : 75,
                curve: Curves.ease,
                decoration: BoxDecoration(
                    color: e.isDone ? Colors.lightGreenAccent : Colors.white,
                    borderRadius: BorderRadius.circular(50)),
                child: IconButton(
                  icon: e.isDone
                      ? Icon(
                          Icons.done,
                          color: e.isDone ? Colors.green : Colors.grey,
                          size: 30,
                        )
                      : Text(
                          "Mark\nDone",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16, height: 1),
                        ),
                  onPressed: () async {
                    final isSuccess = await sharedPref.done(e.id);
                    if (isSuccess) {
                      setState(() {});
                    }
                  },
                )),
          ),
        ),
      ),
    );
  }

  void removeLastItem(Note e) async{
    await sharedPref.remove(e.id);
    setState(() {

    });
  }

  void _showBottomSheet(BuildContext context) {
    String title;
    final isDone = false;

    showModalBottomSheet(
        elevation: 20,
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Wrap(
                  children: <Widget>[
                    TextFormField(
                      key: key,
                      decoration: InputDecoration(
                          hintText: 'Note-1',
                          labelText: 'Note-1',
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blueGrey,
                                style: BorderStyle.solid,
                              ),
                              borderRadius: BorderRadius.circular(10))),
                      onChanged: (data) {
                        print('data: $data');
                        title = data;
                      },
                      validator: (data) {
                        if (data.isEmpty) {
                          return "Enter your note-1";
                        }
                        return null;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: Center(
                        child: RaisedButton(
                          color: Colors.red,
                          onPressed: () async{

                            if (key.currentState.validate())  {
                              final id = DateTime.now().millisecondsSinceEpoch;
                              Note note = new Note(
                                  title: title, id: id, isDone: isDone);
                              await sharedPref.saveNote(note);
                              setState(()  {
                                  Navigator.pop(context);

                                });
                            }
                          },
                          child: Text(
                            "Add Note-1",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
