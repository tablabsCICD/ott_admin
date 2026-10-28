# Filmytell Admin Portal – Backend API Requirements Specification

## Overview
This document specifies the backend API requirements identified during the development and audit of the **Filmytell Admin Portal** (covering Revenue Transparency, Promoter Management, Settlement Processing, and Content Analytics).

---

## 1. Promoter Level & Parent Hierarchy APIs

### A. Dedicated Change Promoter Level API
- **Endpoint**: `/api/Promoters/updateLevel` (or `PUT /api/Promoters/{id}/level`)
- **HTTP Method**: `PUT` or `PATCH`
- **Purpose**: Directly updates a promoter's level (National, State, District, Taluka) and optional parent without requiring the full user and bank details profile to be re-sent.
- **Request Body**:
```json
{
  "promoterId": 88,
  "level": "State",
  "parentId": 12,
  "parentName": "Sunil Sharma"
}
```
- **Response**:
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Promoter level updated to State successfully",
  "data": {
    "promoterId": 88,
    "promoterName": "Rajesh Kumar",
    "previousLevel": "District",
    "newLevel": "State",
    "parentId": 12,
    "parentName": "Sunil Sharma",
    "updatedAt": "2026-09-18T14:30:00Z"
  }
}
```

### B. Dedicated Assign Parent Reporting Promoter API
- **Endpoint**: `/api/Promoters/assignParent` (or `PUT /api/Promoters/{id}/parent`)
- **HTTP Method**: `PUT` or `PATCH`
- **Request Body**:
```json
{
  "promoterId": 88,
  "parentId": 12,
  "parentName": "Sunil Sharma"
}
```
- **Response**:
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Parent promoter assigned successfully"
}
```

### C. Promoter Hierarchy Tree API
- **Endpoint**: `/api/Promoters/getHierarchyTree?promoterId={id}`
- **HTTP Method**: `GET`
- **Purpose**: Returns the full hierarchical lineage and nested sub-promoter network for visualization on the Promoter Details and Hierarchy screens.
- **Response**:
```json
{
  "success": true,
  "data": {
    "promoterId": 12,
    "promoterName": "Sunil Sharma",
    "level": "National",
    "children": [
      {
        "promoterId": 88,
        "promoterName": "Rajesh Kumar",
        "level": "State",
        "totalDirectUsers": 140,
        "totalRevenue": 850000.0000,
        "children": [
          {
            "promoterId": 105,
            "promoterName": "Amit Patil",
            "level": "District",
            "totalDirectUsers": 45,
            "totalRevenue": 210000.0000
          }
        ]
      }
    ]
  }
}
```

---

## 2. Promoter Settlements & Audit Trail APIs

### A. Promoter Settlement Disbursement History API
- **Endpoint**: `/api/settlement/promoter`
- **HTTP Method**: `GET`
- **Query Parameters**:
  - `promoterId` (required): Promoter ID
  - `page` (optional, default: 0)
  - `limit` (optional, default: 20)
- **Response**:
```json
{
  "success": true,
  "data": {
    "promoterId": 88,
    "totalPaid": 125000.0000,
    "pendingBalance": 12706.7797,
    "settlements": [
      {
        "settlementId": "SET-2026-0012",
        "period": "01/09/2026 - 15/09/2026",
        "grossRevenueGenerated": 450000.0000,
        "commissionEarned": 4500.0000,
        "tdsDeduction": 450.0000,
        "payoutCharges": 81.0000,
        "netPaid": 3969.0000,
        "utrNumber": "HDFC2026091600129",
        "bankName": "HDFC Bank",
        "accountNumber": "XXXXXX4921",
        "status": "PAID",
        "paidAt": "2026-09-16T10:30:00Z"
      }
    ]
  }
}
```

### B. Persistent Administrative Audit Trail API
- **Endpoint**: `/api/admin/audit-logs`
- **HTTP Method**: `GET`
- **Query Parameters**:
  - `entityType` (optional): `PROMOTER`, `MEDIA_HOUSE`, `CONTENT`, `SETTLEMENT`
  - `entityId` (optional): Entity ID
- **Response**:
```json
{
  "success": true,
  "data": [
    {
      "id": 501,
      "entityType": "PROMOTER",
      "entityId": 88,
      "actionType": "CHANGE_LEVEL",
      "description": "Level changed from District to State",
      "previousValue": "District",
      "newValue": "State",
      "performedBy": "Admin (admin@filmytell.com)",
      "ipAddress": "192.168.1.50",
      "createdAt": "2026-09-18T08:15:00Z"
    }
  ]
}
```

---

## 3. Production House & Content-Wise Transparency APIs

### A. Production House Content-Wise Financial Breakdown API (Level 2 Drill-Down)
- **Endpoint**: `/api/v1/analytics/production-house/{id}/content-revenue`
- **HTTP Method**: `GET`
- **Request Parameters**:
  - `id` (path, required): Media House ID
  - `startDate` (query, optional)
  - `endDate` (query, optional)
- **Response**:
```json
{
  "success": true,
  "data": {
    "mediaHouseId": 14,
    "mediaHouseName": "Filmytell Studios",
    "totalCustomerPayment": 1250000.0000,
    "totalGst": 190677.9661,
    "totalBaseAmount": 1059322.0339,
    "totalGatewayFee": 25000.0000,
    "totalNetRevenue": 1034322.0339,
    "totalProductionGross": 724025.4237,
    "totalProductionTds": 72402.5424,
    "totalProductionPayoutCharge": 14480.5085,
    "totalFinalProductionRevenue": 637142.3728,
    "contentBreakdown": [
      {
        "contentId": 101,
        "title": "Samrat Prithviraj",
        "type": "MOVIE",
        "purchases": 4200,
        "customerPayment": 420000.0000,
        "gst": 64067.7966,
        "baseAmount": 355932.2034,
        "gatewayFee": 8400.0000,
        "netRevenue": 347532.2034,
        "productionGross": 243272.5424,
        "productionTds": 24327.2542,
        "productionPayoutCharge": 4865.4508,
        "finalProductionRevenue": 214079.8374
      }
    ]
  }
}
```

### B. Promoter Multi-Level Referral Revenue Attribution API
- **Endpoint**: `/api/v1/promoter/{id}/revenue-transparency`
- **HTTP Method**: `GET`
- **Request Parameters**:
  - `id` (path, required): Promoter ID
  - `startDate`, `endDate` (query, optional)
- **Response**:
```json
{
  "success": true,
  "data": {
    "promoterId": 88,
    "promoterName": "Rajesh Kumar",
    "tierLevel": "National",
    "commissionRatePercentage": 2.0000,
    "totalCustomerPaymentGenerated": 850000.0000,
    "baseRevenue": 720338.9831,
    "grossCommissionEarned": 14406.7797,
    "tdsDeduction": 1440.6780,
    "payoutCharges": 259.3220,
    "netWalletCredited": 12706.7797,
    "productionHouseBreakdown": [
      {
        "mediaHouseId": 14,
        "mediaHouseName": "Filmytell Studios",
        "transactionsCount": 1420,
        "customerPayment": 450000.0000,
        "baseAmount": 381355.9322,
        "promoterRate": 2.0000,
        "promoterShare": 7627.1186
      }
    ],
    "contentBreakdown": [
      {
        "contentId": 101,
        "title": "Samrat Prithviraj",
        "type": "MOVIE",
        "transactionsCount": 980,
        "customerPayment": 294000.0000,
        "baseAmount": 249152.5424,
        "promoterRate": 2.0000,
        "promoterShare": 4983.0508
      }
    ]
  }
}
```

---

## 4. Key Financial Constants & Rules

| Parameter | Value | Calculation Formula |
| :--- | :--- | :--- |
| **GST Rate** | `18.0000%` | $\text{Base Amount} = \text{Customer Payment} / 1.18$ |
| **Payment Gateway Fee** | `2.0000%` | $\text{Customer Payment} \times 2\%$ |
| **Net Revenue** | Split Basis | $\text{Base Amount} - \text{Gateway Fee}$ |
| **Platform Share** | `30.0000%` | $\text{Net Revenue} \times 30\%$ |
| **Production House Share** | `70.0000%` | $\text{Net Revenue} \times 70\%$ |
| **Production TDS** | `10.0000%` | $\text{Production Share} \times 10\%$ |
| **Production Payout Fee** | `2.0000%` | $\text{Production Share} \times 2\%$ |
| **Promoter Commission** | `0.5%` - `2.0%` | Calculated on Base Revenue, paid from platform marketing reserves, **excluded** from Total Revenue |
| **Display Format** | `₹ #,##,##0.0000` | Strict 4 decimal places across all screens |

