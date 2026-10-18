import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/design_template.dart';
import '../providers/design_advisor_providers.dart';
import 'package:stream_pay/core/responsive/constrained_body.dart';

class DesignCalculatorScreen extends ConsumerStatefulWidget {
  final DesignTemplate template;

  const DesignCalculatorScreen({super.key, required this.template});

  @override
  ConsumerState<DesignCalculatorScreen> createState() => _DesignCalculatorScreenState();
}

class _DesignCalculatorScreenState extends ConsumerState<DesignCalculatorScreen> {
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();

  double _width = 0.0;
  double _height = 0.0;

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _width = (double.tryParse(_widthController.text) ?? 0.0) / 100.0;
      _height = (double.tryParse(_heightController.text) ?? 0.0) / 100.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final materialsAsync = ref.watch(templateMaterialsProvider(widget.template.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.template.titleAr),
        centerTitle: true,
      ),
      body: ConstrainedForm(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.template.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  widget.template.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
            const SizedBox(height: 24),
            const Text(
              'أبعاد الحائط (بالسنتيمتر)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _widthController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'العرض',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      suffixText: 'سم',
                    ),
                    onChanged: (_) => _calculate(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _heightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'الارتفاع',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      suffixText: 'سم',
                    ),
                    onChanged: (_) => _calculate(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'الخامات المطلوبة (تقديرياً)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            materialsAsync.when(
              data: (materials) {
                if (materials.isEmpty) {
                  return const Text('لم يتم تحديد خامات لهذا التصميم بعد.', style: TextStyle(color: Colors.grey));
                }

                if (_width == 0 || _height == 0) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 12),
                        Expanded(child: Text('يرجى إدخال أبعاد الحائط لحساب الكميات المطلوبة.', style: TextStyle(color: Colors.blue))),
                      ],
                    ),
                  );
                }

                return Column(
                  children: materials.map((material) {
                    // Very simple mock logic for calculation.
                    // In a real app, this logic would live in a domain service.
                    double requiredQty = 0;
                    if (material.calculationRule.contains('panel_center')) {
                      requiredQty = (_width * 0.3) * material.unitMultiplier;
                    } else if (material.calculationRule.contains('louver')) {
                      requiredQty = (_width * 0.7) * material.unitMultiplier;
                    } else {
                      requiredQty = (_width * _height) * material.unitMultiplier;
                    }

                    // Ensure minimum of 1 if there's any area
                    requiredQty = requiredQty < 1 ? 1 : requiredQty.ceilToDouble();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          child: Icon(Icons.widgets, color: Theme.of(context).primaryColor),
                        ),
                        title: Text(material.productCategory),
                        subtitle: Text(material.isOptional ? 'اختياري' : 'أساسي'),
                        trailing: Text(
                          '${requiredQty.toInt()} وحدة',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('خطأ: $err', style: const TextStyle(color: Colors.red)),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: (_width > 0 && _height > 0)
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم إضافة الخامات لفاتورة جديدة')),
                      );
                    }
                  : null,
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('إضافة الكل لعرض السعر'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
