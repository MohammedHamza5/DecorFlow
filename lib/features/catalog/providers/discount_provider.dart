import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';


class DiscountCampaign {
  final String id;
  final String title;
  final String targetType; // 'all' or 'categories'
  final List<String> categories;
  final double discountPercent;
  final DateTime createdAt;

  DiscountCampaign({
    required this.id,
    required this.title,
    required this.targetType,
    required this.categories,
    required this.discountPercent,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'targetType': targetType,
      'categories': categories,
      'discountPercent': discountPercent,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DiscountCampaign.fromMap(Map<String, dynamic> map) {
    return DiscountCampaign(
      id: map['id'],
      title: map['title'],
      targetType: map['targetType'],
      categories: List<String>.from(map['categories'] ?? []),
      discountPercent: (map['discountPercent'] as num).toDouble(),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

class DiscountCampaignNotifier extends AsyncNotifier<List<DiscountCampaign>> {
  @override
  Future<List<DiscountCampaign>> build() async {
    return _loadCampaigns();
  }

  Future<List<DiscountCampaign>> _loadCampaigns() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('discount_campaigns');
    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((e) => DiscountCampaign.fromMap(e)).toList();
    }
    return [];
  }

  Future<void> addCampaign(DiscountCampaign campaign) async {
    final current = state.value ?? [];
    final newList = [...current, campaign];
    await _save(newList);
    state = AsyncData(newList);
  }

  Future<void> removeCampaign(String id) async {
    final current = state.value ?? [];
    final newList = current.where((c) => c.id != id).toList();
    await _save(newList);
    state = AsyncData(newList);
  }

  Future<void> _save(List<DiscountCampaign> campaigns) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(campaigns.map((c) => c.toMap()).toList());
    await prefs.setString('discount_campaigns', jsonString);
  }
}

final discountCampaignsProvider = AsyncNotifierProvider<DiscountCampaignNotifier, List<DiscountCampaign>>(() {
  return DiscountCampaignNotifier();
});
