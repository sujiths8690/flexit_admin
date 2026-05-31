import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/utils/utils.dart';
import '../../providers/admin_auth/admin_auth_provider.dart';
import '../../widgets/common/common_widgets.dart';

class IncomeScreen extends ConsumerStatefulWidget {
  const IncomeScreen({super.key});

  @override
  ConsumerState<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends ConsumerState<IncomeScreen> {
  final _searchCtrl = TextEditingController();
  String _filter = 'All';
  List<PaymentRecord> _payments = [];
  List<PaymentRecord> _filtered = [];
  bool _isLoading = true;
  final _filters = ['All', 'Success', 'Failed', 'Pending', 'Refunded'];

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_applyFilter);
    _loadTransactions();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _payments.where((p) {
        final matchQ = q.isEmpty ||
            p.transactionId.toLowerCase().contains(q) ||
            p.customerName.toLowerCase().contains(q) ||
            p.customerId.toLowerCase().contains(q) ||
            p.businessName.toLowerCase().contains(q);
        final matchF =
            _filter == 'All' || p.status.toLowerCase() == _filter.toLowerCase();
        return matchQ && matchF;
      }).toList();
    });
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);

    try {
      final overview =
          await ref.read(adminAuthServiceProvider).fetchRevenueOverview();
      if (!mounted) return;
      setState(() {
        _payments = overview.transactions;
        _isLoading = false;
      });
      _applyFilter();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _payments = const [];
        _filtered = const [];
        _isLoading = false;
      });
    }
  }

  void _setFilter(String f) {
    setState(() => _filter = f);
    _applyFilter();
  }

  double get _totalFiltered => _filtered
      .where((p) => p.status == 'success')
      .fold(0.0, (sum, p) => sum + p.amount);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Income'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(118),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                FxSearchBar(
                    hint: 'Search by customer, transaction ID, business...',
                    controller: _searchCtrl),
                const SizedBox(height: 10),
                FxFilterChips(
                    options: _filters,
                    selected: _filter,
                    onChanged: _setFilter),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Summary Row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.incomeGrad1, AppColors.incomeGrad2],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.currency_rupee_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${AppUtils.formatCurrency(_totalFiltered)} in filtered results',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14),
                    ),
                  ),
                  Text(
                    '${_filtered.length} transactions',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? const FxEmptyState(
                        icon: Icons.receipt_long_rounded,
                        title: 'No transactions found',
                        subtitle: 'Try adjusting your search or filter',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _PaymentTile(
                          payment: _filtered[i],
                          isDark: isDark,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PaymentDetailScreen(payment: _filtered[i]),
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final PaymentRecord payment;
  final bool isDark;
  final VoidCallback onTap;

  const _PaymentTile(
      {required this.payment, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = payment;
    return FxCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppUtils.statusBg(p.status),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(AppUtils.paymentMethodIcon(p.method),
                size: 22, color: AppUtils.statusColor(p.status)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.customerName,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimary
                            : AppColors.textDark)),
                Text(p.businessName,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(AppUtils.timeAgo(p.date),
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${p.amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: p.status == 'failed' || p.status == 'refunded'
                      ? AppUtils.statusColor(p.status)
                      : (isDark ? AppColors.textPrimary : AppColors.textDark),
                ),
              ),
              const SizedBox(height: 4),
              StatusBadge(p.status),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Payment Detail Screen ────────────────────────────────────────────────────

class PaymentDetailScreen extends StatelessWidget {
  final PaymentRecord payment;
  const PaymentDetailScreen({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = payment;

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          // Amount Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppUtils.statusColor(p.status).withOpacity(0.15),
                  AppUtils.statusColor(p.status).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppUtils.statusColor(p.status).withOpacity(0.25)),
            ),
            child: Column(
              children: [
                Icon(AppUtils.paymentMethodIcon(p.method),
                    size: 36, color: AppUtils.statusColor(p.status)),
                const SizedBox(height: 12),
                Text(
                  '₹${p.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                    color: isDark ? AppColors.textPrimary : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                StatusBadge(p.status),
                const SizedBox(height: 8),
                Text(AppUtils.formatDateTime(p.date),
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FxDetailSection(
            title: 'Transaction Info',
            children: [
              InfoRow(label: 'Transaction ID', value: p.transactionId),
              InfoRow(label: 'Invoice ID', value: p.invoiceId),
              InfoRow(
                  label: 'Amount',
                  value: '${p.currency} ${p.amount.toStringAsFixed(2)}'),
              InfoRow(
                  label: 'Status', value: '', trailing: StatusBadge(p.status)),
              InfoRow(label: 'Method', value: p.method.toUpperCase()),
              if (p.cardLast4 != null)
                InfoRow(label: 'Card', value: '•••• •••• •••• ${p.cardLast4}'),
              if (p.bankName != null)
                InfoRow(label: 'Bank', value: p.bankName!),
            ],
          ),
          const SizedBox(height: 16),
          FxDetailSection(
            title: 'Customer Info',
            children: [
              InfoRow(label: 'Name', value: p.customerName),
              InfoRow(label: 'Customer ID', value: p.customerId),
              InfoRow(label: 'Business', value: p.businessName),
              InfoRow(label: 'Plan', value: p.plan),
            ],
          ),
          const SizedBox(height: 16),
          FxDetailSection(
            title: 'Description',
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child:
                    Text(p.description, style: const TextStyle(fontSize: 13)),
              ),
            ],
          ),
          if (p.extraDetails.isNotEmpty) ...[
            const SizedBox(height: 16),
            FxDetailSection(
              title: 'All Details',
              children: p.extraDetails.entries
                  .map((entry) => InfoRow(label: entry.key, value: entry.value))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
