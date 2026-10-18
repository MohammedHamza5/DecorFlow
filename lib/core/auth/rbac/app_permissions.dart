enum AppRole {
  owner,
  manager,
  seller;

  static AppRole fromString(String? roleStr) {
    switch (roleStr) {
      case 'owner':
        return AppRole.owner;
      case 'manager':
        return AppRole.manager;
      case 'seller':
      default:
        return AppRole.seller;
    }
  }

  String get nameStr {
    switch (this) {
      case AppRole.owner:
        return 'owner';
      case AppRole.manager:
        return 'manager';
      case AppRole.seller:
        return 'seller';
    }
  }
}

enum AppPermission {
  // ═══ كتالوج المنتجات ═══
  viewProducts,      // الكل
  addProduct,        // owner, manager
  editProduct,       // owner, manager
  deleteProduct,     // owner فقط
  editPrices,        // owner, manager

  // ═══ المخزون ═══
  viewInventory,     // الكل
  addStock,          // owner, manager
  deductStock,       // owner, manager, seller (للبيع)
  adjustStock,       // owner, manager
  recordDamage,      // owner, manager

  // ═══ العملاء والمشاريع ═══
  viewCustomers,     // الكل
  addCustomer,       // الكل
  editCustomer,      // owner, manager
  deleteCustomer,    // owner فقط
  viewProjects,      // الكل
  createProject,     // الكل
  deleteProject,     // owner فقط

  // ═══ عروض الأسعار ═══
  viewQuotes,        // الكل
  createQuote,       // owner, manager, seller
  editQuote,         // owner, manager, seller (صاحب العرض فقط)
  deleteQuote,       // owner, manager
  editNetPrice,      // owner فقط (سعر التكلفة)

  // ═══ الفواتير والمدفوعات ═══
  viewInvoices,      // owner, manager
  createInvoice,     // owner, manager
  deleteInvoice,     // owner فقط
  viewPayments,      // owner, manager
  createPayment,     // owner, manager
  deletePayment,     // owner فقط

  // ═══ التقارير ═══
  viewDashboard,     // الكل (بيانات مختلفة حسب الدور)
  viewFinancialReports, // owner, manager

  // ═══ الإدارة ═══
  manageTeam,        // owner, manager
  manageSuppliers,   // owner, manager
  manageSettings,    // owner فقط
}

class RolePermissions {
  static const Map<AppRole, List<AppPermission>> _permissions = {
    AppRole.owner: AppPermission.values,
    AppRole.manager: [
      AppPermission.viewProducts,
      AppPermission.addProduct,
      AppPermission.editProduct,
      AppPermission.editPrices,
      AppPermission.viewInventory,
      AppPermission.addStock,
      AppPermission.deductStock,
      AppPermission.adjustStock,
      AppPermission.recordDamage,
      AppPermission.viewCustomers,
      AppPermission.addCustomer,
      AppPermission.editCustomer,
      AppPermission.viewProjects,
      AppPermission.createProject,
      AppPermission.viewQuotes,
      AppPermission.createQuote,
      AppPermission.editQuote,
      AppPermission.deleteQuote,
      AppPermission.viewInvoices,
      AppPermission.createInvoice,
      AppPermission.viewPayments,
      AppPermission.createPayment,
      AppPermission.viewDashboard,
      AppPermission.viewFinancialReports,
      AppPermission.manageTeam,
      AppPermission.manageSuppliers,
    ],
    AppRole.seller: [
      AppPermission.viewProducts,
      AppPermission.viewInventory,
      AppPermission.deductStock,
      AppPermission.viewCustomers,
      AppPermission.addCustomer,
      AppPermission.viewProjects,
      AppPermission.createProject,
      AppPermission.viewQuotes,
      AppPermission.createQuote,
      AppPermission.editQuote,
      AppPermission.viewDashboard,
    ],
  };

  /// Returns true if the given [role] has the specified [permission].
  static bool hasPermission(AppRole role, AppPermission permission) {
    if (role == AppRole.owner) return true;
    return _permissions[role]?.contains(permission) ?? false;
  }
}
