import 'package:admin_ott/app/provider/promoterProvider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/ui/pages/manage%20media%20house%20page/component/stat_tile.dart';
import 'package:admin_ott/app/ui/pages/manage%20promoter%20page/components/buildList.dart';
import 'package:admin_ott/domain/entities/promoter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PromoterDetailsPage extends StatefulWidget {
  final Promoters promoter;

  const PromoterDetailsPage({super.key, required this.promoter});

  @override
  State<PromoterDetailsPage> createState() => _PromoterDetailsPageState();
}

class _PromoterDetailsPageState extends State<PromoterDetailsPage> {
  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    final userProvider = Provider.of<PromoterProvider>(context, listen: false);
    final referralCode = widget.promoter.userId?.refferCode;
    if (referralCode == null || referralCode.isEmpty) return;
    await userProvider.getUsersByUserReferalCode(referralCode);
  }

  @override
  Widget build(BuildContext context) {
    final selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;
    final promoter = widget.promoter;
    final user = promoter.userId;
    final location = user?.location;
    final locationText = [
      location?.taluka,
      location?.district,
      location?.state,
      location?.country
    ].where((e) => e != null && e.trim().isNotEmpty).join(', ');

    return Scaffold(
      backgroundColor: selectedThemeData.scaffoldBackgroundColor,
      appBar: AppBar(
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GraphPage(promoters: promoter),
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
                  'Joining date: ${promoter.createdDate ?? "N/A"}',
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
                promoter.promoterName ?? "Unknown Promoter",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                user?.emailId ?? "N/A",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text(
                user?.mobileNumber ?? "N/A",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text(
                locationText.isEmpty ? "Location: N/A" : locationText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Consumer<PromoterProvider>(builder: (context, provider, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    StatTile(label: 'Refer', value: provider.refer ?? '0'),
                    StatTile(
                        label: 'Incentive', value: provider.incentive ?? '0'),
                    StatTile(label: 'Revenue', value: provider.revenue ?? '0'),
                  ],
                );
              }),
              const SizedBox(height: 20),
              _buildBankDetailsCard(selectedThemeData, promoter),
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

  Widget _buildBankDetailsCard(ThemeData theme, Promoters promoter) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bank & Documents',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _buildDetailItem('Bank Name', promoter.bankName),
              _buildDetailItem('Branch Name', promoter.branchName),
              _buildDetailItem('Account Number', promoter.accountNumber),
              _buildDetailItem('IFSC Code', promoter.ifscCode),
              _buildDetailItem('PAN Card', promoter.panCard),
              _buildDetailItem('Aadhaar Card', promoter.aadharCard),
              _buildDetailItem('GST Number', promoter.gst),
              _buildDetailItem('Website', promoter.website),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String? value) {
    final displayValue =
        value == null || value.trim().isEmpty ? 'N/A' : value.trim();

    return SizedBox(
      width: 240,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            displayValue,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class GraphPage extends StatefulWidget {
  final Promoters promoters;
  const GraphPage({super.key, required this.promoters});

  @override
  _GraphPageState createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  String selectedButton = '1W'; // Default selected button
  String selectedGraphType = 'Revenue'; // Default graph type
  List<ChartData> chartData = []; // Initialize with an empty list
  List<ChartData> filteredData = []; // Initialize with an empty list

  Future<void> getUserData() async {
    final userProvider = Provider.of<PromoterProvider>(context, listen: false);
    final promoterId = widget.promoters.id;
    if (promoterId == null) {
      setState(() {
        chartData = [];
        filteredData = [];
      });
      return;
    }
    await userProvider.getUsersAndRevenue(promoterId);
    if (!mounted) return;

    setState(() {
      chartData = userProvider.promoterUserRevenueGraph
          .where((entry) =>
              entry.date != null &&
              entry.revenue != null &&
              entry.usersOnboarded != null)
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
        backgroundColor: selectedThemeData.scaffoldBackgroundColor,
        actions: [
          DropdownButton<String>(
            value: selectedGraphType,
            dropdownColor: selectedThemeData.cardColor,
            icon: Icon(Icons.arrow_drop_down,
                color: selectedThemeData.canvasColor),
            underline: const SizedBox(),
            items: ['Revenue', 'Users Onboarded'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: TextStyle(color: selectedThemeData.canvasColor),
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
                    yValueMapper: (ChartData data, _) =>
                        selectedGraphType == 'Revenue'
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
