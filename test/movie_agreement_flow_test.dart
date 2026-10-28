import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/ui/pages/manage%20content%20page/component/content_review_components.dart';
import 'package:admin_ott/domain/entities/content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  group('Movie Agreement Flow & Visibility Tests', () {
    // Scenario 1: A movie with an already uploaded agreement
    test('1. Movie with directly uploaded agreementUrl parses and resolves accurately', () {
      final json = {
        "id": 101,
        "title": "Kantara Chapter 1",
        "agreementUrl": "https://filmytell.com/ott/uploads/agreements/kantara_agreement.pdf",
        "sensorCertificate": "https://filmytell.com/ott/uploads/certificates/kantara_censor.jpg",
        "mediaHouseName": "Hombale Films",
      };

      final movie = Content.fromJson(json);
      expect(movie.agreementUrl, "https://filmytell.com/ott/uploads/agreements/kantara_agreement.pdf");
      expect(movie.resolvedAgreementUrl, "https://filmytell.com/ott/uploads/agreements/kantara_agreement.pdf");
      expect(movie.sensorCertificate, "https://filmytell.com/ott/uploads/certificates/kantara_censor.jpg");
    });

    test('1b. Movie with snake_case and alias agreement keys parses correctly', () {
      final jsonSnake = {
        "id": 102,
        "title": "Leo",
        "agreement_url": "https://filmytell.com/ott/uploads/agreements/leo_agreement.pdf",
      };
      final movieSnake = Content.fromJson(jsonSnake);
      expect(movieSnake.agreementUrl, "https://filmytell.com/ott/uploads/agreements/leo_agreement.pdf");
      expect(movieSnake.resolvedAgreementUrl, "https://filmytell.com/ott/uploads/agreements/leo_agreement.pdf");

      final jsonProdHouse = {
        "id": 103,
        "title": "Jailer",
        "productionHouseAgreement": "https://filmytell.com/ott/agreements/jailer_contract.pdf",
      };
      final movieProd = Content.fromJson(jsonProdHouse);
      expect(movieProd.agreementUrl, "https://filmytell.com/ott/agreements/jailer_contract.pdf");

      final jsonNestedMedia = {
        "id": 104,
        "title": "Vikram",
        "mediaHouse": {
          "id": 5,
          "name": "Raaj Kamal Films",
          "agreementUrl": "https://filmytell.com/ott/agreements/rkfi_agreement.pdf"
        }
      };
      final movieNested = Content.fromJson(jsonNestedMedia);
      expect(movieNested.agreementUrl, "https://filmytell.com/ott/agreements/rkfi_agreement.pdf");
    });

    test('1c. Movie with agreement stored in legacy sensorCertificate field resolves agreement', () {
      final jsonLegacy = {
        "id": 105,
        "title": "Legacy Agreement Title",
        "sensorCertificate": "https://filmytell.com/ott/uploads/agreements/signed_agreement_105.pdf",
      };
      final movieLegacy = Content.fromJson(jsonLegacy);
      expect(movieLegacy.agreementUrl, "https://filmytell.com/ott/uploads/agreements/signed_agreement_105.pdf");
      expect(movieLegacy.resolvedAgreementUrl, "https://filmytell.com/ott/uploads/agreements/signed_agreement_105.pdf");
    });

    // Scenario 2: A movie without an agreement
    test('2. Movie without an agreement returns null and preserves separate certificate', () {
      final jsonNoAgreement = {
        "id": 201,
        "title": "Movie Without Agreement",
        "sensorCertificate": "https://filmytell.com/ott/uploads/certificates/censor_u_certificate.jpg",
      };

      final movie = Content.fromJson(jsonNoAgreement);
      expect(movie.agreementUrl, isNull);
      expect(movie.resolvedAgreementUrl, isNull);
      expect(movie.sensorCertificate, "https://filmytell.com/ott/uploads/certificates/censor_u_certificate.jpg");
    });

    // Scenario 3: A movie whose agreement URL is missing or invalid
    test('3. Movie with blank, null, or empty string agreement handles gracefully', () {
      final jsonEmpty = {
        "id": 301,
        "title": "Empty Agreement Movie",
        "agreementUrl": "   ",
        "sensorCertificate": null,
      };

      final movie = Content.fromJson(jsonEmpty);
      expect(movie.agreementUrl, isNull);
      expect(movie.resolvedAgreementUrl, isNull);
    });

    // Scenario 4 & 7: Multiple movies with different agreements and verifying correct display
    test('4 & 7. Multiple movies maintain independent and distinct agreements without bleed', () {
      final movieA = Content.fromJson({
        "id": 401,
        "title": "Movie Alpha",
        "agreementUrl": "https://filmytell.com/ott/uploads/alpha_agreement.pdf",
        "mediaHouseName": "Production Alpha",
      });

      final movieB = Content.fromJson({
        "id": 402,
        "title": "Movie Beta",
        "agreementUrl": "https://filmytell.com/ott/uploads/beta_agreement.pdf",
        "mediaHouseName": "Production Beta",
      });

      final movieC = Content.fromJson({
        "id": 403,
        "title": "Movie Gamma",
        "mediaHouseName": "Production Gamma",
      });

      expect(movieA.resolvedAgreementUrl, "https://filmytell.com/ott/uploads/alpha_agreement.pdf");
      expect(movieB.resolvedAgreementUrl, "https://filmytell.com/ott/uploads/beta_agreement.pdf");
      expect(movieC.resolvedAgreementUrl, isNull);

      expect(movieA.resolvedAgreementUrl, isNot(equals(movieB.resolvedAgreementUrl)));
    });

    // Scenario 6: Refreshing Movie Details screen (simulating mergeWith)
    test('6. Refreshing Movie Details via mergeWith retains agreement without data loss', () {
      final summaryMovie = Content(
        id: 501,
        title: "Dune Part Two",
        agreementUrl: "https://filmytell.com/ott/uploads/dune_agreement.pdf",
      );

      final fullDetailsWithAgreement = Content(
        id: 501,
        title: "Dune Part Two",
        description: "Paul Atreides unites with Chani and the Fremen",
        runtime: 166,
        agreementUrl: "https://filmytell.com/ott/uploads/dune_agreement_updated.pdf",
      );

      final merged = summaryMovie.mergeWith(fullDetailsWithAgreement);
      expect(merged.agreementUrl, "https://filmytell.com/ott/uploads/dune_agreement_updated.pdf");
      expect(merged.resolvedAgreementUrl, "https://filmytell.com/ott/uploads/dune_agreement_updated.pdf");

      // Even if full details has null agreementUrl, summary's existing agreement is retained
      final fullDetailsWithoutAgreement = Content(
        id: 501,
        title: "Dune Part Two",
        description: "Refreshed metadata",
      );
      final mergedRetained = summaryMovie.mergeWith(fullDetailsWithoutAgreement);
      expect(mergedRetained.agreementUrl, "https://filmytell.com/ott/uploads/dune_agreement.pdf");
    });
  });

  group('AgreementSection Widget UI Tests', () {
    Widget buildTestableWidget(Widget child) {
      return MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<ThemeProvider>(
            create: (_) => ThemeProvider(),
            child: child,
          ),
        ),
      );
    }

    testWidgets('Renders Production House Agreement card with View and Download buttons when uploaded', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const AgreementSection(
            agreementUrl: 'https://filmytell.com/ott/uploads/agreements/filmytell_mou_agreement.pdf',
            censorCertificateUrl: 'https://filmytell.com/ott/uploads/certificates/cert_ua.jpg',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Label verification
      expect(find.text('Production House Agreement'), findsOneWidget);
      expect(find.text('Censor Certificate'), findsOneWidget);

      // File name display verification
      expect(find.text('filmytell_mou_agreement.pdf'), findsOneWidget);

      // Buttons verification
      expect(find.text('View Agreement'), findsOneWidget);
      expect(find.text('Download Agreement'), findsOneWidget);

      // Status badge and format verification
      expect(find.text('Uploaded'), findsNWidgets(2));
      expect(find.text('PDF'), findsOneWidget);
    });

    testWidgets('Renders clear "Agreement not uploaded" empty state when no agreement exists', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const AgreementSection(
            agreementUrl: null,
            censorCertificateUrl: null,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Appropriate labels
      expect(find.text('Production House Agreement'), findsOneWidget);
      expect(find.text('Censor Certificate'), findsOneWidget);

      // Clear empty state messages
      expect(find.text('Agreement not uploaded'), findsOneWidget);
      expect(find.text('Censor Certificate not uploaded'), findsOneWidget);

      // Status indicator
      expect(find.text('Not Uploaded'), findsNWidgets(2));

      // No View or Download buttons for missing agreement
      expect(find.text('View Agreement'), findsNothing);
      expect(find.text('Download Agreement'), findsNothing);
    });

    testWidgets('Handles single agreement uploaded without separate censor certificate', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const AgreementSection(
            agreementUrl: 'https://filmytell.com/ott/contracts/exclusive_agreement.pdf',
            censorCertificateUrl: null,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Production House Agreement'), findsOneWidget);
      expect(find.text('exclusive_agreement.pdf'), findsOneWidget);
      expect(find.text('View Agreement'), findsOneWidget);
      expect(find.text('Download Agreement'), findsOneWidget);

      // Censor certificate is not uploaded
      expect(find.text('Censor Certificate not uploaded'), findsOneWidget);
    });

    testWidgets('Renders The Mars movie agreement and censor certificate correctly', (tester) async {
      final theMars = Content(
        id: 50,
        title: 'The Mars',
        type: 'MOVIE',
        agreementUrl: 'https://filmytell.com/agreements/the_mars_agreement.pdf',
        sensorCertificate: 'https://filmytell.com/certificates/the_mars_censor.jpg',
      );

      await tester.pumpWidget(
        buildTestableWidget(
          AgreementSection(
            agreementUrl: theMars.resolvedAgreementUrl,
            censorCertificateUrl: theMars.sensorCertificate,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Production House Agreement'), findsOneWidget);
      expect(find.text('the_mars_agreement.pdf'), findsOneWidget);
      expect(find.text('View Agreement'), findsOneWidget);
      expect(find.text('Download Agreement'), findsOneWidget);
      expect(find.text('the_mars_censor.jpg'), findsOneWidget);
      expect(find.text('Uploaded'), findsNWidgets(2));
    });

    testWidgets('Renders Second Son Whiz short film agreement correctly', (tester) async {
      final secondSonWhiz = Content(
        id: 72,
        title: 'Second Son Whiz',
        type: 'SHORT_FILM',
        aggrementDocument: 'https://filmytell.com/agreements/second_son_whiz_agreement.pdf',
        isAggrement: true,
      );

      await tester.pumpWidget(
        buildTestableWidget(
          AgreementSection(
            agreementUrl: secondSonWhiz.resolvedAgreementUrl ?? secondSonWhiz.aggrementDocument,
            censorCertificateUrl: null,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Production House Agreement'), findsOneWidget);
      expect(find.text('second_son_whiz_agreement.pdf'), findsOneWidget);
      expect(find.text('View Agreement'), findsOneWidget);
      expect(find.text('Download Agreement'), findsOneWidget);
      expect(find.text('Censor Certificate not uploaded'), findsOneWidget);
      expect(find.text('Uploaded'), findsOneWidget);
    });
  });

  group('Comparison: The Mars Movie vs Second Son Whiz Short Film', () {
    test('Both The Mars and Second Son Whiz resolve their agreements correctly despite different field naming', () {
      // The Mars: standard movie agreement payload
      final theMarsJson = {
        "id": 50,
        "title": "The Mars",
        "type": "MOVIE",
        "mediaHouseId": 10,
        "mediaHouseName": "Red Planet Studios",
        "agreementUrl": "https://filmytell.com/agreements/the_mars_agreement.pdf",
        "sensorCertificate": "https://filmytell.com/certificates/the_mars_censor.jpg",
      };

      // Second Son Whiz: production house uploaded short film payload with aggrementDocument
      final secondSonWhizJson = {
        "id": 72,
        "title": "Second Son Whiz",
        "type": "SHORT_FILM",
        "mediaHouseId": 25,
        "mediaHouseName": "Whiz Media House",
        "aggrementDocument": "https://filmytell.com/agreements/second_son_whiz_agreement.pdf",
        "isAggrement": true,
        "registrationFeeDetails":
            "Agreement Upload URL: https://filmytell.com/agreements/second_son_whiz_agreement.pdf; Agreement Signed Date: 2026-10-15; Agreement Uploaded: Y",
      };

      final theMars = Content.fromJson(theMarsJson);
      final secondSonWhiz = Content.fromJson(secondSonWhizJson);

      // Verify The Mars
      expect(theMars.id, 50);
      expect(theMars.title, "The Mars");
      expect(theMars.type, "MOVIE");
      expect(theMars.mediaHouseId, 10);
      expect(theMars.agreementUrl, "https://filmytell.com/agreements/the_mars_agreement.pdf");
      expect(theMars.resolvedAgreementUrl, "https://filmytell.com/agreements/the_mars_agreement.pdf");
      expect(theMars.sensorCertificate, "https://filmytell.com/certificates/the_mars_censor.jpg");

      // Verify Second Son Whiz
      expect(secondSonWhiz.id, 72);
      expect(secondSonWhiz.title, "Second Son Whiz");
      expect(secondSonWhiz.type, "SHORT_FILM");
      expect(secondSonWhiz.mediaHouseId, 25);
      expect(secondSonWhiz.aggrementDocument, "https://filmytell.com/agreements/second_son_whiz_agreement.pdf");
      expect(secondSonWhiz.isAggrement, isTrue);
      expect(secondSonWhiz.resolvedAgreementUrl, "https://filmytell.com/agreements/second_son_whiz_agreement.pdf");

      // Verify independence
      expect(theMars.resolvedAgreementUrl, isNot(equals(secondSonWhiz.resolvedAgreementUrl)));
      expect(theMars.id, isNot(equals(secondSonWhiz.id)));
      expect(theMars.mediaHouseId, isNot(equals(secondSonWhiz.mediaHouseId)));
    });

    test('Second Son Whiz parses when wrapped inside ContentList API response from getById', () {
      final apiResponse = {
        "status": 200,
        "message": "Content fetched successfully",
        "data": {
          "ContentList": {
            "id": 72,
            "title": "Second Son Whiz",
            "type": "SHORT_FILM",
            "mediaHouseId": 25,
            "mediaHouseName": "Whiz Media House",
            "aggrementDocument": "https://filmytell.com/agreements/second_son_whiz_agreement.pdf",
            "isAggrement": true,
            "registrationFeeDetails":
                "Agreement Upload URL: https://filmytell.com/agreements/second_son_whiz_agreement.pdf; Agreement Signed Date: 2026-10-15; Agreement Uploaded: Y",
          }
        }
      };

      final content = Content.fromJson(apiResponse);
      expect(content.id, 72);
      expect(content.title, "Second Son Whiz");
      expect(content.type, "SHORT_FILM");
      expect(content.mediaHouseId, 25);
      expect(content.aggrementDocument, "https://filmytell.com/agreements/second_son_whiz_agreement.pdf");
      expect(content.isAggrement, isTrue);
      expect(content.resolvedAgreementUrl, "https://filmytell.com/agreements/second_son_whiz_agreement.pdf");
    });

    test('Refreshing Second Son Whiz via mergeWith retains agreement information', () {
      final summaryShortFilm = Content(
        id: 72,
        title: "Second Son Whiz",
        type: "SHORT_FILM",
        aggrementDocument: "https://filmytell.com/agreements/second_son_whiz_agreement.pdf",
        isAggrement: true,
      );

      final fullDetailsShortFilm = Content(
        id: 72,
        title: "Second Son Whiz",
        type: "SHORT_FILM",
        description: "An inspiring short film about a prodigy.",
        aggrementDocument: "https://filmytell.com/agreements/second_son_whiz_agreement.pdf",
        isAggrement: true,
      );

      final merged = summaryShortFilm.mergeWith(fullDetailsShortFilm);
      expect(merged.id, 72);
      expect(merged.title, "Second Son Whiz");
      expect(merged.description, "An inspiring short film about a prodigy.");
      expect(merged.aggrementDocument, "https://filmytell.com/agreements/second_son_whiz_agreement.pdf");
      expect(merged.resolvedAgreementUrl, "https://filmytell.com/agreements/second_son_whiz_agreement.pdf");
      expect(merged.isAggrement, isTrue);
    });

    test('Short film with agreement only in registrationFeeDetails successfully extracts URL', () {
      final jsonFeeOnly = {
        "id": 88,
        "title": "Indie Short Film",
        "type": "SHORT_FILM",
        "registrationFeeDetails":
            "Agreement Upload URL: https://filmytell.com/contracts/indie_short_signed.pdf; Agreement Signed Date: 2026-08-01; Agreement Uploaded: Y",
      };

      final shortFilm = Content.fromJson(jsonFeeOnly);
      expect(shortFilm.resolvedAgreementUrl, "https://filmytell.com/contracts/indie_short_signed.pdf");
    });

    test('Short film without agreement leaves agreement fields null gracefully', () {
      final jsonNoAgreement = {
        "id": 99,
        "title": "Uncontracted Short Film",
        "type": "SHORT_FILM",
        "isAggrement": false,
      };

      final shortFilm = Content.fromJson(jsonNoAgreement);
      expect(shortFilm.resolvedAgreementUrl, isNull);
      expect(shortFilm.agreementUrl, isNull);
      expect(shortFilm.aggrementDocument, isNull);
    });
  });
}

