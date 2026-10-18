# 💳 خطة محفظة عمولات المهندسين والصنايعية (Technician & Architect Wallet Plan)

يوضح هذا المستند التصميم البرمجي الكامل لنظام إدارة عمولات المهندسين، مقاولي التشطيبات، والفنيين (الصنايعية) لتسهيل حساب مستحقاتهم آلياً وتحفيزهم لجلب زبائن جدد للمحل.

---

## 💾 تصميم قاعدة البيانات (Supabase Schema)

سنقوم بإنشاء جدولين رئيسيين في قاعدة البيانات مع تفعيل سياسات الحماية (RLS) بناءً على معرف المتجر `shop_id`:

```sql
-- 1. جدول الفنيين والمهندسين
CREATE TABLE IF NOT EXISTS public.premium_technicians (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    shop_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    name text NOT NULL,
    phone text NOT NULL,
    title text NOT NULL, -- (مثال: مهندس ديكور، كهربائي، نجار، مقاول)
    commission_rate numeric DEFAULT 5.0, -- النسبة الافتراضية (مثلاً 5%)
    notes text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

-- 2. جدول المعاملات المالية والمحفظة
CREATE TABLE IF NOT EXISTS public.premium_technician_transactions (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    shop_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    technician_id uuid NOT NULL REFERENCES public.premium_technicians(id) ON DELETE CASCADE,
    invoice_id uuid REFERENCES public.invoices(id) ON DELETE SET NULL,
    amount numeric NOT NULL, -- قيمة العملية (موجب للإيداع وسالب للسحب)
    transaction_type text NOT NULL, -- 'commission' (عمولة) أو 'withdrawal' (سحب نقدي)
    status text DEFAULT 'completed', -- 'pending' (معلق حتى تحصيل الفاتورة) أو 'completed'
    notes text,
    created_at timestamp with time zone DEFAULT now()
);

-- تفعيل الحماية RLS لكل جدول وربطها بـ shop_id للتاجر الحالي
```

---

## 🏛️ منطق العمل (Domain & Logic)

### 1. النموذج البرمجي (Dart Models)
* **`TechnicianModel`:** يحتوي على حقول (معرف الفني، معرف المتجر، الاسم، الهاتف، النسبة، الرصيد المالي الحالي).
* **`WalletTransactionModel`:** يحتوي على تفاصيل المعاملة المالية (المعرف، معرف الفني، القيمة، التاريخ، نوع المعاملة، رقم الفاتورة المقترنة).

### 2. معالجة حساب العمولات تلقائياً (Triggering Logic)
* عند تسجيل فاتورة جديدة في النظام وربطها بـ `technician_id` الفني:
  * يقوم النظام بحساب قيمة العمولة بناءً على `commission_rate` الخاص بالفني (مثلاً 5% من إجمالي قيمة المواد).
  * تسجل العملية في جدول `premium_technician_transactions` بحالة `pending` (معلقة).
* بمجرد سداد الفاتورة بالكامل أو تحصيل دفعة، يتم تحديث حالة العمولة المقابلة إلى `completed` وإضافتها تلقائياً للرصيد المتاح للسحب للفني.

---

## 📱 واجهات المستخدم (UI Screens)

1. **شاشة الفنيين الرئيسية (Technicians List Screen):**
   * عرض كروت الفنيين، وتضمين الاسم، التخصص، ورصيد المحفظة الحالي.
   * زر إضافة فني جديد (الاسم، الهاتف، النسبة الافتراضية، التخصص).
   * محرك بحث وتصفية حسب التخصص.

2. **شاشة المحفظة وكشف الحساب (Wallet Details & Statement Screen):**
   * عرض الرصيد الإجمالي المتاح، والرصيد المعلق (بسبب فواتير لم تسدد بالكامل).
   * قائمة بكشف الحساب بالتفصيل بالتواريخ (المبالغ المضافة باللون الأخضر، والمبالغ المسحوبة باللون الأحمر).
   * زر "تسجيل دفعة مسحوبة" (Withdrawal Transaction).

3. **نموذج إيصال السحب (Withdrawal Receipt Share):**
   * عند إتمام عملية سحب نقدي للفني، يقوم التطبيق بتوليد بطاقة رقمية منسقة تحتوي على تفاصيل السحب (اسم المحل، اسم الفني، التاريخ، المبلغ، التوقيع الرقمي) جاهزة للمشاركة السريعة كصورة عبر الـ WhatsApp للتوثيق والمصداقية.
