import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/not_logged_in_screen.dart';
import 'package:sixam_mart/features/bill_payment/controllers/bill_payment_controller.dart';
import 'package:sixam_mart/features/bill_payment/domain/models/bill_payment_history_model.dart';
import 'package:sixam_mart/features/bill_payment/screens/bill_payment_detail_screen.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/wallet/widgets/add_fund_dialogue_widget.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/route_helper.dart';

class BillPaymentScreen extends StatefulWidget {
  const BillPaymentScreen({super.key});

  @override
  State<BillPaymentScreen> createState() => _BillPaymentScreenState();
}

class _BillPaymentScreenState extends State<BillPaymentScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        // Load history when the tab is first visited
        final ctrl = Get.find<BillPaymentController>();
        if (ctrl.historyList == null) {
          ctrl.loadHistory(reload: true);
        }
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _accountController.dispose();
    _amountController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    if (!isLoggedIn) {
      return NotLoggedInScreen(callBack: (value) {
        setState(() {});
      });
    }

    return GetBuilder<BillPaymentController>(builder: (ctrl) {
      // Sync amount controller with controller state if needed
      if (ctrl.customAmount.isNotEmpty &&
          _amountController.text != ctrl.customAmount) {
        _amountController.text = ctrl.customAmount;
      }
      if (ctrl.accountNumber.isNotEmpty &&
          _accountController.text != ctrl.accountNumber) {
        _accountController.text = ctrl.accountNumber;
      }

      return Scaffold(
        backgroundColor: const Color(0xFFF0F4FF),
        body: Column(
          children: [
            _buildHeader(ctrl),
            _buildTopTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildBody(ctrl),
                  _buildHistoryTab(ctrl),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTopTabBar() {
    const activeColor = Color(0xFF00AA13);
    const inactiveColor = Color(0xFF8A9BB5);
    return Container(
      color: const Color(0xFFF0F4FF),
      child: TabBar(
        controller: _tabController,
        labelColor: activeColor,
        unselectedLabelColor: inactiveColor,
        indicatorColor: activeColor,
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        tabs: const [
          Tab(text: 'Pay Bill'),
          Tab(text: 'History'),
        ],
      ),
    );
  }

  Widget _buildHeader(BillPaymentController ctrl) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF06402B),
            Color(0xFF00AA13),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (ctrl.currentStep == BillPaymentStep.selection) {
                        Get.back();
                      } else if (ctrl.currentStep ==
                          BillPaymentStep.verification) {
                        ctrl.setStep(BillPaymentStep.selection);
                      } else if (ctrl.currentStep == BillPaymentStep.payment) {
                        ctrl.setStep(BillPaymentStep.verification);
                      } else {
                        ctrl.resetState();
                        _accountController.clear();
                        _amountController.clear();
                      }
                    },
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 20),
                    style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.15)),
                  ),
                  Expanded(child: Text('bill_payment'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_rounded,
                        color: Colors.white, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('wallet_balance'.tr,
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                          GetBuilder<ProfileController>(builder: (profileCtrl) {
                            return Text(
                              PriceConverter.convertPrice(
                                  profileCtrl.userInfoModel?.walletBalance ??
                                      0.0),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 22),
                            );
                          }),
                        ],
                      ),
                    ),
                    if (Get.find<SplashController>()
                            .configModel
                            ?.addFundStatus ==
                        true)
                      TextButton(
                        onPressed: () {
                          final ScrollController cardScrollController =
                              ScrollController();
                          Get.dialog(Dialog(
                              child: AddFundDialogueWidget(
                                  cardScrollController: cardScrollController)));
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                        child: Text('top_up'.tr,
                            style: TextStyle(
                                color: Color(0xFF00AA13),
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BillPaymentController ctrl) {
    if (ctrl.isLoading && ctrl.countries.isEmpty) {
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: Color(0xFF00AA13))));
    }

    // Safety: If we're in a step that requires a provider, but none is selected (e.g. after re-entry), reset to selection
    if (ctrl.currentStep != BillPaymentStep.selection &&
        ctrl.selectedProvider == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ctrl.setStep(BillPaymentStep.selection);
      });
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildStepIndicator(ctrl),
          const SizedBox(height: 32),
          if (ctrl.currentStep == BillPaymentStep.selection)
            _buildSelectionStep(ctrl),
          if (ctrl.currentStep == BillPaymentStep.verification &&
              ctrl.selectedProvider != null)
            _buildTabbedDetailsStep(ctrl),
          if (ctrl.currentStep == BillPaymentStep.result)
            _buildResultStep(ctrl),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(BillPaymentController ctrl) {
    const activeColor = Color(0xFF00AA13);
    final inactiveColor = Colors.grey.shade300;

    int currentIdx = ctrl.currentStep.index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(3, (index) {
          bool active = index <= currentIdx;
          if (ctrl.currentStep == BillPaymentStep.result) active = true;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: active ? activeColor : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: active
                        ? [
                            BoxShadow(
                                color: activeColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4))
                          ]
                        : [],
                    border: Border.all(
                        color: active ? activeColor : inactiveColor, width: 2),
                  ),
                  child: Center(
                    child: (index < currentIdx ||
                            ctrl.currentStep == BillPaymentStep.result)
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: active ? Colors.white : inactiveColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                  ),
                ),
                if (index < 2)
                  Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: active ? activeColor : inactiveColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSelectionStep(BillPaymentController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Provider Grid
        Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Text('select_provider'.tr,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E1B4B))),
        ),
        // const SizedBox(height: 20),
        if (ctrl.isLoading && ctrl.providers.isEmpty)
          const Center(
              child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator()))
        else if (ctrl.providers.isEmpty)
          Center(child: Padding(padding: const EdgeInsets.all(40), child: Text('no_providers_found_for_senegal'.tr,
                      style: TextStyle(color: Colors.grey))))
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.0,
              ),
              itemCount: ctrl.providers.length,
              itemBuilder: (context, index) {
                final provider = ctrl.providers[index];
                return GestureDetector(
                  onTap: () => ctrl.selectProvider(provider),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border:
                          Border.all(color: Colors.grey.shade100, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 6))
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade50, Colors.white],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade200, width: 1),
                          ),
                          child: ClipOval(
                            child: provider.imageAsset != null
                                ? Image.asset(
                                    provider.imageAsset!,
                                    fit: BoxFit.cover,
                                    width: 76,
                                    height: 76,
                                  )
                                : Center(
                                    child: Text(provider.flag,
                                        style: const TextStyle(fontSize: 36)),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            provider.name,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: Color(0xFF1E1B4B)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          provider.description ?? 'Utilities',
                          style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 10,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildTabbedDetailsStep(BillPaymentController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader('Details', 'Enter info to proceed with payment',
              () => ctrl.setStep(BillPaymentStep.selection)),
          const SizedBox(height: 24),

          // Provider Info Summary
          _buildProviderSmallCard(ctrl),
          const SizedBox(height: 24),

          // Tab Toggle
          _buildTabToggle(ctrl),
          const SizedBox(height: 24),

          // Tab Content
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: ctrl.selectedTabIndex == 0
                ? _buildFastPaymentTab(ctrl)
                : _buildCheckInvoiceTab(ctrl),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderSmallCard(BillPaymentController ctrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00AA13).withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF00AA13).withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 8))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFFF3F7FF), Colors.blue.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade100, width: 1),
            ),
            child: ClipOval(
              child: ctrl.selectedProvider?.imageAsset != null
                  ? Image.asset(
                      ctrl.selectedProvider!.imageAsset!,
                      fit: BoxFit.cover,
                      width: 60,
                      height: 60,
                    )
                  : Center(
                      child: Text(ctrl.selectedProvider?.flag ?? '🌍',
                          style: const TextStyle(fontSize: 30)),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ctrl.selectedProvider?.name ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        color: Color(0xFF003366))),
                const SizedBox(height: 2),
                Text(ctrl.selectedProvider?.description ?? 'Utilities Service',
                    style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded,
              color: Color(0xFF00AA13), size: 20),
        ],
      ),
    );
  }

  Widget _buildTabToggle(BillPaymentController ctrl) {
    return Column(
      children: [
        Row(
          children: [
            _buildTabItem(ctrl, 0, 'Fast Payment', Icons.flash_on_rounded),
            _buildTabItem(ctrl, 1, 'Check Invoice', Icons.receipt_long_rounded),
          ],
        ),
        Stack(
          children: [
            Container(
              height: 1.5,
              width: double.infinity,
              color: Colors.grey.shade100,
            ),
            AnimatedAlign(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              alignment: ctrl.selectedTabIndex == 0
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00AA13),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabItem(
      BillPaymentController ctrl, int index, String label, IconData icon) {
    bool isSelected = ctrl.selectedTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          ctrl.setTabIndex(index);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 20,
                  color: isSelected
                      ? const Color(0xFF00AA13)
                      : Colors.grey.shade400),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF003366)
                      : Colors.grey.shade500,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFastPaymentTab(BillPaymentController ctrl) {
    return Column(
      key: const ValueKey(0),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 25,
                  offset: const Offset(0, 10))
            ],
          ),
          child: Column(
            children: [
              _buildInputField(
                controller: _accountController,
                hint: 'Meter or Account Number',
                label: 'Account Number',
                icon: Icons.numbers_rounded,
                onChanged: ctrl.setAccountNumber,
              ),
              const SizedBox(height: 20),
              _buildInputField(
                controller: _amountController,
                hint: 'Enter Amount',
                label: 'Amount to Pay',
                icon: '🪙',
                onChanged: ctrl.setAmount,
              ),
              _buildAmountBoundsHint(ctrl),
              if (ctrl.customAmount.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildFeeBreakdown(ctrl),
              ],
              const SizedBox(height: 24),
              _buildActionButton(
                onPressed: ctrl.canSend ? ctrl.processPayment : null,
                isLoading: ctrl.isLoading,
                text: 'Confirm Payment',
                icon: Icons.lock_rounded,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCheckInvoiceTab(BillPaymentController ctrl) {
    final invoice = ctrl.verifiedInvoice;
    return Column(
      key: const ValueKey(1),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 25,
                  offset: const Offset(0, 10))
            ],
          ),
          child: Column(
            children: [
              _buildInputField(
                controller: _accountController,
                hint: 'Meter or Account Number',
                label: 'Account Number',
                icon: Icons.numbers_rounded,
                onChanged: ctrl.setAccountNumber,
              ),
              const SizedBox(height: 24),
              if (invoice == null)
                _buildActionButton(
                  onPressed: ctrl.canCheckInvoice ? ctrl.checkInvoice : null,
                  isLoading: ctrl.isCheckingInvoice,
                  text: 'Fetch Invoice',
                  icon: Icons.search_rounded,
                )
              else ...[
                _buildInvoiceDetailsCard(ctrl),
                const SizedBox(height: 16),
                _buildFeeBreakdown(ctrl),
                const SizedBox(height: 24),
                _buildActionButton(
                  onPressed: ctrl.canSend ? ctrl.processPayment : null,
                  isLoading: ctrl.isLoading,
                  text: 'Confirm Payment',
                  icon: Icons.lock_rounded,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeeBreakdown(BillPaymentController ctrl) {
    final double billAmount = double.tryParse(ctrl.customAmount) ?? 0;
    if (billAmount <= 0) return const SizedBox.shrink();

    final double platformFee = ctrl.calcCommission(billAmount);
    final double providerFee = ctrl.calcProviderFee(billAmount);
    final String currency = ctrl.verifiedInvoice?.currency ?? 'XOF';
    final double total = billAmount + platformFee + providerFee;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F7FF),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: const Color(0xFF0066CC).withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          _feeRow('bill_payment'.tr, '${billAmount.toStringAsFixed(0)} $currency'),
          if (providerFee > 0)
            _feeRow(
                'Provider Fee (${ctrl.providerFeeLabel})',
                '${providerFee.toStringAsFixed(0)} $currency',
                valueColor: Colors.orange.shade700),
          _feeRow(
              'Platform Fee (${ctrl.commissionLabel})',
              '${platformFee.toStringAsFixed(0)} $currency',
              valueColor: Colors.deepPurple),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: Color(0xFFDEE8F5)),
          ),
          _feeRow(
            'Total Payable',
            '${total.toStringAsFixed(0)} $currency',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _feeRow(String label, String value,
      {Color? valueColor, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 14 : 13,
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
              color: isTotal ? const Color(0xFF003366) : Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 15 : 13,
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700,
              color: isTotal
                  ? const Color(0xFF00AA13)
                  : (valueColor ?? const Color(0xFF1E1B4B)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceDetailsCard(BillPaymentController ctrl) {
    final invoice = ctrl.verifiedInvoice;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F7FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF00AA13).withOpacity(0.12)),
        image: DecorationImage(
          image: const AssetImage(
              'assets/image/mask.png'), // Subtle texture if available
          opacity: 0.05,
          alignment: Alignment.bottomRight,
          fit: BoxFit.scaleDown,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('outstanding_balance'.tr,
                      style: TextStyle(
                          color: const Color(0xFF00AA13),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2)),
                  const SizedBox(height: 4),
                  Text(
                    '${invoice?.total ?? '0'} ${invoice?.currency ?? 'XOF'}',
                    style: const TextStyle(
                        color: Color(0xFF003366),
                        fontSize: 24,
                        fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('unpaid'.tr,
                    style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w900,
                        fontSize: 10)),
              ),
            ],
          ),
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(height: 1, color: Color(0xFFDEE8F5))),
          _summaryRow('Owner', invoice?.customerName ?? 'N/A', isBold: true),
          const SizedBox(height: 12),
          _summaryRow('Due Date', invoice?.dueDate ?? 'N/A', isSmall: true),
          const SizedBox(height: 12),
          _summaryRow('Invoice ref', invoice?.invoiceNumber ?? 'N/A',
              isSmall: true),
          if (invoice?.minAmount != null || invoice?.maxAmount != null) ...[
            const SizedBox(height: 12),
            _buildAmountBoundsHint(ctrl),
          ],
        ],
      ),
    );
  }

  Widget _buildAmountBoundsHint(BillPaymentController ctrl) {
    final min = ctrl.verifiedInvoice?.minAmount;
    final max = ctrl.verifiedInvoice?.maxAmount;
    if (min == null && max == null) return const SizedBox.shrink();

    String _fmt(String v) {
      final d = double.tryParse(v);
      if (d == null) return v;
      return d.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+$)'),
            (m) => '${m[1]},',
          );
    }

    String rangeText;
    if (min != null && max != null) {
      rangeText = '${_fmt(min)} – ${_fmt(max)} XOF';
    } else if (min != null) {
      rangeText = 'Min: ${_fmt(min)} XOF';
    } else {
      rangeText = 'Max: ${_fmt(max!)} XOF';
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 14, color: Color(0xFF00AA13)),
          const SizedBox(width: 6),
          Text(
            'Allowed range: $rangeText',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF00AA13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultStep(BillPaymentController ctrl) {
    bool isSuccess = ctrl.transactionSuccess;
    final tx = ctrl.lastTransaction;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(36),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 30,
                    offset: const Offset(0, 10))
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isSuccess
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSuccess
                        ? Icons.verified_rounded
                        : Icons.build_circle_outlined,
                    color: isSuccess ? Colors.green : Colors.orange.shade700,
                    size: 72,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  isSuccess ? 'Payment Successful!' : 'Service Unavailable',
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E1B4B)),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    isSuccess
                        ? 'Your bill has been settled successfully. You can download the receipt in history.'
                        : 'There is an issue on our side and we are working to fix it. Please try again later.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.5),
                  ),
                ),
                if (isSuccess) ...[
                  const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Divider(height: 1)),
                  // Vend code / token — shown prominently when present
                  if (tx?.token != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF06402B),
                            Color(0xFF00AA13),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text('vend_code'.tr,
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5)),
                          const SizedBox(height: 8),
                          Text(tx!.token!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2)),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: tx.token!));
                              Get.snackbar(
                                  'copied'.tr, 'vend_code_copied_to_clipboard'.tr,
                                  snackPosition: SnackPosition.BOTTOM,
                                  duration: const Duration(seconds: 2));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.4)),
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.copy_rounded, color: Colors.white, size: 14), const SizedBox(width: 6), Text('copy_code'.tr,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  _resultRow('Transaction ID', tx?.transactionId ?? 'N/A'),
                  _resultRow('Bill Amount',
                      '${tx?.amount ?? ctrl.customAmount} ${tx?.currency ?? 'XOF'}'),
                  if ((double.tryParse(tx?.fees ?? '') ?? 0) > 0)
                    _resultRow(
                        'Provider Fee', '${tx!.fees} ${tx.currency ?? 'XOF'}'),
                  if (tx?.serviceCommission != null)
                    _resultRow('Platform Fee',
                        '${tx!.serviceCommission} ${tx.currency ?? 'XOF'}'),
                  _resultRow('Total Deducted',
                      '${tx?.totalDeducted ?? tx?.total ?? ctrl.customAmount} ${tx?.currency ?? 'XOF'}'),
                  _resultRow('Account Number',
                      tx?.accountNumber ?? ctrl.accountNumber),
                  _resultRow('Date & Time', tx?.dateTime ?? 'Just now'),
                ],
                const SizedBox(height: 40),
                _buildActionButton(
                  onPressed: () {
                    ctrl.resetState();
                    _accountController.clear();
                    _amountController.clear();
                  },
                  text: 'Back to Start',
                  icon: Icons.home_rounded,
                ),
                if (isSuccess) ...[
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: ctrl.checkStatus,
                    icon: ctrl.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.sync_rounded, size: 20),
                    label: Text('refresh_status'.tr,
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 14)),
                    style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF00AA13)),
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          Get.toNamed(RouteHelper.getConversationRoute()),
                      icon: const Icon(Icons.support_agent_rounded, size: 20),
                      label: Text('contact_support'.tr,
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 15)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF00AA13),
                        side: const BorderSide(
                            color: Color(0xFF00AA13), width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widgets
  Widget _buildStepHeader(String title, String subtitle, VoidCallback onBack) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
            ),
            child: const Icon(Icons.chevron_left_rounded,
                size: 24, color: Color(0xFF00AA13)),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E1B4B))),
              Text(subtitle,
                  style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required String label,
    required dynamic icon,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E1B4B))),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: const Color(0xFF00AA13).withOpacity(0.08), width: 1.5),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Color(0xFF003366)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
              prefixIcon: Container(
                width: 40,
                alignment: Alignment.center,
                child: icon is IconData
                    ? Icon(icon, color: const Color(0xFF00AA13), size: 20)
                    : Text(icon.toString(),
                        style: const TextStyle(fontSize: 18)),
              ),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onPressed,
    required String text,
    IconData? icon,
    bool isLoading = false,
  }) {
    final bool isEnabled = onPressed != null && !isLoading;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isEnabled ? const Color(0xFF00AA13) : Colors.grey.shade300,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: isEnabled ? 6 : 0,
          shadowColor: const Color(0xFF00AA13).withOpacity(0.4),
        ),
        child: isLoading
            ? const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 3))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 22),
                    const SizedBox(width: 12)
                  ],
                  Text(text,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5)),
                ],
              ),
      ),
    );
  }

  Widget _invoiceInfoRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white60, size: 16),
                const SizedBox(width: 8)
              ],
              Text(label,
                  style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14)),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value,
      {bool isBold = false, bool isSmall = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              color: isBold ? const Color(0xFF1E1B4B) : Colors.grey.shade600,
              fontSize: isSmall ? 12 : (isBold ? 15 : 15),
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
            )),
        Text(value,
            style: TextStyle(
              color: isSmall ? Colors.grey.shade700 : const Color(0xFF1E1B4B),
              fontSize: isSmall ? 12 : (isBold ? 18 : 15),
              fontWeight: isBold
                  ? FontWeight.w900
                  : (isSmall ? FontWeight.w600 : FontWeight.w800),
            )),
      ],
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          Text(value,
              style: const TextStyle(
                  color: Color(0xFF1E1B4B),
                  fontWeight: FontWeight.w800,
                  fontSize: 14)),
        ],
      ),
    );
  }

  // ── HISTORY TAB ────────────────────────────────────────────────────

  Widget _buildHistoryTab(BillPaymentController ctrl) {
    if (ctrl.isHistoryLoading && ctrl.historyList == null) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF00AA13)));
    }

    final list = ctrl.historyList;

    if (list == null || list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('no_bill_payments_yet'.tr,
                style: TextStyle(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                    fontSize: 15)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ctrl.loadHistory(reload: true),
              child: Text('refresh'.tr,
                  style: TextStyle(color: Color(0xFF00AA13))),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF00AA13),
      onRefresh: () => ctrl.loadHistory(reload: true),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: list.length + (ctrl.hasMoreHistory ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == list.length) {
            // Load-more trigger
            if (!ctrl.isHistoryLoading) ctrl.loadHistory();
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Color(0xFF00AA13))),
            );
          }
          return _buildHistoryItem(list[index]);
        },
      ),
    );
  }

  Widget _buildHistoryItem(BillPaymentRecord record) {
    Color statusColor;
    IconData statusIcon;
    String statusLabel;

    if (record.isSuccess) {
      statusColor = const Color(0xFF00AA13);
      statusIcon = Icons.check_circle_rounded;
      statusLabel = 'Success';
    } else if (record.isFailed) {
      statusColor = Colors.red;
      statusIcon = Icons.cancel_rounded;
      statusLabel = 'Failed';
    } else {
      statusColor = Colors.orange;
      statusIcon = Icons.hourglass_top_rounded;
      statusLabel = 'Pending';
    }

    final dateStr = record.createdAt != null
        ? '${record.createdAt!.day}/${record.createdAt!.month}/${record.createdAt!.year}  '
            '${record.createdAt!.hour.toString().padLeft(2, '0')}:'
            '${record.createdAt!.minute.toString().padLeft(2, '0')}'
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Get.to(
            () => BillPaymentDetailScreen(initialRecord: record),
            transition: Transition.rightToLeft,
            duration: const Duration(milliseconds: 280),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(record.provider ?? 'bill_payment'.tr,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: Color(0xFF1E1B4B))),
                      const SizedBox(height: 2),
                      Text('A/C: ${record.accountNumber ?? '—'}',
                          style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                      if (record.lamToken != null) ...[
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: record.lamToken!));
                            Get.snackbar('Copied', 'Vend code copied',
                                snackPosition: SnackPosition.BOTTOM,
                                duration: const Duration(seconds: 2));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00AA13)
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.bolt_rounded,
                                    size: 12, color: Color(0xFF00AA13)),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    record.lamToken!,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF00AA13)),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.copy_rounded,
                                    size: 11, color: Color(0xFF00AA13)),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (dateStr.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(dateStr,
                            style: TextStyle(
                                color: Colors.grey.shade400, fontSize: 11)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${record.amount?.toStringAsFixed(0) ?? '—'} ${record.currency ?? 'XOF'}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: Color(0xFF003366)),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(statusLabel,
                          style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded,
                    color: Colors.grey.shade300, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
