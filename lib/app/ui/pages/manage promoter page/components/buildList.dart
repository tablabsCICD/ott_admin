import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:admin_ott/domain/entities/promoter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../provider/promoterProvider.dart';

class BuildList extends StatefulWidget {
  Promoters promoter;
  BuildList( this.promoter, {super.key});

  @override
  State<BuildList> createState() => _BuildListState();
}

class _BuildListState extends State<BuildList> {
  bool isUser = true;
  bool isPromoter = false;
  bool isPurchases = false;

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
    await userProvider.getPromotersByUserReferalCode(widget.promoter.userId!.refferCode!);
  }



  final Map<String, List<String>> purchasedContent = {
    'Promoter1': ['Content1 by User1', 'Content2 by User2'],
    'Promoter2': ['Content3 by User3', 'Content4 by User4'],
    'Promoter3': ['Content5 by User5', 'Content6 by User1'],
  };

  List<Widget> buildList(BuildContext context,PromoterProvider provider) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;
    if (isUser) {
      return
          provider.usersByPromoterCode.map(
            (user) => Card(
              color: selectedThemeData.cardColor,
              child: ListTile(
                title: Text(
                  '${user.firstName} ${user.lastName}',
                ),
              ),
            ),
          )
          .toList();
    } else if (isPromoter) {
      return provider.promotersByPromoterCode
          .map(
            (promoter) => Card(
              color: selectedThemeData.cardColor,
              child: ListTile(
                title: Text(
                  promoter.promoterName!,
                ),
              ),
            ),
          )
          .toList();
    } else if (isPurchases) {
      return purchasedContent.entries.map((
        entry,
      ) {
        return Card(
          color: selectedThemeData.cardColor,
          child: ExpansionTile(
            title: Text(
              entry.key,
            ),
            children: entry.value
                .map(
                  (content) => ListTile(
                    title: Text(
                      content,
                    ),
                  ),
                )
                .toList(),
          ),
        );
      }).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final selectedThemeData = Provider.of<ThemeProvider>(context).getTheme;

    return Container(
      width: ResponsiveWidget.isMobile(context) ? double.infinity : 600,
      decoration: BoxDecoration(
        color: selectedThemeData.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child:Consumer<PromoterProvider>(
    builder: (context, provider, child) {
    return  Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isUser = true;
                        isPromoter = false;
                        isPurchases = false;
                      });
                    },
                    child: Text(
                      'Users',
                      style: TextStyle(
                        color: isUser
                            ? selectedThemeData.primaryColor
                            : selectedThemeData.canvasColor,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isUser = false;
                        isPromoter = true;
                        isPurchases = false;
                      });
                    },
                    child: Text(
                      'Promoters',
                      style: TextStyle(
                        color: isPromoter
                            ? selectedThemeData.primaryColor
                            : selectedThemeData.canvasColor,
                      ),
                    ),
                  ),
               /*   GestureDetector(
                    onTap: () {
                      setState(() {
                        isUser = false;
                        isPromoter = false;
                        isPurchases = true;
                      });
                    },
                    child: Text(
                      'Purchases',
                      style: TextStyle(
                        color: isPurchases
                            ? selectedThemeData.primaryColor
                            : selectedThemeData.canvasColor,
                      ),
                    ),
                  ),*/
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: ListView(
                  children: buildList(context,provider),
                ),
              ),
            ],
          );}
        ),
      ),
    );
  }
}
