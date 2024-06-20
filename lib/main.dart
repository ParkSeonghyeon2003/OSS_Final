import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '대학 과제 메모 앱',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final List<Map<String, dynamic>> _memos = [];
  final List<String> _subjects = [];
  String? _selectedSubject;
  DateTime? _selectedDeadline;

  void _addMemo() {
    setState(() {
      _memos.add({
        'text': _textController.text,
        'timestamp': DateTime.now(),
        'deadline': _selectedDeadline,
        'subject': _selectedSubject,
        'isDone': false,
      });
      _textController.clear();
      _selectedDeadline = null;
      _selectedSubject = null;
    });
  }

  void _toggleMemoCompletion(int index) {
    setState(() {
      _memos[index]['isDone'] = !_memos[index]['isDone'];
    });
  }

  void _deleteMemo(int index) {
    setState(() {
      _memos.removeAt(index);
    });
  }

  void _addSubject() {
    setState(() {
      _subjects.add(_subjectController.text);
      _subjectController.clear();
    });
  }

  void _deleteSubject(int index) {
    setState(() {
      _subjects.removeAt(index);
    });
  }

  void _showEditDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('메모 수정'),
          content: Column(
            children: [
              TextField(
                controller: TextEditingController(text: _memos[index]['text']),
                onChanged: (value) {
                  setState(() {
                    _memos[index]['text'] = value;
                  });
                },
              ),
              DropdownButton<String>(
                value: _selectedSubject,
                hint: const Text('과목을 선택하세요'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSubject = newValue;
                  });
                },
                items: _subjects.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              ElevatedButton(
                onPressed: () async {
                  _selectedDeadline = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                },
                child: const Text('마감 기한 선택'),
              ),
            ],
          ),
          actions: [
            TextButton(
              // 취소
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              // 저장
              child: const Text('저장'),
              onPressed: () {
                setState(() {
                  _memos[index] = {
                    'text': _memos[index]['text'],
                    'timestamp': _memos[index]['timestamp'],
                    'deadline': _selectedDeadline,
                    'subject': _selectedSubject,
                    'isDone': _memos[index]['isDone'],
                  };
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('대학 과제 메모 앱'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '메모'),
              Tab(text: '과목 관리'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 메모 탭
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            decoration: const InputDecoration(
                              hintText: '메모를 입력하세요',
                            ),
                            onSubmitted: (text) {
                              _addMemo();
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addMemo,
                        ),
                      ],
                    ),
                  ),
                  DropdownButton<String>(
                    value: _selectedSubject,
                    hint: const Text('과목을 선택하세요'),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedSubject = newValue;
                      });
                    },
                    items:
                        _subjects.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      _selectedDeadline = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                    },
                    child: const Text('마감 기한 선택'),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _memos.length,
                      itemBuilder: (context, index) {
                        final memo = _memos[index];
                        final timestamp = memo['timestamp'] as DateTime;
                        final deadline = memo['deadline'] as DateTime?;
                        final formattedTimestamp =
                            DateFormat('yyyy-MM-dd HH:mm:ss', 'ko')
                                .format(timestamp); // 한국어 날짜 포맷
                        final formattedDeadline = deadline != null
                            ? DateFormat('yyyy-MM-dd', 'ko')
                                .format(deadline) // 한국어 날짜 포맷
                            : '없음';

                        return ListTile(
                          title: Text(
                            memo['text'],
                          ),
                          subtitle: Text(
                            '작성 시간: $formattedTimestamp\n마감 기한: $formattedDeadline\n과목: ${memo['subject']}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check),
                                onPressed: () {
                                  _toggleMemoCompletion(index);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _showEditDialog(index);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _deleteMemo(index);
                                },
                              ),
                            ],
                          ),
                          tileColor: memo['isDone']
                              ? Colors.lightGreenAccent // 연한 초록색 배경
                              : Colors.transparent,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // 과목 관리 탭
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _subjectController,
                      decoration: const InputDecoration(
                        hintText: '새로운 과목을 입력하세요',
                      ),
                      onSubmitted: (text) {
                        _addSubject();
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addSubject,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _subjects.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_subjects[index]),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  //_showEditDialog(index);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _deleteSubject(index);
                                },
                              ),
                            ],
                          ),
                        );
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
