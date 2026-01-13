import 'package:admin_ott/app/provider/mediaHouseProvider.dart';
import 'package:admin_ott/domain/entities/mediaHouse.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../provider/themeProvider.dart';
import 'media_house_detail_page.dart';


class ProfilePageCard extends StatelessWidget {
  MediaHouse mediaHouse;
  MediaHouseProvider provider;
  ProfilePageCard(this.mediaHouse,  this.provider, {super.key});

  @override
  Widget build(BuildContext context) {
    final selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;
    return InkWell(
      onTap: () async {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MediaHouseDetailPage(mediaHouse: mediaHouse),
          ),
        );
      },
      child: Card(
        color: selectedThemeData.cardColor,
        child: Container(
          width : 250,
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: 130,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(12.0),topRight:Radius.circular(12.0) ),
                    color: selectedThemeData.focusColor,
                    /*image: const DecorationImage(
                      image: NetworkImage("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTONvusf0zDT91WJPM7D6rR8ZV0S5gVwCb0XQ&s"), // Add your background image here
                      fit: BoxFit.cover, // Adjust how the image fits the container
                    ),*/
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 10,),
                      Text(
                        mediaHouse.mediaHouseName??'',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        mediaHouse.contactNumber??'',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(mediaHouse.logo??''),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ProfileStat(title: mediaHouse.postCount??'', subtitle: 'Total Movie'),
                    ProfileStat(title: mediaHouse.totalViews??'', subtitle: 'Views'),
                    ProfileStat(title: mediaHouse.totalReveneu??'', subtitle: 'Revenue'),
                  ],
                ),
              ),
            ],
          ),

            ),
      ),
    );
  }
}

class ProfileStat extends StatelessWidget {
  final String title;
  final String subtitle;

  const ProfileStat({
    required this.title,
    required this.subtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
