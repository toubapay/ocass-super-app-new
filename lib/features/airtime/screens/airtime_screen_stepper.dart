import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/not_logged_in_screen.dart';
import 'package:sixam_mart/common/widgets/wallet_action_icon.dart';
import 'package:sixam_mart/features/airtime/controllers/airtime_controller.dart';
import 'package:sixam_mart/features/airtime/domain/models/airtime_model.dart';
import 'package:sixam_mart/features/airtime/screens/airtime_success_screen.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/wallet/widgets/add_fund_dialogue_widget.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/images.dart';

class AirtimeScreenStepper extends StatefulWidget {
  const AirtimeScreenStepper({super.key});

  @override
  State<AirtimeScreenStepper> createState() => _AirtimeScreenStepperState();
}

class _AirtimeScreenStepperState extends State<AirtimeScreenStepper> {
  int _currentStep = 0;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _customAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<AirtimeController>().requestContactsAndLoad();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _customAmountController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    if (!isLoggedIn) {
      return NotLoggedInScreen(callBack: (value) {
        setState(() {});
      });
    }
    return GetBuilder<AirtimeController>(builder: (ctrl) {
      if (ctrl.transactionSuccess && ctrl.lastTransaction != null) {
        return AirtimeSuccessScreen(
          response: ctrl.lastTransaction!,
          operator: ctrl.selectedOperator,
        );
      }
      return Scaffold(
        backgroundColor: const Color(0xFFF0F4FF),
        body: Stack(
          children: [
            // Gradient header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 200,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF06402B), Color(0xFF00AA13)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(36),
                    bottomRight: Radius.circular(36),
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Header
                  _buildHeader(),
                  const SizedBox(height: 20),

                  // Progress Stepper
                  _buildProgressStepper(),
                  const SizedBox(height: 24),

                  // Step Content
                  Expanded(
                    child: _buildStepContent(ctrl),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (_currentStep > 0) {
                _previousStep();
              } else {
                Get.back();
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const Spacer(),
          Text('airtime_top_up'.tr,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildProgressStepper() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildStepIndicator(0, 'Provider', Icons.cell_tower_rounded),
          _buildStepLine(0),
          _buildStepIndicator(1, 'Number', Icons.phone_rounded),
          _buildStepLine(1),
          _buildStepIndicator(
            2,
            'Amount',
            Icons.attach_money_rounded,
            custom: Center(child: Text('🪙', style: TextStyle(fontSize: 20))),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, IconData icon,
      {Widget? custom}) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;

    return Expanded(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isActive || isCompleted
                  ? Colors.white
                  : Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: custom != null
                ? custom
                : Icon(
                    isCompleted ? Icons.check_rounded : icon,
                    color: isActive || isCompleted
                        ? const Color(0xFF00AA13)
                        : Colors.white,
                    size: 24,
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive || isCompleted
                  ? Colors.white
                  : Colors.white.withOpacity(0.6),
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(int step) {
    final isCompleted = _currentStep > step;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 30),
        decoration: BoxDecoration(
          color: isCompleted ? Colors.white : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildStepContent(AirtimeController ctrl) {
    switch (_currentStep) {
      case 0:
        return _buildStep1ProviderSelection(ctrl);
      case 1:
        return _buildStep2NumberSelection(ctrl);
      case 2:
        return _buildStep3AmountAndPayment(ctrl);
      default:
        return const SizedBox();
    }
  }

  // ═══════════════════════════════════════════════════════════
  // STEP 1: PROVIDER SELECTION
  // ═══════════════════════════════════════════════════════════

  Widget _buildStep1ProviderSelection(AirtimeController ctrl) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF0F4FF),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('select_your_provider'.tr,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E1B4B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'choose_the_mobile_operator_for_your_top_up'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Operator Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1,
                    ),
                    itemCount: kAirtimeOperators.length,
                    itemBuilder: (context, index) {
                      final op = kAirtimeOperators[index];
                      final selected = ctrl.selectedOperator?.code == op.code;
                      return GestureDetector(
                        onTap: () {
                          ctrl.selectOperator(op);
                          _nextStep();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF00AA13)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF00AA13)
                                  : Colors.grey.shade200,
                              width: 2,
                            ),
                            boxShadow: selected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF00AA13)
                                          .withOpacity(0.3),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    )
                                  ]
                                : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  'assets/image/${op.logo}',
                                  height: 60,
                                  width: 60,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Text(
                                    op.flag,
                                    style: const TextStyle(fontSize: 38),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                op.name,
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : const Color(0xFF1E1B4B),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                op.country,
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white70
                                      : Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Next Button
          _buildBottomButton(
            label: 'Continue',
            icon: Icons.arrow_forward_rounded,
            enabled: ctrl.selectedOperator != null,
            onPressed: () {
              HapticFeedback.lightImpact();
              _nextStep();
            },
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // STEP 2: NUMBER SELECTION
  // ═══════════════════════════════════════════════════════════

  Widget _buildStep2NumberSelection(AirtimeController ctrl) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF0F4FF),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('enter_phone_number'.tr,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E1B4B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'search_a_contact_or_enter_manually'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Unified input
                  _buildManualPhoneInput(ctrl),
                  const SizedBox(height: 20),

                  // Contact selection content
                  _buildContactSelection(ctrl),
                ],
              ),
            ),
          ),

          // Next Button
          _buildBottomButton(
            label: 'Continue',
            icon: Icons.arrow_forward_rounded,
            enabled: ctrl.effectivePhone.length >= 8,
            onPressed: () {
              HapticFeedback.lightImpact();
              _nextStep();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildManualPhoneInput(AirtimeController ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: ctrl.setManualPhone,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E1B4B),
        ),
        decoration: InputDecoration(
          hintText: '${'eg'.tr} 772345678',
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(
            Icons.phone_rounded,
            color: Color(0xFF00AA13),
            size: 24,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildContactSelection(AirtimeController ctrl) {
    if (!ctrl.contactsPermissionGranted && !ctrl.contactsLoaded) {
      return _buildPermissionCard(ctrl);
    }

    return Column(
      children: [
        // Selected contact indicator
        if (ctrl.selectedContact != null) ...[
          _buildSelectedContactCard(ctrl),
          const SizedBox(height: 16),
        ],

        // Contact list
        if (ctrl.selectedContact == null) ...[
          if (ctrl.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: Color(0xFF00AA13)),
              ),
            )
          else if (ctrl.filteredContacts.isEmpty && ctrl.manualPhone.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.person_off_rounded,
                        size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text(
                      'no_contacts_found'.tr,
                      style:
                          TextStyle(color: Colors.grey.shade500, fontSize: 16),
                    ),
                  ],
                ),
              ),
            )
          else if (ctrl.filteredContacts.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 400),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: ctrl.filteredContacts.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: Colors.grey.shade100,
                  indent: 72,
                ),
                itemBuilder: (context, index) {
                  final contact = ctrl.filteredContacts[index];
                  final initial = contact.displayName.isNotEmpty
                      ? contact.displayName[0].toUpperCase()
                      : '?';
                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: _avatarColor(initial),
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    title: Text(
                      contact.displayName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                    subtitle: contact.phones.isNotEmpty
                        ? Text(
                            contact.phones.first.number,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          )
                        : null,
                    onTap: () {
                      ctrl.selectContact(contact);
                      _phoneController
                          .clear(); // Clear unified input if contact selected
                    },
                  );
                },
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildSelectedContactCard(AirtimeController ctrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF00AA13),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00AA13).withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              ctrl.selectedContact!.displayName.isNotEmpty
                  ? ctrl.selectedContact!.displayName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ctrl.selectedContact!.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                if (ctrl.selectedContact!.phones.isNotEmpty)
                  Text(
                    ctrl.selectedContact!.phones.first.number,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: ctrl.clearSelectedContact,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _avatarColor(String letter) {
    const colors = [
      Color(0xFF00AA13),
      Color(0xFF059669),
      Color(0xFFD97706),
      Color(0xFFDC2626),
      Color(0xFF7C3AED),
      Color(0xFF0891B2),
    ];
    return colors[letter.codeUnitAt(0) % colors.length];
  }

  Widget _buildPermissionCard(AirtimeController ctrl) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF00AA13).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.contacts_rounded,
              size: 56,
              color: Color(0xFF00AA13),
            ),
          ),
          const SizedBox(height: 20),
          Text('access_your_contacts'.tr,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: Color(0xFF1E1B4B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'allow_contacts_access_to_quickly_select_a_recipient'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: ctrl.requestContactsAndLoad,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00AA13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              child: Text('grant_permission'.tr,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // STEP 3: AMOUNT & PAYMENT
  // ═══════════════════════════════════════════════════════════

  Widget _buildStep3AmountAndPayment(AirtimeController ctrl) {
    print(ctrl.effectiveAmount.isNotEmpty);
    print(ctrl.effectivePhone.isNotEmpty);
    print(ctrl.selectedOperator);
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF0F4FF),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('select_amount'.tr,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E1B4B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'choose_a_plan_or_enter_custom_amount'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Wallet Balance Card
                  _buildWalletBalanceCard(),
                  const SizedBox(height: 24),

                  // Toggle between plans and custom
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: _buildToggleButton(
                  //         label: 'Quick Plans',
                  //         icon: Icons.grid_view_rounded,
                  //         isSelected: !ctrl.useCustomAmount,
                  //         onTap: () => ctrl.toggleCustomAmount(false),
                  //       ),
                  //     ),
                  //     const SizedBox(width: 12),
                  //     Expanded(
                  //       child: _buildToggleButton(
                  //         label: 'Custom',
                  //         icon: Icons.edit_rounded,
                  //         isSelected: ctrl.useCustomAmount,
                  //         onTap: () => ctrl.toggleCustomAmount(true),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 20),

                  // Plans or Custom Input
                  // if (!ctrl.useCustomAmount)
                  //   _buildPlanGrid(ctrl)
                  // else
                  _buildCustomAmountInput(ctrl),
                  const SizedBox(height: 16),

                  // Quick Amount Suggestions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['500', '1000', '2000', '5000'].map((amount) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: InkWell(
                            onTap: () {
                              ctrl.setCustomAmount(amount);
                              _customAmountController.text = amount;
                              HapticFeedback.lightImpact();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: ctrl.customAmount == amount
                                    ? const Color(0xFF00AA13)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: ctrl.customAmount == amount
                                      ? const Color(0xFF00AA13)
                                      : Colors.grey.shade200,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  amount,
                                  style: TextStyle(
                                    color: ctrl.customAmount == amount
                                        ? Colors.white
                                        : const Color(0xFF1E1B4B),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Summary Card
                  if (ctrl.effectiveAmount.isNotEmpty) _buildSummaryCard(ctrl),

                  const SizedBox(height: 16),

                  // Transaction Result
                  if (ctrl.lastTransaction != null && ctrl.transactionSuccess)
                    _buildSuccessCard(ctrl),
                ],
              ),
            ),
          ),

          // Send Button
          if (!ctrl.transactionSuccess)
            _buildBottomButton(
              label: ctrl.isLoading ? 'Processing...' : 'Send AirTime',
              icon: Icons.send_rounded,
              enabled: ctrl.canSend && !ctrl.isLoading,
              onPressed: () async {
                HapticFeedback.mediumImpact();
                await ctrl.sendAirtime();
              },
              isLoading: ctrl.isLoading,
            )
          else
            _buildBottomButton(
              label: 'Send Another',
              icon: Icons.refresh_rounded,
              enabled: true,
              onPressed: () {
                ctrl.resetState();
                setState(() => _currentStep = 0);
                _phoneController.clear();
                _customAmountController.clear();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildWalletBalanceCard() {
    final ScrollController cardScrollController = ScrollController();

    return GetBuilder<ProfileController>(builder: (profileCtrl) {
      final double walletBalance =
          profileCtrl.userInfoModel?.walletBalance ?? 0.0;
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00AA13), Color(0xFF00AA13)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00AA13).withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('wallet_balance'.tr,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    PriceConverter.convertPrice(walletBalance),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            ActionIcon(
              fromAirTime: true,
              // icon: Icons.payment,
              imagePath: Images.plus,
              title: "top_up",
              onTap: () {
                Get.dialog(
                  Dialog(
                      backgroundColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      child: SizedBox(
                        width: 500,
                        child: SingleChildScrollView(
                            controller: cardScrollController,
                            child: AddFundDialogueWidget(
                                cardScrollController: cardScrollController)),
                      )),
                );
              },
            ),
            SizedBox(
              width: 10,
            )
          ],
        ),
      );
    });
  }

  Widget _buildPlanGrid(AirtimeController ctrl) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: kAirtimePlans.length,
      itemBuilder: (context, index) {
        final plan = kAirtimePlans[index];
        final selected = ctrl.selectedPlan?.amount == plan.amount;
        return GestureDetector(
          onTap: () => ctrl.selectPlan(plan),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: selected
                  ? const LinearGradient(
                      colors: [Color(0xFF00AA13), Color(0xFF00AA13)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: selected ? null : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? Colors.transparent : Colors.grey.shade200,
                width: 2,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF00AA13).withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  plan.label,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF1E1B4B),
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                if (plan.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    plan.description!,
                    style: TextStyle(
                      color: selected ? Colors.white70 : Colors.grey.shade500,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomAmountInput(AirtimeController ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _customAmountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: false),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: ctrl.setCustomAmount,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E1B4B),
        ),
        decoration: InputDecoration(
          hintText: 'enter_amount'.tr,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 10, top: 9),
            child: Text('🪙', style: TextStyle(fontSize: 20)),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(AirtimeController ctrl) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00AA13).withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_rounded,
                color: Color(0xFF00AA13),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text('transaction_summary'.tr,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Color(0xFF1E1B4B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _summaryRow(
            Icons.cell_tower_rounded,
            'Provider',
            ctrl.selectedOperator?.name ?? '—',
          ),
          const SizedBox(height: 12),
          _summaryRow(
            Icons.phone_rounded,
            'Number',
            ctrl.effectivePhone.isEmpty ? '—' : ctrl.effectivePhone,
          ),
          const SizedBox(height: 12),
          _summaryRow(
            Icons.attach_money_rounded,
            'Amount',
            ctrl.effectiveAmount.isEmpty ? '—' : '${ctrl.effectiveAmount} XOF',
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF00AA13)),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Color(0xFF1E1B4B),
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessCard(AirtimeController ctrl) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 64,
            ),
          ),
          const SizedBox(height: 20),
          Text('airtime_sent_successfully'.tr,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 22,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'your_top_up_has_been_processed'.tr,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                if (ctrl.lastTransaction != null) ...[
                  _resultRow('Transaction ID',
                      ctrl.lastTransaction!.transactionId ?? '—'),
                  const SizedBox(height: 8),
                  _resultRow('Status', ctrl.lastTransaction!.status ?? '—'),
                  const SizedBox(height: 8),
                  _resultRow(
                      'Amount', '${ctrl.lastTransaction!.montant ?? '—'} XOF'),
                  const SizedBox(height: 8),
                  _resultRow('Phone', ctrl.lastTransaction!.telephone ?? '—'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Colors.white,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BOTTOM BUTTON
  // ═══════════════════════════════════════════════════════════

  Widget _buildBottomButton({
    required String label,
    required IconData icon,
    required bool enabled,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: enabled ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  enabled ? const Color(0xFF00AA13) : Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: enabled ? 8 : 0,
              shadowColor: const Color(0xFF00AA13).withOpacity(0.4),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: Colors.white, size: 22),
                      const SizedBox(width: 12),
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
