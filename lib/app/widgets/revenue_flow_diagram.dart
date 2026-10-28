import 'package:flutter/material.dart';
import 'package:admin_ott/app/widgets/financial_formatter.dart';

/// Visual financial transparency flow diagram showing the entire breakdown
/// from Customer Payment to Platform, Production House, and Promoter payouts.
class RevenueFlowDiagram extends StatelessWidget {
  final double customerPayment;
  final double? gstAmount;
  final double? baseAmount;
  final double? gatewayFee;
  final double? netRevenue;
  final double? platformRevenue;
  final double? productionGrossRevenue;
  final double? productionTds;
  final double? productionPayoutCharge;
  final double? finalProductionRevenue;
  final double? promoterRevenue;
  final double? promoterRate;

  const RevenueFlowDiagram({
    super.key,
    required this.customerPayment,
    this.gstAmount,
    this.baseAmount,
    this.gatewayFee,
    this.netRevenue,
    this.platformRevenue,
    this.productionGrossRevenue,
    this.productionTds,
    this.productionPayoutCharge,
    this.finalProductionRevenue,
    this.promoterRevenue,
    this.promoterRate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final calculatedBase = baseAmount ?? FinancialFormatter.calculateBaseAmount(customerPayment);
    final calculatedGst = gstAmount ?? FinancialFormatter.calculateGst(customerPayment);
    final calculatedGateway = gatewayFee ?? FinancialFormatter.calculateGatewayFee(customerPayment);
    final calculatedNet = netRevenue ?? (calculatedBase - calculatedGateway);
    final calculatedPlatform = platformRevenue ?? FinancialFormatter.calculatePlatformRevenue(calculatedNet);
    final calculatedProdGross = productionGrossRevenue ?? FinancialFormatter.calculateProductionGrossRevenue(calculatedNet);
    final calculatedTds = productionTds ?? FinancialFormatter.calculateProductionTds(calculatedProdGross);
    final calculatedPayout = productionPayoutCharge ?? FinancialFormatter.calculateProductionPayoutCharge(calculatedProdGross);
    final calculatedFinalProd = finalProductionRevenue ?? (calculatedProdGross - calculatedTds - calculatedPayout);
    final calculatedPromoter = promoterRevenue ?? (promoterRate != null ? FinancialFormatter.calculatePromoterRevenue(calculatedBase, promoterRate!) : 0.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.canvasColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.account_tree_outlined, color: theme.primaryColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Financial Revenue Flow Standard',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: theme.canvasColor,
                      ),
                    ),
                    Text(
                      'Complete traceable flow from customer collection to net payouts (4 decimal precision)',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.canvasColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 850;

              return Column(
                children: [
                  // Step 1: Customer Payment -> GST -> Base
                  _buildStepContainer(
                    theme,
                    title: '1. Customer Payment & Taxes',
                    color: Colors.blue,
                    items: [
                      _FlowItem('Customer Payment', FinancialFormatter.format4(customerPayment), isPrimary: true),
                      _FlowItem('(-) GST 18%', FinancialFormatter.format4(calculatedGst), subtitle: 'Customer Payment - Base Amount'),
                      _FlowItem('(=) Base Amount after GST', FinancialFormatter.format4(calculatedBase), subtitle: 'Customer Payment ÷ 1.18', isBold: true),
                      _FlowItem('(-) Gateway/Platform Fee (2%)', FinancialFormatter.format4(calculatedGateway), subtitle: 'Customer Payment × 2%'),
                      _FlowItem('(=) Net Revenue for Sharing', FinancialFormatter.format4(calculatedNet), subtitle: 'Base Amount - Gateway Fee', isHighlight: true),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Icon(Icons.arrow_downward, size: 20, color: Colors.grey),
                  const SizedBox(height: 12),
                  // Step 2: Distribution Split (30% vs 70%) + Promoter
                  isNarrow
                      ? Column(
                          children: [
                            _buildPlatformCard(theme, calculatedNet, calculatedPlatform),
                            const SizedBox(height: 12),
                            _buildProductionHouseCard(theme, calculatedProdGross, calculatedTds, calculatedPayout, calculatedFinalProd),
                            const SizedBox(height: 12),
                            _buildPromoterCard(theme, calculatedBase, calculatedPromoter, promoterRate),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildPlatformCard(theme, calculatedNet, calculatedPlatform)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildProductionHouseCard(theme, calculatedProdGross, calculatedTds, calculatedPayout, calculatedFinalProd)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildPromoterCard(theme, calculatedBase, calculatedPromoter, promoterRate)),
                          ],
                        ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformCard(ThemeData theme, double netRev, double platformRev) {
    return _buildStepContainer(
      theme,
      title: '2A. Platform Share (30%)',
      color: Colors.indigo,
      items: [
        _FlowItem('Net Revenue', FinancialFormatter.format4(netRev)),
        _FlowItem('Platform Share %', '30.00%'),
        _FlowItem('Final Platform Revenue', FinancialFormatter.format4(platformRev), isHighlight: true, isBold: true),
      ],
    );
  }

  Widget _buildProductionHouseCard(
    ThemeData theme,
    double prodGross,
    double tds,
    double payoutFee,
    double finalProd,
  ) {
    return _buildStepContainer(
      theme,
      title: '2B. Production House (70%)',
      color: Colors.pink,
      items: [
        _FlowItem('Gross Production Share (70%)', FinancialFormatter.format4(prodGross)),
        _FlowItem('(-) TDS Deduction (10%)', FinancialFormatter.format4(tds), subtitle: 'Gross Share × 10%'),
        _FlowItem('(-) Payout Fee (2%)', FinancialFormatter.format4(payoutFee), subtitle: 'Gross Share × 2%'),
        _FlowItem('(=) Final Production Revenue', FinancialFormatter.format4(finalProd), isHighlight: true, isBold: true),
      ],
    );
  }

  Widget _buildPromoterCard(
    ThemeData theme,
    double baseAmt,
    double promoterRev,
    double? rate,
  ) {
    return _buildStepContainer(
      theme,
      title: '2C. Promoter Incentive (Separate)',
      color: Colors.cyan,
      items: [
        _FlowItem('Base Amount Base', FinancialFormatter.format4(baseAmt)),
        _FlowItem('Applicable Rate', rate != null ? FinancialFormatter.formatPercent(rate * 100) : 'Tier-based (1% - 3%)'),
        _FlowItem('Promoter Earnings', FinancialFormatter.format4(promoterRev), subtitle: 'Base Amount × Rate (Excluded from Total Revenue)', isHighlight: true, isBold: true),
      ],
    );
  }

  Widget _buildStepContainer(
    ThemeData theme, {
    required String title,
    required Color color,
    required List<_FlowItem> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final item in items) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: item.isBold ? FontWeight.w800 : FontWeight.w500,
                            color: item.isHighlight ? color : theme.canvasColor,
                          ),
                        ),
                        if (item.subtitle != null)
                          Text(
                            item.subtitle!,
                            style: TextStyle(fontSize: 10, color: theme.canvasColor.withValues(alpha: 0.5)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.value,
                    style: TextStyle(
                      fontSize: item.isHighlight ? 13 : 12,
                      fontWeight: (item.isBold || item.isHighlight) ? FontWeight.w800 : FontWeight.w600,
                      color: item.isHighlight ? color : (item.isPrimary ? theme.primaryColor : theme.canvasColor),
                    ),
                  ),
                ],
              ),
            ),
            if (item != items.last) Divider(height: 8, color: theme.canvasColor.withValues(alpha: 0.06)),
          ],
        ],
      ),
    );
  }
}

class _FlowItem {
  final String label;
  final String value;
  final String? subtitle;
  final bool isPrimary;
  final bool isHighlight;
  final bool isBold;

  _FlowItem(
    this.label,
    this.value, {
    this.subtitle,
    this.isPrimary = false,
    this.isHighlight = false,
    this.isBold = false,
  });
}
