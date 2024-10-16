import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '그림일기',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CalendarPage(), // 기본 페이지로 CalendarPage 설정
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
        title: Text('Monthly Calendar'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month, // 월별 형식 고정
            availableCalendarFormats: const {     // 월별 형식으로만 표시되도록 고정
              CalendarFormat.month: 'Month',
            },
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });

              // 날짜가 선택되었을 때 DiaryPage로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DiaryPage(selectedDate: _selectedDay!),
                ),
              );
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay; // 이전/다음 달로 변경 시 포커스 업데이트
              });
            },
          ),
        ],
      ),
    );
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

  // 녹음 버튼 클릭 시 동작할 함수
  void _onRecordButtonPressed() {
    setState(() {
      _isListening = !_isListening;
      _text = _isListening ? "녹음 중..." : "녹음된 텍스트 표시";
    });
  }

  // 페이지가 변경될 때 호출되는 함수
  void _onPageChanged(int index) {
    setState(() {
      _currentDate = widget.selectedDate.add(Duration(days: index));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('일기 작성: ${DateFormat('MM월 dd일').format(widget.selectedDate)}'),
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
                // 선택한 날짜 표시
                Flexible(
                  child: Center(
                    child: Text(
                      DateFormat('MM월 dd일').format(date),
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  flex: 1,
                ),
                SizedBox(height: 10),

                // 사진 첨부 공간 (임시)
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

                // 음성 녹음 및 텍스트 표시
                Flexible(
                  child: Container(
                    child: Row(
                      children: [
                        // 녹음 버튼
                        IconButton(
                          icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                          onPressed: _onRecordButtonPressed,
                          color: Colors.red,
                        ),
                        SizedBox(width: 10),

                        // 녹음된 텍스트 표시
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

                        // 텍스트 전송 버튼
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
