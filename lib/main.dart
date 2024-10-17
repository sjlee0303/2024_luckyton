import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart'; // 로케일 초기화를 위한 import

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 비동기 작업이 필요한 경우 호출
  await initializeDateFormatting('ko_KR', null); // 한국어 로케일 데이터 초기화
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Calendar and Diary',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CalendarPage(),
    );
  }
}

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => _selectYearMonth(context),
          child: Text('${_focusedDay.year}년 ${_focusedDay.month}월'),
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'ko_KR',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {
              CalendarFormat.month: '월',
            },
            headerVisible: false,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });

              // 선택한 날짜로 DiaryPage로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DiaryPage(selectedDate: _selectedDay!),
                ),
              );
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
          ),
          if (_focusedDay.month != DateTime.now().month ||
              _focusedDay.year != DateTime.now().year)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _focusedDay = DateTime.now();
                });
              },
              child: Text('오늘'),
            ),
        ],
      ),
    );
  }

  Future<void> _selectYearMonth(BuildContext context) async {
    int selectedYear = _focusedDay.year;
    int selectedMonth = _focusedDay.month;

    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: 300,
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    '년도와 월을 선택하세요',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  DropdownButton<int>(
                    value: selectedYear,
                    items: List.generate(20, (index) {
                      int year = DateTime.now().year - 10 + index;
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        selectedYear = value!;
                      });
                    },
                  ),
                  DropdownButton<int>(
                    value: selectedMonth,
                    items: List.generate(12, (index) {
                      int month = index + 1;
                      return DropdownMenuItem(
                        value: month,
                        child: Text('$month월'),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        selectedMonth = value!;
                      });
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _focusedDay = DateTime(selectedYear, selectedMonth, 1);
                      });
                      Navigator.pop(context);
                    },
                    child: Text('확인'),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      setState(() {
        _focusedDay = DateTime(selectedYear, selectedMonth, 1);
      });
    });
  }
}

class DiaryPage extends StatefulWidget {
  final DateTime selectedDate;

  const DiaryPage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  _DiaryPageState createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  bool _isListening = false;
  String _text = "";
  late PageController _pageController;
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    _currentDate = widget.selectedDate;
    _pageController = PageController(initialPage: 0);
  }

  void _onRecordButtonPressed() {
    setState(() {
      _isListening = !_isListening;
      _text = _isListening ? "녹음 중..." : "녹음된 텍스트 표시";
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentDate = widget.selectedDate.add(Duration(days: index));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('일기 작성: ${DateFormat('MM월 dd일').format(_currentDate)}'),
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          final date = widget.selectedDate.add(Duration(days: index));
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Center(
                    child: Text(
                      DateFormat('MM월 dd일').format(date),
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  flex: 1,
                ),
                SizedBox(height: 10),
                Flexible(
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: Center(
                      child: Text(
                        "사진을 첨부하세요",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ),
                  flex: 4,
                ),
                SizedBox(height: 10),
                Flexible(
                  child: Container(
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                          onPressed: _onRecordButtonPressed,
                          color: Colors.red,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.3,
                            padding: EdgeInsets.all(10.0),
                            color: Colors.grey[200],
                            child: Text(
                              _text.isEmpty ? "녹음된 텍스트 표시" : _text,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        IconButton(
                          icon: Icon(Icons.send),
                          onPressed: () {
                            print("텍스트 전송: $_text");
                          },
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                  fit: FlexFit.tight,
                  flex: 5,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
