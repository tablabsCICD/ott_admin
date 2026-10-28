import 'package:admin_ott/domain/entities/location.dart';
import 'package:admin_ott/domain/entities/promoter.dart';

class PromoterHierarchyInfo {
  final int? promoterId;
  final String? promoterName;
  final String? level;
  final Location? location;
  final String? country;
  final String? state;
  final String? district;
  final String? taluka;

  final bool hasParent;
  final int? parentPromoterId;
  final String? parentName;
  final String? parentLevel;
  final String? parentReferralCode;

  PromoterHierarchyInfo({
    this.promoterId,
    this.promoterName,
    this.level,
    this.location,
    this.country,
    this.state,
    this.district,
    this.taluka,
    this.hasParent = false,
    this.parentPromoterId,
    this.parentName,
    this.parentLevel,
    this.parentReferralCode,
  });

  String get normalizedLevel {
    final raw = (level ?? '').trim().toLowerCase();
    if (raw.contains('nation') || raw.contains('country')) return 'National';
    if (raw.contains('state')) return 'State';
    if (raw.contains('district')) return 'District';
    if (raw.contains('taluka')) return 'Taluka';
    if (level?.trim().isNotEmpty == true) return level!.trim();
    return 'Taluka';
  }

  String get normalizedParentLevel {
    final raw = (parentLevel ?? '').trim().toLowerCase();
    if (raw.contains('nation') || raw.contains('country')) return 'National';
    if (raw.contains('state')) return 'State';
    if (raw.contains('district')) return 'District';
    if (raw.contains('taluka')) return 'Taluka';
    return parentLevel?.trim().isNotEmpty == true ? parentLevel!.trim() : '';
  }

  factory PromoterHierarchyInfo.fromJson(
    Map<String, dynamic> json, {
    Promoters? fallbackPromoter,
  }) {
    dynamic data = json['data'] ?? json['Promoter'] ?? json['promoter'] ?? json;
    Map<String, dynamic> dataMap = {};
    if (data is Map<String, dynamic>) {
      dataMap = data;
    } else if (data is Map) {
      dataMap = Map<String, dynamic>.from(data);
    }

    // Check nested promoter map
    Map<String, dynamic> promMap = dataMap;
    if (dataMap['promoter'] is Map) {
      promMap = Map<String, dynamic>.from(dataMap['promoter']);
    } else if (dataMap['Promoter'] is Map) {
      promMap = Map<String, dynamic>.from(dataMap['Promoter']);
    } else if (dataMap['currentPromoter'] is Map) {
      promMap = Map<String, dynamic>.from(dataMap['currentPromoter']);
    }

    // Extract promoter id, name, level
    int? pId;
    if (promMap['id'] != null) {
      pId = int.tryParse(promMap['id'].toString());
    } else if (promMap['promoterId'] != null) {
      pId = int.tryParse(promMap['promoterId'].toString());
    } else if (dataMap['id'] != null) {
      pId = int.tryParse(dataMap['id'].toString());
    } else if (dataMap['promoterId'] != null) {
      pId = int.tryParse(dataMap['promoterId'].toString());
    } else if (fallbackPromoter?.id != null) {
      pId = fallbackPromoter!.id;
    } else if (fallbackPromoter?.userId?.id != null) {
      pId = fallbackPromoter!.userId!.id;
    }

    String? pName = promMap['promoterName'] ??
        promMap['name'] ??
        promMap['userName'] ??
        dataMap['promoterName'] ??
        dataMap['name'] ??
        fallbackPromoter?.promoterName;

    // Search all possible keys for promoter level
    dynamic rawLevel = promMap['level'] ??
        promMap['Level'] ??
        promMap['promoterLevel'] ??
        promMap['PromoterLevel'] ??
        promMap['designation'] ??
        promMap['Designation'] ??
        promMap['role'] ??
        dataMap['level'] ??
        dataMap['Level'] ??
        dataMap['promoterLevel'] ??
        dataMap['PromoterLevel'] ??
        dataMap['designation'] ??
        dataMap['Designation'];

    if (rawLevel == null && promMap['user'] is Map) {
      rawLevel = promMap['user']['level'] ?? promMap['user']['designation'];
    }
    if (rawLevel == null && promMap['userId'] is Map) {
      rawLevel = promMap['userId']['level'] ?? promMap['userId']['designation'];
    }
    if (rawLevel == null && dataMap['user'] is Map) {
      rawLevel = dataMap['user']['level'] ?? dataMap['user']['designation'];
    }
    if (rawLevel == null && dataMap['userId'] is Map) {
      rawLevel = dataMap['userId']['level'] ?? dataMap['userId']['designation'];
    }

    String? pLevel;
    if (rawLevel != null && rawLevel.toString().trim().isNotEmpty && rawLevel.toString().trim().toLowerCase() != 'null') {
      pLevel = rawLevel.toString().trim();
    } else if (fallbackPromoter?.level != null && fallbackPromoter!.level!.trim().isNotEmpty) {
      pLevel = fallbackPromoter.level!.trim();
    } else if (fallbackPromoter != null && fallbackPromoter.normalizedLevel.isNotEmpty) {
      pLevel = fallbackPromoter.normalizedLevel;
    } else {
      pLevel = 'Taluka';
    }

    // Extract location
    Location? pLoc;
    if (promMap['location'] is Map) {
      pLoc = Location.fromJson(Map<String, dynamic>.from(promMap['location']));
    } else if (dataMap['location'] is Map) {
      pLoc = Location.fromJson(Map<String, dynamic>.from(dataMap['location']));
    } else if (fallbackPromoter?.location != null) {
      pLoc = fallbackPromoter!.location;
    } else if (fallbackPromoter?.userId?.location != null) {
      pLoc = fallbackPromoter!.userId!.location;
    }

    final pCountry = pLoc?.country ?? promMap['country'] ?? dataMap['country'] ?? 'India';
    final pState = pLoc?.state ?? promMap['state'] ?? dataMap['state'] ?? '';
    final pDistrict = pLoc?.district ?? promMap['district'] ?? dataMap['district'] ?? '';
    final pTaluka = pLoc?.taluka ?? promMap['taluka'] ?? dataMap['taluka'] ?? '';

    // Extract Parent information
    Map<String, dynamic>? parentMap;
    if (dataMap['parentPromoter'] is Map) {
      parentMap = Map<String, dynamic>.from(dataMap['parentPromoter']);
    } else if (dataMap['ParentPromoter'] is Map) {
      parentMap = Map<String, dynamic>.from(dataMap['ParentPromoter']);
    } else if (dataMap['parent'] is Map) {
      parentMap = Map<String, dynamic>.from(dataMap['parent']);
    } else if (dataMap['Parent'] is Map) {
      parentMap = Map<String, dynamic>.from(dataMap['Parent']);
    } else if (dataMap['reportingPromoter'] is Map) {
      parentMap = Map<String, dynamic>.from(dataMap['reportingPromoter']);
    } else if (dataMap['reportingParent'] is Map) {
      parentMap = Map<String, dynamic>.from(dataMap['reportingParent']);
    } else if (promMap['parentPromoter'] is Map) {
      parentMap = Map<String, dynamic>.from(promMap['parentPromoter']);
    } else if (promMap['ParentPromoter'] is Map) {
      parentMap = Map<String, dynamic>.from(promMap['ParentPromoter']);
    } else if (promMap['parent'] is Map) {
      parentMap = Map<String, dynamic>.from(promMap['parent']);
    } else if (promMap['Parent'] is Map) {
      parentMap = Map<String, dynamic>.from(promMap['Parent']);
    } else if (promMap['reportingPromoter'] is Map) {
      parentMap = Map<String, dynamic>.from(promMap['reportingPromoter']);
    } else if (promMap['reportingParent'] is Map) {
      parentMap = Map<String, dynamic>.from(promMap['reportingParent']);
    }

    if (parentMap != null && parentMap['Promoter'] is Map) {
      parentMap = Map<String, dynamic>.from(parentMap['Promoter']);
    } else if (parentMap != null && parentMap['promoter'] is Map) {
      parentMap = Map<String, dynamic>.from(parentMap['promoter']);
    }

    int? parentId;
    String? parentName;
    String? parentLvl;
    String? parentRef;

    if (parentMap != null) {
      if (parentMap['id'] != null) {
        parentId = int.tryParse(parentMap['id'].toString());
      } else if (parentMap['promoterId'] != null) {
        parentId = int.tryParse(parentMap['promoterId'].toString());
      } else if (parentMap['parentId'] != null) {
        parentId = int.tryParse(parentMap['parentId'].toString());
      } else if (parentMap['parentPromoterId'] != null) {
        parentId = int.tryParse(parentMap['parentPromoterId'].toString());
      }
      parentName = parentMap['promoterName'] ?? parentMap['name'] ?? parentMap['parentName'] ?? parentMap['userName'];
      parentLvl = parentMap['level'] ??
          parentMap['Level'] ??
          parentMap['parentLevel'] ??
          parentMap['promoterLevel'] ??
          parentMap['PromoterLevel'] ??
          parentMap['designation'] ??
          parentMap['Designation'];
      if (parentMap['userId'] is Map) {
        parentRef = parentMap['userId']['refferCode'] ?? parentMap['userId']['referralCode'];
      }
      parentRef ??= parentMap['refferCode'] ?? parentMap['referralCode'] ?? parentMap['parentReferralCode'] ?? parentMap['parentRefferCode'];
    }

    // Check top-level or promoter fields if not found in parentMap
    if (parentId == null) {
      final pidRaw = promMap['parentPromoterId'] ??
          promMap['parentId'] ??
          promMap['parent_id'] ??
          promMap['reportingPromoterId'] ??
          promMap['reportingParentId'] ??
          dataMap['parentPromoterId'] ??
          dataMap['parentId'] ??
          dataMap['parent_id'] ??
          dataMap['reportingPromoterId'] ??
          dataMap['reportingParentId'] ??
          promMap['promoterId'];
      if (pidRaw != null &&
          pidRaw != 0 &&
          pidRaw != '0' &&
          pidRaw.toString() != pId.toString()) {
        parentId = int.tryParse(pidRaw.toString());
      }
    }

    if (parentName == null || parentName.trim().isEmpty) {
      final pnRaw = promMap['parentPromoterName'] ??
          promMap['parentName'] ??
          promMap['reportingPromoterName'] ??
          promMap['reportingParentName'] ??
          promMap['refferedBy'] ??
          promMap['referredBy'] ??
          dataMap['parentPromoterName'] ??
          dataMap['parentName'] ??
          dataMap['reportingPromoterName'] ??
          dataMap['reportingParentName'] ??
          dataMap['refferedBy'] ??
          dataMap['referredBy'];
      if (pnRaw != null &&
          pnRaw.toString().trim().isNotEmpty &&
          pnRaw.toString().trim().toLowerCase() != 'none' &&
          pnRaw.toString().trim().toLowerCase() != 'null') {
        parentName = pnRaw.toString().trim();
      }
    }

    if (parentLvl == null || parentLvl.trim().isEmpty) {
      final plRaw = dataMap['parentLevel'] ??
          dataMap['ParentLevel'] ??
          dataMap['parentPromoterLevel'] ??
          dataMap['ParentPromoterLevel'] ??
          promMap['parentLevel'] ??
          promMap['ParentLevel'] ??
          promMap['parentPromoterLevel'];
      if (plRaw != null && plRaw.toString().trim().isNotEmpty) {
        parentLvl = plRaw.toString().trim();
      }
    }

    if (parentRef == null || parentRef.trim().isEmpty) {
      final prRaw = dataMap['parentReferralCode'] ??
          dataMap['parentRefferCode'] ??
          promMap['parentReferralCode'] ??
          promMap['refferCode'];
      if (prRaw != null && prRaw.toString().trim().isNotEmpty) {
        parentRef = prRaw.toString().trim();
      }
    }

    // Circular check: parent cannot be current promoter
    if (parentId != null && pId != null && parentId == pId) {
      parentId = null;
    }

    // National level promoter cannot have a parent
    final isNational = pLevel.toLowerCase().contains('nation');
    final bool hasParent = !isNational &&
        ((parentId != null && parentId != 0 && parentId != pId) ||
            (parentName != null &&
                parentName.isNotEmpty &&
                parentName.toLowerCase() != 'none' &&
                parentName.toLowerCase() != 'null'));

    return PromoterHierarchyInfo(
      promoterId: pId,
      promoterName: pName,
      level: pLevel,
      location: pLoc,
      country: pCountry,
      state: pState,
      district: pDistrict,
      taluka: pTaluka,
      hasParent: hasParent,
      parentPromoterId: hasParent ? parentId : null,
      parentName: hasParent ? parentName : null,
      parentLevel: hasParent ? parentLvl : null,
      parentReferralCode: hasParent ? parentRef : null,
    );
  }
}
