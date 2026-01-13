import 'package:flutter/material.dart';

class UserApprovalWidget extends StatelessWidget {
  final List<Map<String, dynamic>> userList = [
    {
      'id': 1,
      'name': 'John Doe',
      'email': 'johndoe@example.com',
      'invited by': 'None',
      'role': 'Content Creator',
      'joinedDate': '2025-01-10',
      'status': 'Pending Approval',
    },
    {
      'id': 2,
      'name': 'Jane Smith',
      'email': 'janesmith@example.com',
      'invited by': 'Xyz Sharma',
      'role': 'Editor',
      'joinedDate': '2025-01-09',
      'status': 'Pending Approval',
    },
    {
      'id': 3,
      'name': 'Mike Johnson',
      'email': 'mikejohnson@example.com',
      'invited by': 'Ria Doe',
      'role': 'Reviewer',
      'joinedDate': '2025-01-08',
      'status': 'Pending Approval',
    },
  ];

  void _approveUser(BuildContext context, Map<String, dynamic> user) {
    // Handle user approval logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${user['name']} has been approved!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    var selectedThemeData = Theme.of(context); // Replace with your theme logic

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: userList.map((user) {
            return Card(
              color: selectedThemeData.cardColor,
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: selectedThemeData.canvasColor.withOpacity(0.2),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Email: ${user['email']}'),
                      Text('Invited by: ${user['invited by']}'),
                      Text('Joined Date: ${user['joinedDate']}'),
                      Text('Status: ${user['status']}'),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _approveUser(context, user);
                            },
                            child: Text(
                              'Approve',
                              style: TextStyle(
                                color: selectedThemeData.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
