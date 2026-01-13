/*
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/data/models/response/getRaisedTicketListResponse.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

import '../../../provider/ticketProvider.dart';

class HelpDeskPage extends StatefulWidget {
  @override
  _HelpDeskPageState createState() => _HelpDeskPageState();
}

class _HelpDeskPageState extends State<HelpDeskPage> {

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await Provider.of<TicketProvider>(context, listen: false).getRaisedTicketByUserId();
  }






  @override
  Widget build(BuildContext context) {
    var selectedThemeData = Provider.of<ThemeProvider>(context).getTheme;
    return  Consumer<TicketProvider>(
      builder: (context, provider, child) =>  Scaffold(
        backgroundColor: selectedThemeData.scaffoldBackgroundColor,
        body: Container(
          child: provider.tickets.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
            itemCount: provider.tickets.length,
            itemBuilder: (context, index) {
              TicketRaised ticketRaised = provider.tickets[index];
              return _buildQueryCard(index, selectedThemeData,ticketRaised,provider);
            },
          ),
        ),
       */
/* floatingActionButton: FloatingActionButton(
          onPressed: _addDummyQueries,
          child: const Icon(Icons.add),
          backgroundColor: selectedThemeData.primaryColor,
        ),*//*

      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 80, color: Colors.grey),
          SizedBox(height: 10),
          Text("No queries yet",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildQueryCard(int index, ThemeData selectedThemeData, TicketRaised query,TicketProvider provider) {
    return Card(
      color: selectedThemeData.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        //leading: _buildQueryImage(query['image']),
        title: Text(query.topic??"NA",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          children: [
            Text(
              "${query.mobileNumber} | ${query.email}\n${_formatDate(query.date!)}",
              maxLines: 2,
              style: TextStyle(color: Colors.grey[700]),
            ),
            SizedBox(height: 10,),
                      ],
        ),
        trailing: _buildQueryActions(index,provider),
        onTap: () => _showQueryDetails(query, index),
      ),
    );
  }

  Widget _buildQueryImage(String? imagePath) {
    if (imagePath != null && File(imagePath).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(File(imagePath),
            width: 50, height: 50, fit: BoxFit.cover),
      );
    }
    return Image.network(
      'https://i.pinimg.com/474x/b8/17/b5/b817b5f43d9743cbf0923d68b916116a.jpg',
      width: 50,
      height: 50,
      fit: BoxFit.cover,
    );
  }

  Widget _buildQueryActions(int index,TicketProvider provider) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
      */
/*  IconButton(
          icon: Icon(Icons.check_circle,
              color: _queries[index]['solved'] ? Colors.green : Colors.grey),
          onPressed: () => _toggleSolved(index),
        ),*//*

        IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: () => provider.deleteQuery(provider.tickets[index]),
        ),
      ],
    );
  }

  void _showQueryDetails(TicketRaised query, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("Query Details",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Mobile: ${query.mobileNumber}",
                  style: const TextStyle(fontSize: 16)),
              Text("Email: ${query.email}",
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              //_buildQueryImage(query['image']),
              const SizedBox(height: 10),
              const Text("Query:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(query.topic??"", textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text("Date: ${_formatDate(query.date!)}",
                  style: TextStyle(color: Colors.grey[600])),
            ],
          ),
          actions: [
           */
/* TextButton(
              child:
              Text(query['solved'] ? "Mark as Unsolved" : "Mark as Solved"),
              onPressed: () {
                _toggleSolved(index);
                Navigator.of(context).pop();
              },
            ),*//*

            TextButton(
              child: const Text("Close"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp)
        .toLocal()
        .toString()
        .split('.')[0];
  }
}*/
