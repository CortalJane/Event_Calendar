import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class Event {
  final String name;
  final String time;

  Event({required this.name, required this.time});
}

class EventCalendarScreen extends StatefulWidget {
  @override
  _EventCalendarScreenState createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen> {
  late CalendarFormat _calendarFormat;
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  Map<DateTime, List<Event>> _events = {};
  bool _showReminders = false;

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
  }

  void _addEvent(String eventName, String eventTime) {
    setState(() {
      _events[_selectedDay] = (_events[_selectedDay] ?? [])
        ..add(Event(name: eventName, time: eventTime));
    });
  }

  void _editEvent(int index, String newEventName, String newEventTime) {
    setState(() {
      _events[_selectedDay]![index] = Event(name: newEventName, time: newEventTime);
    });
  }

  void _deleteEvent(int index) {
    setState(() {
      _events[_selectedDay]!.removeAt(index);
      if (_events[_selectedDay]!.isEmpty) {
        _events.remove(_selectedDay);
      }
    });
  }

  void _showAddDialog() {
    TextEditingController eventController = TextEditingController();
    TextEditingController timeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Event"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: eventController, decoration: InputDecoration(hintText: "Enter event name")),
            TextField(controller: timeController, decoration: InputDecoration(hintText: "Enter time (e.g., 3:00 PM)")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          TextButton(
            onPressed: () {
              if (eventController.text.isNotEmpty && timeController.text.isNotEmpty) {
                _addEvent(eventController.text, timeController.text);
                Navigator.pop(context);
              }
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(int index) {
    TextEditingController eventController = TextEditingController(text: _events[_selectedDay]![index].name);
    TextEditingController timeController = TextEditingController(text: _events[_selectedDay]![index].time);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Event"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: eventController, decoration: InputDecoration(hintText: "Enter event name")),
            TextField(controller: timeController, decoration: InputDecoration(hintText: "Enter time (e.g., 3:00 PM)")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          TextButton(
            onPressed: () {
              if (eventController.text.isNotEmpty && timeController.text.isNotEmpty) {
                _editEvent(index, eventController.text, timeController.text);
                Navigator.pop(context);
              }
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showEventDetailsDialog(String eventName, String eventTime) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(eventName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Time: $eventTime"),
            SizedBox(height: 10),
            Text("Okay!👍 Thanks!😊❤️"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Close")),
        ],
      ),
    );
  }

  void _navigateToDayView(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DayViewScreen(events: _events),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, CalendarFormat format) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: TextStyle(color: Colors.black)),
      onTap: () {
        setState(() {
          _calendarFormat = format;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildRemindersSection() {
    List<Map<String, String>> upcomingEvents = _events.entries
        .where((entry) => entry.key.isAfter(DateTime.now()) || isSameDay(entry.key, DateTime.now()))
        .expand((entry) => entry.value.map((event) => {
              "date": DateFormat('MMM dd, yyyy').format(entry.key),
              "name": event.name,
              "time": event.time,
            }))
        .toList()
      ..sort((a, b) => a["date"]!.compareTo(b["date"]!));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Upcoming Reminders", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        if (upcomingEvents.isEmpty) Text("No upcoming events."),
        ...upcomingEvents.map((event) => ListTile(
              leading: Icon(Icons.event_note, color: Colors.pink),
              title: Row(
                children: [
                  Icon(Icons.event, color: Colors.blue),
                  SizedBox(width: 5),
                  Text(event["name"]!, style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              subtitle: Row(
                children: [
                  Icon(Icons.access_time, color: Colors.green),
                  SizedBox(width: 5),
                  Text("${event["date"]} - ${event["time"]}"),
                ],
              ),
              onTap: () {
                _showEventDetailsDialog(event["name"]!, event["time"]!);
              },
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Event Calendar")),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 204, 62, 109),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('View Schedule', style: TextStyle(color: Colors.black, fontSize: 24)),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/drw_bg.jpg'), // Ensure path is correct
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      _buildDrawerItem(Icons.calendar_view_day, 'Day View', CalendarFormat.week),
                      _buildDrawerItem(Icons.calendar_view_week, 'Week View', CalendarFormat.week),
                      _buildDrawerItem(Icons.calendar_today, 'Month View', CalendarFormat.month),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/img_bg.png'), // Ensure path is correct
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showReminders = !_showReminders;
                  });
                },
                child: Text(_showReminders ? "Hide Upcoming Reminders" : "Show Upcoming Reminders"),
              ),
              if (_showReminders)
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: _buildRemindersSection(),
                ),
              Expanded(
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: (day) => _events[day] ?? [],
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _navigateToDayView(context);
                  },
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                    titleTextStyle: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold),
                  ),
                  calendarStyle: CalendarStyle(
                                        todayDecoration: BoxDecoration(color: Colors.blue.withOpacity(0.3), shape: BoxShape.circle),
                    selectedDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                    weekendTextStyle: TextStyle(color: Colors.red),
                  ),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      if (events.isNotEmpty) {
                        return Positioned(
                          bottom: 5,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                          ),
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _events[_selectedDay]?.length ?? 0,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Row(
                        children: [
                          Icon(Icons.event, color: Colors.blue),
                          SizedBox(width: 5),
                          Text(_events[_selectedDay]![index].name),
                        ],
                      ),
                      subtitle: Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.green),
                          SizedBox(width: 5),
                          Text(_events[_selectedDay]![index].time),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: Icon(Icons.edit), onPressed: () => _showEditDialog(index)),
                          IconButton(icon: Icon(Icons.delete), onPressed: () => _deleteEvent(index)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _showAddDialog,
      ),
    );
  }
}

class DayViewScreen extends StatelessWidget {
  final Map<DateTime, List<Event>> events;

  DayViewScreen({required this.events});

  @override
  Widget build(BuildContext context) {
    List<Widget> eventWidgets = [];
    events.forEach((date, eventList) {
      eventWidgets.add(Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('MMM dd, yyyy').format(date), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...eventList.map((event) => ListTile(
              title: Text(event.name, style: TextStyle(fontSize: 16)),
              subtitle: Text(event.time),
            )),
          ],
        ),
      ));
    });

    return Scaffold(
      appBar: AppBar(title: Text("Day View")),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/img_bg.png'), // Ensure path is correct
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: eventWidgets,
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: EventCalendarScreen()));
}
