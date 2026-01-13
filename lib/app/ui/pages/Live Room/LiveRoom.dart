import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/widgets/custom_textfield.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LiveRoomPage extends StatefulWidget {
  const LiveRoomPage({super.key});

  @override
  State<LiveRoomPage> createState() => _LiveRoomPageState();
}

class _LiveRoomPageState extends State<LiveRoomPage> {
  String selectedFilter = 'All';
  bool showEventGraph = true; // Toggle between graphs

  final TextEditingController searchController = TextEditingController();
  void _showAnalyticsDialog(ThemeData selectedThemeData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    showEventGraph ? 'Event Analytics' : 'Attendance Analytics',
                    style: TextStyle(
                      color: selectedThemeData.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        showEventGraph = !showEventGraph;
                      });
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: selectedThemeData.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      showEventGraph
                          ? 'Switch to Attendance'
                          : 'Switch to Events',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                height: 450,
                width: 600,
                child: showEventGraph
                    ? SfCartesianChart(
                        title: ChartTitle(
                          text: 'Events Held Over Time',
                          textStyle: TextStyle(
                            color: selectedThemeData.canvasColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        tooltipBehavior: TooltipBehavior(enable: true),
                        primaryXAxis: CategoryAxis(
                          title: AxisTitle(text: 'Month'),
                          labelStyle: TextStyle(
                            color: selectedThemeData.hintColor,
                          ),
                        ),
                        primaryYAxis: NumericAxis(
                          title: AxisTitle(text: 'Number of Events'),
                          minimum: 0,
                        ),
                        series: <CartesianSeries>[
                          LineSeries<_EventData, String>(
                            dataSource: [
                              _EventData('Jan', 5),
                              _EventData('Feb', 8),
                              _EventData('Mar', 4),
                              _EventData('Apr', 10),
                            ],
                            xValueMapper: (_EventData data, _) => data.month,
                            yValueMapper: (_EventData data, _) => data.events,
                            color: selectedThemeData.primaryColor,
                            markerSettings: MarkerSettings(isVisible: true),
                          ),
                        ],
                      )
                    : SfCartesianChart(
                        title: ChartTitle(
                          text: 'Attendance Percentage (Monthly)',
                          textStyle: TextStyle(
                            color: selectedThemeData.canvasColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        tooltipBehavior: TooltipBehavior(enable: true),
                        primaryXAxis: CategoryAxis(
                          title: AxisTitle(text: 'Month'),
                          labelStyle: TextStyle(
                            color: selectedThemeData.hintColor,
                          ),
                        ),
                        primaryYAxis: NumericAxis(
                          title: AxisTitle(text: 'Percentage (%)'),
                          minimum: 0,
                          maximum: 100,
                          labelFormat: '{value}%',
                        ),
                        series: <CartesianSeries>[
                          LineSeries<_AttendanceData, String>(
                            dataSource: [
                              _AttendanceData('Jan', 75),
                              _AttendanceData('Feb', 60),
                              _AttendanceData('Mar', 80),
                              _AttendanceData('Apr', 50),
                            ],
                            xValueMapper: (_AttendanceData data, _) =>
                                data.month,
                            yValueMapper: (_AttendanceData data, _) =>
                                data.percentage,
                            color: selectedThemeData.primaryColor,
                            enableTooltip: true,
                            markerSettings: MarkerSettings(isVisible: true),
                          ),
                        ],
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Add logic for downloading a report or analytics data
                  },
                  child: Text(
                    'Download Report',
                    style: TextStyle(color: selectedThemeData.primaryColor),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _navigateToCreateEvent() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Live Event'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(hintText: 'Event Name'),
                ),
                TextField(
                  decoration: const InputDecoration(hintText: 'Organizer Name'),
                ),
                TextField(
                  decoration: const InputDecoration(hintText: 'Date'),
                ),
                TextField(
                  decoration: const InputDecoration(hintText: 'Time'),
                ),
                TextField(
                  decoration: const InputDecoration(hintText: 'Duration'),
                ),
                TextField(
                  decoration:
                      const InputDecoration(hintText: 'Number of Invitees'),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Save event logic
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var selectedThemedata =
        Provider.of<ThemeProvider>(context, listen: true).getTheme;

    // Demo Data for Events
    final liveEvents = [
      {
        'name': 'Music Night',
        'organizer': 'Alice',
        'status': 'Live',
        'viewers': 120,
        'invited': 200,
        'joined': 120,
        'date': '2025-01-15',
        'time': '8:00 PM',
        'duration': '2 hrs'
      },
      {
        'name': 'Music Night',
        'organizer': 'Alice',
        'status': 'Live',
        'viewers': 120,
        'invited': 200,
        'joined': 120,
        'date': '2025-01-15',
        'time': '8:00 PM',
        'duration': '2 hrs'
      },
      {
        'name': 'Movie Screening',
        'organizer': 'Bob',
        'status': 'Upcoming',
        'viewers': 0,
        'invited': 150,
        'joined': 0,
        'date': '2025-01-20',
        'time': '6:00 PM',
        'duration': '3 hrs'
      },
      {
        'name': 'Tech Webinar',
        'organizer': 'Charlie',
        'status': 'Completed',
        'viewers': 85,
        'invited': 100,
        'joined': 85,
        'date': '2025-01-10',
        'time': '4:00 PM',
        'duration': '1.5 hrs'
      },
    ];

    final filteredEvents = liveEvents.where((event) {
      if (selectedFilter != 'All' && event['status'] != selectedFilter) {
        return false;
      }
      if (searchController.text.isNotEmpty) {
        return (event['name'] as String)
                .toLowerCase()
                .contains(searchController.text.toLowerCase()) ||
            (event['organizer'] as String)
                .toLowerCase()
                .contains(searchController.text.toLowerCase());
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: selectedThemedata.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter and Search Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                DropdownButton<String>(
                  dropdownColor: selectedThemedata.cardColor,
                  value: selectedFilter,
                  onChanged: (value) {
                    setState(() {
                      selectedFilter = value!;
                    });
                  },
                  items: ['All', 'Live', 'Upcoming', 'Completed'].map((filter) {
                    return DropdownMenuItem(
                      value: filter,
                      child: Text(filter),
                    );
                  }).toList(),
                ),
                SizedBox(
                  width: ResponsiveWidget.isMobile(context)
                      ? 250 //double.infinity
                      : 500,
                  child: CustomTextField(
                    prefixIcon: Icon(
                      Icons.search,
                    ),
                    controller: searchController,
                    hintText: 'Search by name or organizer',
                    textInputType: TextInputType.text,
                    onValueChange: (value) {
                      setState(() {});
                    },
                  ),
                ),
                ResponsiveWidget.isDesktop(context)
                    ? ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedThemedata.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          _showAnalyticsDialog(
                            selectedThemedata,
                          );
                        },
                        icon: const Icon(Icons.bar_chart),
                        label: const Text('Analytics'),
                      )
                    : SizedBox(
                        width: 1,
                      ),
              ],
            ),
            const SizedBox(height: 16),

            // Section Title with Divider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [],
            ),
            const SizedBox(height: 10),
            const Divider(thickness: 1),

            // List of Events with Detailed Cards
            Expanded(
              child: ListView.builder(
                itemCount: filteredEvents.length,
                itemBuilder: (context, index) {
                  final event = filteredEvents[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: event['status'] == 'Live'
                                    ? Colors.green
                                    : event['status'] == 'Upcoming'
                                        ? Colors.orange
                                        : Colors.grey,
                                child: Icon(
                                  event['status'] == 'Live'
                                      ? Icons.play_arrow
                                      : event['status'] == 'Upcoming'
                                          ? Icons.schedule
                                          : Icons.check,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event['name'] as String,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: selectedThemedata.canvasColor,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Organizer: ${event['organizer']}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: selectedThemedata.hintColor,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Status: ${event['status']} • Viewers: ${event['viewers']}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: selectedThemedata.hintColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed: () {
                                  // Show more options
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Date: ${event['date']} • Time: ${event['time']} • Duration: ${event['duration']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: selectedThemedata.hintColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Invited: ${event['invited']} • Joined: ${event['joined']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: selectedThemedata.hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () => _navigateToCreateEvent(),
        child: Container(
          height: 40,
          width: 160,
          decoration: BoxDecoration(
            color: selectedThemedata.primaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text(
                'Upload Content',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventData {
  final String month;
  final int events;

  _EventData(this.month, this.events);
}

class _AttendanceData {
  final String month;
  final double percentage;

  _AttendanceData(this.month, this.percentage);
}
