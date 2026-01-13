import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/provider/transactionProvider.dart';
import 'package:admin_ott/data/models/response/userTransactionResponse.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../widgets/custom_textfield.dart'; // For number formatting

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  String selectedButton = '7D'; // Default selected button
  String selectedGraphType = 'Revenue'; // Default graph type

  @override
  void initState() {
    super.initState();

    _fetchGraphData();
  }


Future<void> _fetchGraphData() async {
  await Provider.of<TransactionProvider>(context, listen: false).fetchUserTransactions('');
  await Provider.of<TransactionProvider>(context, listen: false).fetchTransactionGraph(0);
}



  Future<void> updateGraph(String buttonLabel, int days) async {
    setState(() {
      selectedButton = buttonLabel;
    });
    if(selectedButton == "7D"){
    await Provider.of<TransactionProvider>(context, listen: false).fetchTransactionGraph(0);}else if(selectedButton=="1M"){
      await Provider.of<TransactionProvider>(context, listen: false).fetchTransactionGraph(1);
    }else{
      await Provider.of<TransactionProvider>(context, listen: false).fetchTransactionGraph(2);
    }
  }

  void switchGraphType(String type) {
    setState(() {
      selectedGraphType = type;
    });
  }


  int selectedTimeRange = 0; // Default to weekly view

  @override
  Widget build(BuildContext context) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: true).getTheme;
    return Scaffold(
      body:Consumer<TransactionProvider>(builder: (context, provider, child) {
        debugPrint("transactionList:::" +
            provider.filtteredUserTransactionList.length.toString());
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: ResponsiveWidget.isMobile(context)
                    ? _buildMobileLayout(selectedThemeData,provider)
                    : _buildDesktopLayout(selectedThemeData,provider)
              ),
            ],
          ),
        );}
      ),
    );
  }

  Widget _toggleButton(String label, int index, ThemeData themeData) {
    bool isSelected = selectedTimeRange == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTimeRange = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? themeData.primaryColor : themeData.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : themeData.textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(ThemeData themeData, TransactionProvider provider) {
    return Column(
      children: [
        CustomTextField(
          controller: provider.searchController,
          hintText: 'Search by user name',
          textInputType: TextInputType.text,
          prefixIcon: Icon(Icons.search_sharp),
        ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: provider.filtteredUserTransactionList.length,
            itemBuilder: (context,index){
              UserTransactionData userTransactionData = provider.filtteredUserTransactionList[index];
              return _buildTransactionCards(themeData,userTransactionData);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(ThemeData themeData, TransactionProvider provider) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: true).getTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Card(
            color: selectedThemeData.cardColor,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      title: ChartTitle(
                          text: selectedGraphType == 'Revenue'
                              ? 'Revenue Analysis (Total : $provider)'
                              : 'User Onboarding Analysis'),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <CartesianSeries>[
                        LineSeries<TransactionChartData, String>(
                          dataSource: provider.chartData,
                          xValueMapper: (TransactionChartData data, _) => data.date,
                          yValueMapper: (TransactionChartData data, _) =>
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
                      _buildOptionButton('7D', 7, selectedThemeData),
                      _buildOptionButton('1M', 30, selectedThemeData),
                      _buildOptionButton('1Y', 365, selectedThemeData),
                      _buildOptionButton(
                          'All', provider.chartData.length, selectedThemeData),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Flexible(
          flex: 3,
          child:   Column(
            children: [
              CustomTextField(
                controller: provider.searchController,
                hintText: 'Search by user name',
                textInputType: TextInputType.text,
                prefixIcon: Icon(Icons.search_sharp),
              ),
              Expanded(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: provider.filtteredUserTransactionList.length,
                    itemBuilder: (context,index){
                      UserTransactionData userTransactionData = provider.filtteredUserTransactionList[index];
                    return _buildTransactionCards(themeData,userTransactionData);
                    },
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionButton(
      String label, int days, ThemeData selectedThemeData) {
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

  Widget _buildTransactionCards(ThemeData themeData, UserTransactionData userTransactionData) {
    return Card(
        color: themeData.cardColor,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "TXN"+userTransactionData.id.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: themeData.primaryColor,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.share, color: themeData.primaryColor),
                    onPressed: () {
                      Share.share(
                        'Transaction Details\n'
                        'Transaction ID: ${userTransactionData.id}\n'
                        'Date: ${userTransactionData.movie!.releaseDate}\n'
                        'Time: ${userTransactionData.movie!.releaseDate}\n'
                        'User Name: ${userTransactionData.user!.firstName}\n'
                        'User ID: ${userTransactionData.user!.id}\n'
                        'Movie: ${userTransactionData.movie!.title}\n'
                        'Price: ${userTransactionData.movie!.price}\n'
                        'Accessible Till: ${userTransactionData.dateTo}\n',
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                userTransactionData.user!.firstName ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'User ID: ${userTransactionData.user!.id}',
                style: const TextStyle(fontSize: 14),
              ),
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Movie:', style: _boldTextStyle()),
                        const SizedBox(height: 4),
                        Text(userTransactionData.movie!.title ?? ''),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Price:', style: _boldTextStyle()),
                        const SizedBox(height: 4),
                        Text(userTransactionData.movie!.price.toString() ?? ''),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Admin Revenue:', style: _boldTextStyle()),
                        const SizedBox(height: 4),
                        Text('0'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Duration:', style: _boldTextStyle()),
                        const SizedBox(height: 4),
                        Text(userTransactionData.movie!.runtime.toString() ?? ''),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date & Time:', style: _boldTextStyle()),
                        const SizedBox(height: 4),
                        Text(
                          '${userTransactionData.movie!.releaseDate} ',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
  }

  TextStyle _boldTextStyle() {
    return const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );
  }
}

class TransactionChartData {
  final String date;
  final double revenue;
  final int usersOnboarded;

  TransactionChartData(this.date, this.revenue, this.usersOnboarded);
}
