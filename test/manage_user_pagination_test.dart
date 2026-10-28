import 'package:admin_ott/app/core/constant/api_constant.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/provider/userProvider.dart';
import 'package:admin_ott/app/ui/pages/manage%20user%20page/ManageUserPage.dart';
import 'package:admin_ott/data/models/response/getAllUserResponse.dart';
import 'package:admin_ott/domain/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class MockUserProvider extends UserProvider {
  int mockCurrentPage = 0;
  int mockPageSize = 20;
  int mockTotalUsers = 562;
  int mockTotalPages = 29;
  bool mockHasNext = true;
  bool mockHasPrevious = false;
  bool mockIsLoadingUsers = false;
  List<User> mockUsers = [];
  List<User> mockFilteredUsers = [];

  int fetchUsersCallCount = 0;
  int? lastRequestedPage;
  int? lastRequestedSize;
  int nextPageCallCount = 0;
  int previousPageCallCount = 0;

  @override
  int get currentPage => mockCurrentPage;

  @override
  int get pageSize => mockPageSize;

  @override
  int get totalUsers => mockTotalUsers;

  @override
  int get totalPages => mockTotalPages;

  @override
  bool get hasNext => mockHasNext;

  @override
  bool get hasPrevious => mockHasPrevious;

  @override
  bool get isLoadingUsers => mockIsLoadingUsers;

  @override
  List<User> get users => mockUsers;

  @override
  List<User> get filteredUsers => mockFilteredUsers;

  @override
  Future<void> fetchUsers({int? page, int? size}) async {
    fetchUsersCallCount++;
    lastRequestedPage = page;
    lastRequestedSize = size;
  }

  @override
  Future<void> nextPage() async {
    nextPageCallCount++;
    if (!mockHasNext || mockIsLoadingUsers) return;
    mockCurrentPage++;
    mockHasPrevious = mockCurrentPage > 0;
    mockHasNext = mockCurrentPage < mockTotalPages - 1;
    notifyListeners();
  }

  @override
  Future<void> previousPage() async {
    previousPageCallCount++;
    if (!mockHasPrevious || mockIsLoadingUsers || mockCurrentPage <= 0) return;
    mockCurrentPage--;
    mockHasPrevious = mockCurrentPage > 0;
    mockHasNext = mockCurrentPage < mockTotalPages - 1;
    notifyListeners();
  }

  void setMockData({
    required int currentPage,
    required int pageSize,
    required int totalUsers,
    required int totalPages,
    required bool hasNext,
    required bool hasPrevious,
    required List<User> users,
    bool isLoading = false,
  }) {
    mockCurrentPage = currentPage;
    mockPageSize = pageSize;
    mockTotalUsers = totalUsers;
    mockTotalPages = totalPages;
    mockHasNext = hasNext;
    mockHasPrevious = hasPrevious;
    mockUsers = users;
    mockFilteredUsers = List<User>.from(users);
    mockIsLoadingUsers = isLoading;
    notifyListeners();
  }
}

List<User> generateMockUsers(int count, {int startId = 1}) {
  return List.generate(count, (index) {
    final id = startId + index;
    return User(
      id: id,
      firstName: 'User$id',
      lastName: 'LastName$id',
      emailId: 'user$id@filmytell.com',
      mobileNumber: '9876543${id.toString().padLeft(3, '0')}',
      active: true,
      role: ['USER'],
    );
  });
}

Widget createTestApp(UserProvider provider) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<UserProvider>.value(value: provider),
      ChangeNotifierProvider<ThemeProvider>(
        create: (_) => ThemeProvider(),
      ),
    ],
    child: MaterialApp(
      home: ManageUserPage(),
    ),
  );
}

void main() {
  group('Manage User Pagination - Model & API Integration Tests', () {
    test('1. UserPagination parses flat API response correctly', () {
      final json = {
        "page": 0,
        "size": 20,
        "totalItems": 562,
        "totalPages": 29,
        "hasNext": true,
        "hasPrevious": false,
        "users": [
          {"id": 1, "firstName": "Alice", "emailId": "alice@test.com"}
        ]
      };

      final pagination = UserPagination.fromJson(json);
      expect(pagination.page, 0);
      expect(pagination.size, 20);
      expect(pagination.totalItems, 562);
      expect(pagination.totalPages, 29);
      expect(pagination.hasNext, true);
      expect(pagination.hasPrevious, false);
    });

    test('2. UserPagination parses nested data.pagination structure', () {
      final json = {
        "success": true,
        "data": {
          "pagination": {
            "page": 2,
            "size": 20,
            "totalItems": 562,
            "totalPages": 29,
            "hasNext": true,
            "hasPrevious": true,
          },
          "users": [
            {"id": 41, "firstName": "Bob"}
          ]
        }
      };

      final pagination = UserPagination.fromJson(json);
      expect(pagination.page, 2);
      expect(pagination.size, 20);
      expect(pagination.totalItems, 562);
      expect(pagination.totalPages, 29);
      expect(pagination.hasNext, true);
      expect(pagination.hasPrevious, true);
    });

    test('3. UserPagination computes totalPages and boundary booleans when omitted', () {
      final json = {
        "page": 0,
        "size": 20,
        "totalItems": 45,
      };

      final pagination = UserPagination.fromJson(json);
      expect(pagination.totalPages, 3); // ceil(45 / 20) = 3
      expect(pagination.hasNext, true); // page 0 < 2
      expect(pagination.hasPrevious, false); // page == 0
    });

    test('4. GetAllUserResponse parses users and pagination metadata seamlessly', () {
      final json = {
        "message": "Users fetched successfully",
        "statusCode": 200,
        "success": true,
        "data": {
          "users": [
            {"id": 1, "firstName": "John", "lastName": "Doe"},
            {"id": 2, "firstName": "Jane", "lastName": "Smith"}
          ],
          "page": 0,
          "size": 20,
          "totalItems": 562,
          "totalPages": 29,
          "hasNext": true,
          "hasPrevious": false,
        }
      };

      final response = GetAllUserResponse.fromJson(json);
      expect(response.success, true);
      expect(response.statusCode, 200);
      expect(response.data?.users?.length, 2);
      expect(response.data?.user?.length, 2); // Backward compatibility getter
      expect(response.pagination?.totalItems, 562);
      expect(response.pagination?.totalPages, 29);
      expect(response.pagination?.hasNext, true);
      expect(response.pagination?.hasPrevious, false);
    });

    test('5. GetAllUserResponse supports top-level users array and pagination', () {
      final json = {
        "page": 28,
        "size": 20,
        "totalItems": 562,
        "totalPages": 29,
        "hasNext": false,
        "hasPrevious": true,
        "users": [
          {"id": 561, "firstName": "LastUser1"},
          {"id": 562, "firstName": "LastUser2"}
        ]
      };

      final response = GetAllUserResponse.fromJson(json);
      expect(response.data?.users?.length, 2);
      expect(response.pagination?.page, 28);
      expect(response.pagination?.hasNext, false);
      expect(response.pagination?.hasPrevious, true);
    });

    test('6. ApiConstant produces proper query parameters with zero-based pagination', () {
      final defaultPagedUrl = ApiConstant.getAllUsersPaged();
      expect(defaultPagedUrl, contains('user/getAllActiveUsers?page=0&size=20'));

      final customPagedUrl = ApiConstant.getAllUsersPaged(page: 5, size: 50);
      expect(customPagedUrl, contains('user/getAllActiveUsers?page=5&size=50'));

      // Check backward compatibility
      expect(ApiConstant.getAllUser, contains('user/getAllActiveUsers'));
    });
  });

  group('Manage User Pagination - UserProvider State Management Tests', () {
    test('1. Initial pagination state defaults to zero-based first page', () {
      final provider = UserProvider();
      expect(provider.currentPage, 0);
      expect(provider.pageSize, 20);
      expect(provider.totalUsers, 0);
      expect(provider.totalPages, 1);
      expect(provider.hasNext, false);
      expect(provider.hasPrevious, false);
      expect(provider.isLoadingUsers, false);
    });

    test('2. Searching resets current page to 0', () {
      final provider = UserProvider();
      provider.searchUsers('Filmytell');
      expect(provider.currentPage, 0);
    });

    test('3. clearUserSearch resets current page to 0 and clears query', () {
      final provider = UserProvider();
      provider.searchController.text = 'SomeQuery';
      provider.clearUserSearch();
      expect(provider.searchController.text, isEmpty);
      expect(provider.currentPage, 0);
    });
  });

  group('Manage User Pagination - UI Widget Interaction Tests', () {
    testWidgets('Scenario 1, 2, 10: Renders Manage User page with 20 user cards and correct pagination summary',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockProvider = MockUserProvider();
      final users = generateMockUsers(20);
      mockProvider.setMockData(
        currentPage: 0,
        pageSize: 20,
        totalUsers: 562,
        totalPages: 29,
        hasNext: true,
        hasPrevious: false,
        users: users,
      );

      await tester.pumpWidget(createTestApp(mockProvider));
      await tester.pump();

      // Verify pagination text matches API metadata (562 total, 29 total pages, showing 1-20)
      expect(find.text('Showing 1-20 of 562 users'), findsOneWidget);
      expect(find.text('Page 1 of 29'), findsOneWidget);

      // Verify user cards rendered
      expect(find.text('User1 LastName1'), findsOneWidget);
      expect(find.text('User20 LastName20'), findsOneWidget);
    });

    testWidgets('Scenario 3, 4: Previous button disabled on page 1, Next button enabled and advances page',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockProvider = MockUserProvider();
      final users = generateMockUsers(20);
      mockProvider.setMockData(
        currentPage: 0,
        pageSize: 20,
        totalUsers: 562,
        totalPages: 29,
        hasNext: true,
        hasPrevious: false,
        users: users,
      );

      await tester.pumpWidget(createTestApp(mockProvider));
      await tester.pump();

      // Find Previous and Next buttons
      final prevButtonFinder = find.widgetWithText(OutlinedButton, 'Previous');
      final nextButtonFinder = find.widgetWithText(OutlinedButton, 'Next');
      expect(prevButtonFinder, findsOneWidget);
      expect(nextButtonFinder, findsOneWidget);

      final OutlinedButton prevButton = tester.widget(prevButtonFinder);
      final OutlinedButton nextButton = tester.widget(nextButtonFinder);

      // Previous button must be disabled on page 0
      expect(prevButton.onPressed, isNull);
      // Next button must be enabled
      expect(nextButton.onPressed, isNotNull);

      // Tap Next button
      await tester.tap(nextButtonFinder);
      await tester.pump();

      expect(mockProvider.nextPageCallCount, 1);
      expect(mockProvider.currentPage, 1);
      expect(mockProvider.hasPrevious, true);

      // Now on page 2, Previous button becomes enabled
      final OutlinedButton updatedPrevButton = tester.widget(prevButtonFinder);
      expect(updatedPrevButton.onPressed, isNotNull);

      // Tap Previous button
      await tester.tap(prevButtonFinder);
      await tester.pump();

      expect(mockProvider.previousPageCallCount, 1);
      expect(mockProvider.currentPage, 0);
    });

    testWidgets('Scenario 5: Next button is disabled on the last page (page 29 of 29)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockProvider = MockUserProvider();
      // On page 28 (0-indexed 29th page), remaining users = 562 - (28 * 20) = 2
      final users = generateMockUsers(2, startId: 561);
      mockProvider.setMockData(
        currentPage: 28,
        pageSize: 20,
        totalUsers: 562,
        totalPages: 29,
        hasNext: false,
        hasPrevious: true,
        users: users,
      );

      await tester.pumpWidget(createTestApp(mockProvider));
      await tester.pump();

      expect(find.text('Showing 561-562 of 562 users'), findsOneWidget);
      expect(find.text('Page 29 of 29'), findsOneWidget);

      final nextButtonFinder = find.widgetWithText(OutlinedButton, 'Next');
      final prevButtonFinder = find.widgetWithText(OutlinedButton, 'Previous');

      final OutlinedButton nextButton = tester.widget(nextButtonFinder);
      final OutlinedButton prevButton = tester.widget(prevButtonFinder);

      // Next is disabled on the last page
      expect(nextButton.onPressed, isNull);
      // Previous is enabled
      expect(prevButton.onPressed, isNotNull);
    });

    testWidgets('Scenario 6 & 7: Search mode displays matching count and prevents invalid pagination',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockProvider = MockUserProvider();
      final users = generateMockUsers(3);
      mockProvider.setMockData(
        currentPage: 0,
        pageSize: 20,
        totalUsers: 562,
        totalPages: 29,
        hasNext: true,
        hasPrevious: false,
        users: users,
      );
      mockProvider.mockFilteredUsers = users;
      mockProvider.searchController.text = 'SpecialUser';

      await tester.pumpWidget(createTestApp(mockProvider));
      await tester.pump(const Duration(milliseconds: 500));

      // Search mode displays found matching count
      expect(find.text('Found 3 matching users'), findsOneWidget);

      final nextButtonFinder = find.widgetWithText(OutlinedButton, 'Next');
      final prevButtonFinder = find.widgetWithText(OutlinedButton, 'Previous');

      final OutlinedButton nextButton = tester.widget(nextButtonFinder);
      final OutlinedButton prevButton = tester.widget(prevButtonFinder);

      // In search mode, pagination buttons are disabled
      expect(nextButton.onPressed, isNull);
      expect(prevButton.onPressed, isNull);

      // Clean up timer
      mockProvider.searchController.clear();
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('Scenario 8: Progress indicator is displayed during page loading and buttons are disabled',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockProvider = MockUserProvider();
      final users = generateMockUsers(20);
      mockProvider.setMockData(
        currentPage: 0,
        pageSize: 20,
        totalUsers: 562,
        totalPages: 29,
        hasNext: true,
        hasPrevious: false,
        users: users,
        isLoading: true,
      );

      await tester.pumpWidget(createTestApp(mockProvider));
      await tester.pump();

      // LinearProgressIndicator is shown at the top of the user list while switching pages
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      final nextButtonFinder = find.widgetWithText(OutlinedButton, 'Next');
      final OutlinedButton nextButton = tester.widget(nextButtonFinder);
      // Next button is disabled while loading
      expect(nextButton.onPressed, isNull);
    });

    testWidgets('Scenario 9: User cards display status, mobile, email, and actions continue to work',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockProvider = MockUserProvider();
      final users = [
        User(
          id: 42,
          firstName: 'Rajesh',
          lastName: 'Kumar',
          emailId: 'rajesh@filmytell.com',
          mobileNumber: '9988776655',
          active: true,
          role: ['USER'],
        ),
      ];
      mockProvider.setMockData(
        currentPage: 0,
        pageSize: 20,
        totalUsers: 1,
        totalPages: 1,
        hasNext: false,
        hasPrevious: false,
        users: users,
      );

      await tester.pumpWidget(createTestApp(mockProvider));
      await tester.pump();

      expect(find.text('Rajesh Kumar'), findsOneWidget);
      expect(find.text('rajesh@filmytell.com'), findsOneWidget);
      expect(find.text('9988776655'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
      expect(find.byIcon(Icons.verified), findsOneWidget);
    });
  });
}
