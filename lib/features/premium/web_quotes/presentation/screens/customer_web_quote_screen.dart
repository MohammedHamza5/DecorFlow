import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/web_quote.dart';
import 'package:stream_pay/core/responsive/app_responsive.dart';
import 'package:stream_pay/core/responsive/constrained_body.dart';

/// This screen is designed to be accessed via Flutter Web.
/// It displays the interactive quote to the customer.
class CustomerWebQuoteScreen extends ConsumerStatefulWidget {
  final WebQuote webQuote;

  const CustomerWebQuoteScreen({super.key, required this.webQuote});

  @override
  ConsumerState<CustomerWebQuoteScreen> createState() => _CustomerWebQuoteScreenState();
}

class _CustomerWebQuoteScreenState extends ConsumerState<CustomerWebQuoteScreen> {
  // Temporary mock data for quantities and add-ons
  final Map<String, int> _itemQuantities = {
    'بديل خشب VR-101': 10,
    'بديل رخام M-50': 2,
  };
  
  final Map<String, double> _itemPrices = {
    'بديل خشب VR-101': 150.0,
    'بديل رخام M-50': 450.0,
  };

  final Map<String, bool> _addons = {
    'سيليكون لاصق (كرتونة)': true,
    'شريط ليد مخفي': false,
  };

  final Map<String, double> _addonPrices = {
    'سيليكون لاصق (كرتونة)': 120.0,
    'شريط ليد مخفي': 80.0,
  };

  final TextEditingController _notesController = TextEditingController();

  double _calculateTotal() {
    double total = 0;
    _itemQuantities.forEach((key, qty) {
      total += qty * (_itemPrices[key] ?? 0);
    });
    _addons.forEach((key, isSelected) {
      if (isSelected) {
        total += _addonPrices[key] ?? 0;
      }
    });
    return total;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A stunning design for the web customer

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('عرض سعر تفاعلي'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: ConstrainedBody(
        maxWidth: 800,
        child: Container(
          margin: EdgeInsets.all(context.isMobile ? 16.0 : 32.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 24,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(24.0),
                    children: [
                      const Text(
                        'المنتجات المطلوبة',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ..._itemQuantities.keys.map((item) => _buildItemRow(item)),
                      const Divider(height: 48),
                      const Text(
                        'إضافات مساعدة (اختياري)',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ..._addons.keys.map((addon) => _buildAddonRow(addon)),
                      const Divider(height: 48),
                      const Text(
                        'ملاحظات إضافية',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'اكتب ملاحظاتك هنا... (مثال: أرجو التوصيل بعد العصر)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withValues(alpha: 0.8)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'متجر الديكور الحديث',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'عرض سعر مخصص لطلبك',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'صالح لمدة 3 أيام',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(String itemName) {
    final qty = _itemQuantities[itemName]!;
    final price = _itemPrices[itemName]!;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(itemName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${price.toStringAsFixed(2)} ج.م / للوحدة', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
          if (widget.webQuote.allowCustomization)
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.red,
                  onPressed: () {
                    if (qty > 1) {
                      setState(() => _itemQuantities[itemName] = qty - 1);
                    }
                  },
                ),
                Text('$qty', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: Colors.green,
                  onPressed: () {
                    setState(() => _itemQuantities[itemName] = qty + 1);
                  },
                ),
              ],
            )
          else
            Text('الكمية: $qty', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
          SizedBox(
            width: 80,
            child: Text(
              '${(price * qty).toStringAsFixed(2)} ج',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddonRow(String addonName) {
    final isSelected = _addons[addonName]!;
    final price = _addonPrices[addonName]!;

    return CheckboxListTile(
      value: isSelected,
      onChanged: widget.webQuote.allowCustomization
          ? (val) {
              if (val != null) setState(() => _addons[addonName] = val);
            }
          : null,
      title: Text(addonName),
      subtitle: Text('+${price.toStringAsFixed(2)} ج.م'),
      activeColor: Theme.of(context).primaryColor,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _buildFooter() {
    final total = _calculateTotal();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('الإجمالي المبدئي', style: TextStyle(color: Colors.grey, fontSize: 16)),
              Text(
                '${total.toStringAsFixed(2)} ج.م',
                style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Confirm order
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تأكيد الطلب بنجاح!')),
              );
            },
            icon: const Icon(Icons.check_circle),
            label: const Text('تأكيد الطلب وشراء', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }
}
