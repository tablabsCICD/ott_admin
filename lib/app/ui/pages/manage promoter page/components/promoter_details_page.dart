import 'package:admin_ott/app/provider/promoterProvider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/ui/pages/manage%20media%20house%20page/component/stat_tile.dart';
import 'package:admin_ott/app/ui/pages/manage%20promoter%20page/components/buildList.dart';
import 'package:admin_ott/data/repositories/dateWiseRevenue.dart';
import 'package:admin_ott/domain/entities/promoter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PromoterDetailsPage extends StatefulWidget {
  final Promoters promoter;

  const PromoterDetailsPage({Key? key, required this.promoter})
      : super(key: key);

  @override
  State<PromoterDetailsPage> createState() => _PromoterDetailsPageState();
}

class _PromoterDetailsPageState extends State<PromoterDetailsPage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserData();
  }

  getUserData() async {
    PromoterProvider userProvider =
    Provider.of<PromoterProvider>(context, listen: false);
    await userProvider.getUsersByUserReferalCode(widget.promoter.userId!.refferCode!);
  }

  @override
  Widget build(BuildContext context) {
    final selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;



    return Scaffold(
      backgroundColor: selectedThemeData.scaffoldBackgroundColor,
      appBar: AppBar(
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GraphPage(promoters: widget.promoter,),
                ),
              );
            },
            child: Row(
              children: [
                Text(
                  'Analysis ',
                  style: TextStyle(
                    color: selectedThemeData.primaryColor,
                  ),
                ),
                Icon(
                  Icons.analytics_outlined,
                  color: selectedThemeData.primaryColor,
                ),
              ],
            ),
          )
        ],
        backgroundColor: selectedThemeData.scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Text(
                  'Joining date: ${widget.promoter.createdDate}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
              const CircleAvatar(
                radius: 50,
              ),
              const SizedBox(height: 20),
              Text(
                widget.promoter.promoterName??"",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.promoter.userId!.emailId??"",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text(
                widget.promoter.userId!.mobileNumber??"",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${widget.promoter.userId!.location!.taluka} ${widget.promoter.userId!.location!.district} ${widget.promoter.userId!.location!.state}, ',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  Text(
                    widget.promoter.userId!.location!.country??"",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 20),
    Consumer<PromoterProvider>(
    builder: (context, provider, child) {
    return  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    StatTile(label: 'Refer', value: provider.refer??'0'),
                    StatTile(label: 'Incentive', value: provider.incentive??'0'),
                    StatTile(label: 'Revenue', value: provider.revenue??'0'),
                  ],
                );}
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Divider(
                  color: Colors.grey.withOpacity(0.4),
                  thickness: 1,
                ),
              ),
              SizedBox(
                height: 800,
                width: double.infinity,
                child: BuildList(widget.promoter),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GraphPage extends StatefulWidget {
  final Promoters promoters; // Mark as final
  const GraphPage({required this.promoters, Key? key}) : super(key: key); // Use required for null safety

  @override
  _GraphPageState createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  String selectedButton = '1W'; // Default selected button
  String selectedGraphType = 'Revenue'; // Default graph type
  List<ChartData> chartData = []; // Initialize with an empty list
  List<ChartData> filteredData = []; // Initialize with an empty list

  Future<void> getUserData() async {
    PromoterProvider userProvider =
    Provider.of<PromoterProvider>(context, listen: false);
    await userProvider.getUsersAndRevenue(widget.promoters.id!);

    setState(() {
      chartData = userProvider.promoterUserRevenueGraph
          .where((entry) =>
      entry.date != null && entry.revenue != null && entry.usersOnboarded != null)
          .map((entry) =>
          ChartData(entry.date!, entry.revenue!, entry.usersOnboarded!))
          .toList();
      filteredData = getFilteredData(7); // Default to 1W data
    });
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  List<ChartData> getFilteredData(int count) {
    return count > chartData.length
        ? chartData
        : chartData.sublist(chartData.length - count);
  }

  void updateGraph(String buttonLabel, int days) {
    setState(() {
      selectedButton = buttonLabel;
      filteredData = getFilteredData(days);
    });
  }

  void switchGraphType(String type) {
    setState(() {
      selectedGraphType = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Analysis"),
        backgroundColor: Colors.black,
        actions: [
          DropdownButton<String>(
            value: selectedGraphType,
            dropdownColor: Colors.black,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            underline: const SizedBox(),
            items: ['Revenue', 'Users Onboarded'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) switchGraphType(newValue);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                title: ChartTitle(
                    text: selectedGraphType == 'Revenue'
                        ? 'Revenue Analysis'
                        : 'User Onboarding Analysis'),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries>[
                  LineSeries<ChartData, String>(
                    dataSource: filteredData,
                    xValueMapper: (ChartData data, _) => data.date,
                    yValueMapper: (ChartData data, _) => selectedGraphType == 'Revenue'
                        ? data.revenue
                        : data.usersOnboarded,
                    color: selectedThemeData.primaryColor,
                    markerSettings: const MarkerSettings(isVisible: true),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOptionButton('1W', 7, selectedThemeData),
                _buildOptionButton('1M', 30, selectedThemeData),
                _buildOptionButton('3M', 90, selectedThemeData),
                _buildOptionButton('6M', 180, selectedThemeData),
                _buildOptionButton('1Y', 365, selectedThemeData),
                _buildOptionButton('All', chartData.length, selectedThemeData),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(String label, int days, selectedThemeData) {
    final isSelected = selectedButton == label;
    return GestureDetector(
      onTap: () => updateGraph(label, days),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE50914)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : selectedThemeData.canvasColor,
          ),
        ),
      ),
    );
  }
}


class ChartData {
  final String date;
  final double revenue;
  final int usersOnboarded;

  ChartData(this.date, this.revenue, this.usersOnboarded);
}
