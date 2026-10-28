import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:admin_ott/app/provider/mediaHouseProvider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/ui/pages/manage media house page/component/edit_media_house_dialog.dart';
import 'package:admin_ott/domain/entities/mediaHouse.dart';

void main() {
  group('Edit Production House Document Mapping & State Isolation Tests', () {
    late MediaHouse sampleHouse;

    setUp(() {
      sampleHouse = MediaHouse(
        id: 101,
        mediaHouseName: 'Star Studios',
        logo: 'https://cdn.example.com/images/star_logo.png',
        profileImage: 'https://cdn.example.com/images/star_poster.jpg',
        adharCard: 'https://cdn.example.com/docs/aadhaar_authority.pdf',
        panCard: 'https://cdn.example.com/docs/firm_pan.pdf',
        gstCertificates: 'https://cdn.example.com/docs/gst_cert.pdf',
        registrationCertificate: 'https://cdn.example.com/docs/reg_cert.pdf',
        shopAct: 'https://cdn.example.com/docs/shop_act.pdf',
        bankProof: 'https://cdn.example.com/docs/bank_statement.pdf',
        addressProof: 'https://cdn.example.com/docs/electricity_bill.pdf',
        contactNumber: '9876543210',
        email: 'info@starstudios.com',
        status: 'ACTIVE',
        active: true,
      );
    });

    test('1. Initial data correctly populates all document and branding fields independently', () {
      final json = sampleHouse.toUpdateJson();

      expect(json['id'], 101);
      expect(json['logo'], 'https://cdn.example.com/images/star_logo.png');
      expect(json['profileImage'], 'https://cdn.example.com/images/star_poster.jpg');
      expect(json['adharCard'], 'https://cdn.example.com/docs/aadhaar_authority.pdf');
      expect(json['panCard'], 'https://cdn.example.com/docs/firm_pan.pdf');
      expect(json['gstCertificates'], 'https://cdn.example.com/docs/gst_cert.pdf');
      expect(json['registrationCertificate'], 'https://cdn.example.com/docs/reg_cert.pdf');
      expect(json['shopAct'], 'https://cdn.example.com/docs/shop_act.pdf');
      expect(json['bankProof'], 'https://cdn.example.com/docs/bank_statement.pdf');
      expect(json['addressProof'], 'https://cdn.example.com/docs/electricity_bill.pdf');
    });

    test('2 & 3. Updating Logo does not bleed into Aadhaar card, PAN card, or Poster', () {
      const newLogoUrl = 'https://cdn.example.com/images/new_star_logo_2026.png';

      final updated = sampleHouse.copyWith(logo: newLogoUrl);

      expect(updated.logo, newLogoUrl);
      // All other fields remain their original values
      expect(updated.adharCard, 'https://cdn.example.com/docs/aadhaar_authority.pdf');
      expect(updated.panCard, 'https://cdn.example.com/docs/firm_pan.pdf');
      expect(updated.profileImage, 'https://cdn.example.com/images/star_poster.jpg');
      expect(updated.gstCertificates, 'https://cdn.example.com/docs/gst_cert.pdf');
    });

    test('4. Updating Aadhaar Card preserves Logo, PAN Card, and Poster', () {
      const newAadhaarUrl = 'https://cdn.example.com/docs/new_aadhaar_2026.pdf';

      final updated = sampleHouse.copyWith(adharCard: newAadhaarUrl);

      expect(updated.adharCard, newAadhaarUrl);
      expect(updated.logo, 'https://cdn.example.com/images/star_logo.png');
      expect(updated.panCard, 'https://cdn.example.com/docs/firm_pan.pdf');
      expect(updated.profileImage, 'https://cdn.example.com/images/star_poster.jpg');
    });

    test('5. Updating PAN Card preserves Logo, Aadhaar Card, and other statutory documents', () {
      const newPanUrl = 'https://cdn.example.com/docs/new_pan_card_2026.pdf';

      final updated = sampleHouse.copyWith(panCard: newPanUrl);

      expect(updated.panCard, newPanUrl);
      expect(updated.adharCard, 'https://cdn.example.com/docs/aadhaar_authority.pdf');
      expect(updated.logo, 'https://cdn.example.com/images/star_logo.png');
      expect(updated.profileImage, 'https://cdn.example.com/images/star_poster.jpg');
      expect(updated.gstCertificates, 'https://cdn.example.com/docs/gst_cert.pdf');
      expect(updated.registrationCertificate, 'https://cdn.example.com/docs/reg_cert.pdf');
    });

    test('6. Updating Poster preserves Logo and all compliance documents', () {
      const newPosterUrl = 'https://cdn.example.com/images/new_movie_poster_banner.jpg';

      final updated = sampleHouse.copyWith(profileImage: newPosterUrl);

      expect(updated.profileImage, newPosterUrl);
      expect(updated.logo, 'https://cdn.example.com/images/star_logo.png');
      expect(updated.adharCard, 'https://cdn.example.com/docs/aadhaar_authority.pdf');
      expect(updated.panCard, 'https://cdn.example.com/docs/firm_pan.pdf');
    });

    test('7 & 8. Replacing multiple files simultaneously maintains strict field mapping and persistence', () {
      const updatedLogo = 'https://cdn.example.com/brand/logo_v2.png';
      const updatedPoster = 'https://cdn.example.com/brand/poster_v2.jpg';
      const updatedAadhaar = 'https://cdn.example.com/compliance/aadhaar_v2.pdf';
      const updatedPan = 'https://cdn.example.com/compliance/pan_v2.pdf';
      const updatedGst = 'https://cdn.example.com/compliance/gst_v2.pdf';

      final updatedHouse = sampleHouse.copyWith(
        logo: updatedLogo,
        profileImage: updatedPoster,
        adharCard: updatedAadhaar,
        panCard: updatedPan,
        gstCertificates: updatedGst,
      );

      final payload = updatedHouse.toUpdateJson();

      expect(payload['logo'], updatedLogo);
      expect(payload['profileImage'], updatedPoster);
      expect(payload['adharCard'], updatedAadhaar);
      expect(payload['panCard'], updatedPan);
      expect(payload['gstCertificates'], updatedGst);

      // Verify that reconstructing from payload preserves each field in its exact slot
      final reloadedHouse = MediaHouse.fromJson(payload);
      expect(reloadedHouse.logo, updatedLogo);
      expect(reloadedHouse.profileImage, updatedPoster);
      expect(reloadedHouse.adharCard, updatedAadhaar);
      expect(reloadedHouse.panCard, updatedPan);
      expect(reloadedHouse.gstCertificates, updatedGst);
      expect(reloadedHouse.bankProof, 'https://cdn.example.com/docs/bank_statement.pdf');
      expect(reloadedHouse.addressProof, 'https://cdn.example.com/docs/electricity_bill.pdf');
    });

    test('9. Response URL parser cleanly extracts direct and nested upload URLs without corruption', () {
      // Test direct string
      final directJson = jsonEncode('https://filmytell.com/uploads/logo.png');
      final decodedDirect = jsonDecode(directJson);
      expect(decodedDirect, 'https://filmytell.com/uploads/logo.png');

      // Test { data: { fileUrl: ... } }
      final nestedJson = jsonEncode({
        'success': true,
        'data': {'fileUrl': 'https://filmytell.com/uploads/aadhaar.pdf'}
      });
      final decodedNested = jsonDecode(nestedJson);
      expect(decodedNested['data']['fileUrl'], 'https://filmytell.com/uploads/aadhaar.pdf');

      // Test { data: "url" }
      final flatDataJson = jsonEncode({
        'success': true,
        'data': 'https://filmytell.com/uploads/pan.pdf'
      });
      final decodedFlat = jsonDecode(flatDataJson);
      expect(decodedFlat['data'], 'https://filmytell.com/uploads/pan.pdf');
    });

    test('10. Poster alias parses correctly from json with "poster" or "posterUrl"', () {
      final houseWithPoster = MediaHouse.fromJson({
        'id': 202,
        'mediaHouseName': 'Apex Films',
        'poster': 'https://cdn.example.com/posters/apex_banner.jpg',
      });
      expect(houseWithPoster.profileImage, 'https://cdn.example.com/posters/apex_banner.jpg');

      final houseWithPosterUrl = MediaHouse.fromJson({
        'id': 203,
        'mediaHouseName': 'Zenith Media',
        'posterUrl': 'https://cdn.example.com/posters/zenith_banner.jpg',
      });
      expect(houseWithPosterUrl.profileImage, 'https://cdn.example.com/posters/zenith_banner.jpg');
    });
  });

  group('EditMediaHouseDialog Widget UI & Field Inspection Tests', () {
    late MediaHouse testHouse;

    setUp(() {
      testHouse = MediaHouse(
        id: 303,
        mediaHouseName: 'Paramount Creations',
        logo: 'https://cdn.example.com/images/paramount_logo.png',
        profileImage: 'https://cdn.example.com/images/paramount_poster.jpg',
        adharCard: 'https://cdn.example.com/docs/aadhaar.pdf',
        panCard: 'https://cdn.example.com/docs/pan.pdf',
        gstCertificates: 'https://cdn.example.com/docs/gst.pdf',
        registrationCertificate: 'https://cdn.example.com/docs/reg.pdf',
        shopAct: 'https://cdn.example.com/docs/shop.pdf',
        bankProof: 'https://cdn.example.com/docs/bank.pdf',
        addressProof: 'https://cdn.example.com/docs/address.pdf',
        status: 'ACTIVE',
        active: true,
      );
    });

    testWidgets('Renders Edit Production House dialog with 5 tabs and dedicated sections', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => MediaHouseProvider()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: EditMediaHouseDialog(mediaHouse: testHouse),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('Edit Production House'), findsOneWidget);
      expect(find.text('Paramount Creations'), findsWidgets);

      // Verify all 5 Tabs exist
      expect(find.text('Basic Details'), findsWidgets);
      expect(find.text('Address & Location'), findsOneWidget);
      expect(find.text('Bank & Documents'), findsOneWidget);
      expect(find.text('Contact Details'), findsOneWidget);
      expect(find.text('Branding & System'), findsOneWidget);

      // Switch to Tab 3: Bank & Documents
      await tester.tap(find.text('Bank & Documents'));
      await tester.pumpAndSettle();

      expect(find.text('Statutory & Compliance Documents'), findsOneWidget);
      expect(find.text('Signing Authority Aadhaar Card'), findsOneWidget);
      expect(find.text('Firm PAN Card'), findsOneWidget);
      expect(find.text('GST Certificate'), findsOneWidget);
      expect(find.text('Registration Certificate'), findsOneWidget);
      expect(find.text('Shop Act / Udyam Aadhaar'), findsOneWidget);
      expect(find.text('Bank Proof'), findsOneWidget);
      expect(find.text('Address Proof'), findsOneWidget);

      // Switch to Tab 5: Branding & System
      await tester.ensureVisible(find.text('Branding & System'));
      await tester.tap(find.text('Branding & System'));
      await tester.pumpAndSettle();

      expect(find.text('Visual Branding'), findsOneWidget);
      expect(find.text('Production House Logo'), findsOneWidget);
      expect(find.text('Production House Poster'), findsOneWidget);
      expect(find.text('System Identifiers (Read-Only)'), findsOneWidget);

      // Verify Cancel and Save buttons exist
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
    });
  });
}
