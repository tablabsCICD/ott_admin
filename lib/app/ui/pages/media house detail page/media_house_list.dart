import 'package:admin_ott/app/provider/mediaHouseProvider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/ui/pages/manage%20media%20house%20page/component/media_house_detail_page.dart';
import 'package:admin_ott/domain/entities/mediaHouse.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MediaHouseList extends StatelessWidget {
  final List<MediaHouse> mediaHouses;

  const MediaHouseList({required this.mediaHouses, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => MediaHouseProvider(),
      builder: (context, child) => _buildPage(context),
    );
  }

  @override
  Widget _buildPage(BuildContext context) {
    final selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;

    if (mediaHouses.isEmpty) {
      return const Center(child: Text('No Media Houses found!'));
    }

    return Consumer<MediaHouseProvider>(
        builder: (context, provider, child) {
      return ListView.builder(
        itemCount: provider.filteredMediaHouseList.length,
        itemBuilder: (context, index) {
          final mediaHouse = provider.filteredMediaHouseList[index];
          return Card(
            color: selectedThemeData.cardColor,
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(mediaHouse.mediaHouseName??''),
              subtitle: Text(mediaHouse.discription??""),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(mediaHouse.logo??''),
              ),
              onTap: () async {
                await provider.fetchMoviesByMediaHouseId(mediaHouse.id!);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MediaHouseDetailPage(mediaHouse: mediaHouse),
                  ),
                );
              },
            ),
          );
        },
      );}
    );
  }
}
