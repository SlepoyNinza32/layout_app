import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'contact_model.dart';

late Box<ContactModel> box;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter<ContactModel>(ContactModelAdapter());
  box = await Hive.openBox<ContactModel>('contact');
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<ContactModel> contact = [
    ContactModel(name: ' ', message: []),
    ContactModel(name: 'Anatoly', message: []),
    ContactModel(name: 'Rock', message: []),
    ContactModel(name: 'Ann', message: []),
  ];
  int sel = 0;

  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    box.addAll(contact);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, value, _) => LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: MediaQuery.of(context).size.height,
                      child: ListView.builder(
                        itemBuilder: (context, index) => index == 0
                            ? SizedBox(
                                width: 0,
                                height: 0,
                              )
                            : ListTile(
                                title: Text('${box.getAt(index)!.name}'),
                                tileColor: box.getAt(index)!.isSelected == false
                                    ? Colors.grey
                                    : Colors.blue,
                                onTap: () {
                                  setState(() {
                                    sel = index;
                                    for (var row in box.values) {
                                      row.isSelected = false;
                                    }
                                    box.getAt(index)!.isSelected = true;
                                  });
                                },
                                subtitle: Text(box.getAt(index)!.message.isEmpty
                                    ? 'nothing'
                                    : box.getAt(index)!.message.last),
                                leading: Icon(Icons.person_rounded),
                              ),
                        itemCount: box.length,
                      ),
                    ),
                    VerticalDivider(width: 3),
                    Container(
                      color: Colors.grey,
                      width: MediaQuery.of(context).size.width * 0.7 - 3,
                      height: MediaQuery.of(context).size.height,
                      child: sel == 0
                          ? Center(
                              child: Text('Select, who do you want to chat'),
                            )
                          : Scaffold(
                              appBar: AppBar(
                                title: Text(
                                  box.getAt(sel)!.name,
                                ),
                              ),
                              body: Container(
                                width:
                                    MediaQuery.of(context).size.width * 0.7 - 3,
                                height: MediaQuery.of(context).size.height,
                                child: Column(
                                  children: [
                                    Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                                  0.9 -
                                              56,
                                      child: ListView.builder(
                                        itemCount:
                                            box.getAt(sel)!.message.length,
                                        itemBuilder: (context, index) => Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Colors.lightBlue,
                                              ),
                                              padding: EdgeInsets.all(8),
                                              margin: EdgeInsets.all(8),
                                              child: Text(
                                                '${box.getAt(sel)!.message[index]}',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.1,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.6,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.1,
                                            child: TextField(
                                              controller: messageController,
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText: '  Write message...',
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.1 -
                                                6,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.1,
                                            child: IconButton(
                                              icon: Icon(Icons.send_outlined),
                                              onPressed: () {
                                                setState(() {
                                                  box.getAt(sel)!.message.add(
                                                      messageController
                                                          .value.text);
                                                  messageController.text = '';
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              );
            } else {
              return Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: ListView.builder(
                  itemBuilder: (context, index) => index == 0
                      ? SizedBox(
                          width: 0,
                          height: 0,
                        )
                      : ListTile(
                          title: Text(contact[index].name),
                          tileColor: Colors.grey,
                          onTap: () {
                            setState(() {
                              sel = index;
                              for (var row in contact) {
                                row.isSelected = false;
                              }
                              contact[sel].isSelected = true;
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => Chat(
                                      index: sel,
                                    ),
                                  ));
                            });
                          },
                          subtitle: Text(box.getAt(index)!.message.isEmpty
                              ? 'nothing'
                              : box.getAt(index)!.message.last),
                          leading: Icon(Icons.person_rounded),
                        ),
                  itemCount: contact.length,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class Chat extends StatefulWidget {
  const Chat({super.key, required this.index});

  final int index;

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          box.getAt(widget.index)!.name,
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width * 0.7 - 3,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: box.getAt(widget.index)!.message.length,
                itemBuilder: (context, index) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.lightBlue,
                      ),
                      padding: EdgeInsets.all(8),
                      margin: EdgeInsets.all(8),
                      child: Text(
                        '${box.getAt(widget.index)!.message[index]}',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.1,
              width: double.infinity,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(8),
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.1,
                      child: TextField(
                        controller: messageController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Write message...',
                        ),
                      ),
                    ),
                  ),
                  Container(width: 0,),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.1,
                    height: MediaQuery.of(context).size.height * 0.1,
                    child: IconButton(
                      iconSize: MediaQuery.of(context).size.width * 0.1,
                      icon: Icon(Icons.send_outlined),
                      onPressed: () {
                        setState(() {
                          box
                              .getAt(widget.index)!
                              .message
                              .add(messageController.value.text);
                          messageController.text = '';
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
