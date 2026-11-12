part of '../screen/store_screen.dart';

class _CartNavigationIcon extends StatelessWidget {
  final IconData icon;

  const _CartNavigationIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoreCubit, StoreState>(
      builder: (context, state) => Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon),
          if (state.cartItems.isNotEmpty)
            Positioned(
              top: -7,
              right: -9,
              child: Container(
                constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${state.cartItems.length}',
                  style: const TextStyle(
                    color: AppColors.surface,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CatalogTab extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _CatalogTab({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoreCubit, StoreState>(
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: onRefresh,
          child: CustomScrollView(
            key: ValueKey(state.catalogRevision),
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _WelcomeBanner()),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 66,
                  child: state.loadingCategories && state.categories.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            16,
                            10,
                            16,
                            10,
                          ),
                          scrollDirection: Axis.horizontal,
                          children: [
                            _CategoryChip(
                              label: 'الكل',
                              selected: state.selectedCategorySlug == null,
                              onTap: () =>
                                  context.read<StoreCubit>().loadProducts(),
                            ),
                            ...state.categories.map(
                              (category) => _CategoryChip(
                                label: category.name,
                                selected:
                                    category.slug == state.selectedCategorySlug,
                                onTap: () => context
                                    .read<StoreCubit>()
                                    .loadProducts(categorySlug: category.slug),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 20),
                sliver: state.loadingProducts && state.products.isEmpty
                    ? const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : state.products.isEmpty
                    ? const SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyState(
                          icon: Icons.inventory_2_outlined,
                          title: 'لا توجد منتجات هنا',
                          subtitle: 'جرّب اختيار قسم آخر أو حدّث القائمة.',
                        ),
                      )
                    : SliverGrid(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final product = state.products[index];
                          return _ProductCard(
                            product: product,
                            isFavorite: state.isFavorite(product.id),
                            onToggleFavorite: () => context
                                .read<StoreCubit>()
                                .toggleFavorite(product),
                            onTap: () => _showProductDetails(context, product),
                          );
                        }, childCount: state.products.length),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: 0.69,
                            ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showProductDetails(
    BuildContext context,
    StoreProduct product,
  ) async {
    final storeCubit = context.read<StoreCubit>();
    final details = await storeCubit.loadProductDetails(product.slug);
    if (!context.mounted || details == null) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: storeCubit,
        child: _ProductDetailsSheet(product: details),
      ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 8),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تسوّق براحة',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: AppColors.surface,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'اكتشف مجموعتنا واختر ما يناسبك',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(color: AppColors.whiteSubtle, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.whiteOverlay,
              borderRadius: BorderRadius.circular(19),
            ),
            child: const Icon(
              Icons.shopping_basket_rounded,
              color: AppColors.surface,
              size: 31,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ChoiceChip(
        label: Text(label, textDirection: TextDirection.rtl),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surface,
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
        ),
        labelStyle: TextStyle(
          color: selected ? AppColors.surface : AppColors.ink,
          fontWeight: FontWeight.w600,
        ),
        showCheckmark: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}

class _FavoritesTab extends StatelessWidget {
  const _FavoritesTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoreCubit, StoreState>(
      builder: (context, state) {
        if (state.loadingFavorites && state.favorites.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (state.favorites.isEmpty) {
          return const _EmptyState(
            icon: Icons.favorite_border_rounded,
            title: 'لا توجد منتجات في المفضلة',
            subtitle: 'احفظ المنتجات التي تعجبك لتجدها هنا.',
          );
        }
        return RefreshIndicator(
          onRefresh: context.read<StoreCubit>().loadFavorites,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.favorites.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = state.favorites[index];
              return Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => _openProductDetails(context, item.product),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: SizedBox(
                            width: 68,
                            height: 68,
                            child: _ProductImage(url: item.product.image),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.categoryName ?? '',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                item.product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.ink,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${_price(item.product.price)} EGP',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (item.product.publisher != null)
                                Text(
                                  'بواسطة ${item.product.publisher!.displayName}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 10,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'إزالة من المفضلة',
                          onPressed: () => context
                              .read<StoreCubit>()
                              .toggleFavorite(item.product),
                          icon: const Icon(
                            Icons.favorite_rounded,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _openProductDetails(
    BuildContext context,
    StoreProduct product,
  ) async {
    final cubit = context.read<StoreCubit>();
    final details = await cubit.loadProductDetails(product.slug);
    if (!context.mounted || details == null) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: _ProductDetailsSheet(product: details),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final StoreProduct product;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const _ProductCard({
    required this.product,
    required this.onTap,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: _ProductImage(url: product.image),
                      ),
                    ),
                    PositionedDirectional(
                      top: 8,
                      end: 8,
                      child: IconButton(
                        tooltip: isFavorite
                            ? 'إزالة من المفضلة'
                            : 'إضافة إلى المفضلة',
                        onPressed: onToggleFavorite,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surface.withValues(
                            alpha: 0.9,
                          ),
                          minimumSize: const Size(34, 34),
                        ),
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFavorite ? AppColors.error : AppColors.muted,
                          size: 19,
                        ),
                      ),
                    ),
                    if (!product.isInStock)
                      const Center(
                        child: Chip(
                          label: Text('نفد المخزون'),
                          backgroundColor: AppColors.surface,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 11),
              if (product.categoryName != null)
                Text(
                  product.categoryName!,
                  textDirection: TextDirection.rtl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                product.name,
                textDirection: TextDirection.rtl,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              if (product.publisher != null) ...[
                const SizedBox(height: 3),
                Text(
                  'بواسطة ${product.publisher!.displayName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 10),
                ),
              ],
              const SizedBox(height: 9),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _price(product.price),
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductDetailsSheet extends StatelessWidget {
  final StoreProduct product;

  const _ProductDetailsSheet({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.dragHandle,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 220,
                child: _ProductImage(url: product.image),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              product.name,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (product.categoryName != null) ...[
              const SizedBox(height: 6),
              Text(
                product.categoryName!,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (product.publisher != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.storefront_outlined,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'الناشر: ${product.publisher!.displayName}',
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Text(
              product.description.isEmpty
                  ? 'لا يتوفر وصف إضافي لهذا المنتج.'
                  : product.description,
              textDirection: TextDirection.rtl,
              style: const TextStyle(color: AppColors.muted, height: 1.6),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: product.isInStock
                    ? AppColors.successContainer
                    : AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                product.isInStock
                    ? 'متوفر في المخزون: ${product.quantity}'
                    : 'نفد المخزون',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: product.isInStock
                      ? AppColors.success
                      : AppColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _price(product.price),
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                  ),
                  onPressed: product.isInStock
                      ? () {
                          context.read<StoreCubit>().addToCart(product);
                          Navigator.pop(context);
                        }
                      : null,
                  icon: const Icon(Icons.add_shopping_cart_rounded),
                  label: const Text('أضف إلى السلة'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String? url;

  const _ProductImage({this.url});

  @override
  Widget build(BuildContext context) {
    final parsed = url == null ? null : Uri.tryParse(url!);
    if (parsed == null || !parsed.hasAbsolutePath || parsed.host.isEmpty) {
      return const _ImagePlaceholder();
    }
    return Image.network(
      url!,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const _ImagePlaceholder(),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryContainer,
      child: const Center(
        child: Icon(
          Icons.inventory_2_outlined,
          color: AppColors.primary,
          size: 42,
        ),
      ),
    );
  }
}

class _CartTab extends StatelessWidget {
  const _CartTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoreCubit, StoreState>(
      builder: (context, state) {
        if (state.loadingCart && state.cartItems.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (state.cartItems.isEmpty) {
          return const _EmptyState(
            icon: Icons.shopping_bag_outlined,
            title: 'سلتك فارغة',
            subtitle: 'ابدأ باكتشاف المنتجات وأضف ما يعجبك.',
          );
        }
        return Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.cartItems.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    _CartItemCard(item: state.cartItems[index]),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 17, 20, 18),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'الإجمالي',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              color: AppColors.ink,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          _price(state.cartTotal),
                          textDirection: TextDirection.ltr,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: state.busy
                            ? null
                            : () => _startCheckout(context),
                        child: state.busy
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.surface,
                                ),
                              )
                            : const Text('تأكيد الطلب'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _startCheckout(BuildContext context) async {
    final checkout = await showDialog<CheckoutDetails>(
      context: context,
      builder: (_) => const _CheckoutDialog(),
    );
    if (checkout == null || !context.mounted) return;
    await context.read<StoreCubit>().placeOrder(
      address: checkout.address,
      latitude: checkout.latitude,
      longitude: checkout.longitude,
      paymentMethod: checkout.paymentMethod,
    );
  }
}

class CheckoutDetails {
  final String address;
  final double? latitude;
  final double? longitude;
  final String paymentMethod;

  const CheckoutDetails({
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.paymentMethod,
  });
}

class _CheckoutDialog extends StatefulWidget {
  const _CheckoutDialog();

  @override
  State<_CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<_CheckoutDialog> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  String _paymentMethod = 'cash';

  @override
  void dispose() {
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  double? _coordinate(String value) =>
      value.trim().isEmpty ? null : double.tryParse(value.trim());

  String? _validateCoordinate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (double.tryParse(value.trim()) == null) {
      return 'أدخل إحداثية صحيحة';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('بيانات التوصيل', textDirection: TextDirection.rtl),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _addressController,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(labelText: 'عنوان التوصيل'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'أدخل عنوان التوصيل'
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _latitudeController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'خط العرض (اختياري)',
                ),
                validator: _validateCoordinate,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _longitudeController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'خط الطول (اختياري)',
                ),
                validator: _validateCoordinate,
              ),
              const SizedBox(height: 12),
              const Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'طريقة الدفع',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'cash',
                    label: Text('نقداً'),
                    icon: Icon(Icons.payments_outlined),
                  ),
                  ButtonSegment(
                    value: 'card',
                    label: Text('بطاقة'),
                    icon: Icon(Icons.credit_card_rounded),
                  ),
                ],
                selected: {_paymentMethod},
                onSelectionChanged: (selection) =>
                    setState(() => _paymentMethod = selection.first),
                showSelectedIcon: false,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(
              context,
              CheckoutDetails(
                address: _addressController.text.trim(),
                latitude: _coordinate(_latitudeController.text),
                longitude: _coordinate(_longitudeController.text),
                paymentMethod: _paymentMethod,
              ),
            );
          },
          child: const Text('متابعة'),
        ),
      ],
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;

  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final store = context.read<StoreCubit>();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: SizedBox(
              width: 76,
              height: 76,
              child: _ProductImage(url: item.product.image),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  textDirection: TextDirection.rtl,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _price(item.subtotal),
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'الكمية: ${item.quantity}',
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'حذف',
            onPressed: () => store.removeCartItem(item),
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrdersTab extends StatelessWidget {
  const _OrdersTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoreCubit, StoreState>(
      builder: (context, state) {
        if (state.loadingOrders && state.orders.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (state.orders.isEmpty) {
          return const _EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'لا توجد طلبات بعد',
            subtitle: 'ستظهر طلباتك هنا بعد إتمام الشراء.',
          );
        }
        return RefreshIndicator(
          onRefresh: context.read<StoreCubit>().loadOrders,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.orders.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _OrderCard(
              order: state.orders[index],
              onTap: () => _showOrderDetails(context, state.orders[index]),
              onPay:
                  state.orders[index].paymentMethod == 'card' &&
                      state.orders[index].status.toLowerCase() == 'pending'
                  ? () => context.read<StoreCubit>().payForOrder(
                      state.orders[index],
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }

  Future<void> _showOrderDetails(BuildContext context, StoreOrder order) async {
    final details = await context.read<StoreCubit>().loadOrderDetails(
      order.code,
    );
    if (!context.mounted || details == null) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تفاصيل الطلب', textDirection: TextDirection.rtl),
        content: SizedBox(
          width: 360,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('رقم الطلب: ${details.code}'),
                const SizedBox(height: 8),
                Text('الحالة: ${_statusLabel(details.status)}'),
                Text('طريقة الدفع: ${_paymentLabel(details.paymentMethod)}'),
                if (details.address.isNotEmpty)
                  Text('العنوان: ${details.address}'),
                const Divider(height: 24),
                ...details.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${item.product.name} × ${item.quantity}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(_price(item.totalPrice)),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 24),
                Text(
                  'الإجمالي: ${_price(details.totalPrice)}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final StoreOrder order;
  final VoidCallback onTap;
  final VoidCallback? onPay;

  const _OrderCard({
    required this.order,
    required this.onTap,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'طلب #${order.code}',
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${_statusLabel(order.status)} · ${order.items.length} منتجات',
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _price(order.totalPrice),
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (onPay != null)
                    TextButton(onPressed: onPay, child: const Text('دفع الآن')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(icon, color: AppColors.primary, size: 38),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

String _price(double value) => value.toStringAsFixed(2);

String _statusLabel(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return 'قيد الانتظار';
    case 'completed':
      return 'مكتمل';
    case 'cancelled':
      return 'ملغي';
    case 'processing':
      return 'قيد التجهيز';
    default:
      return status;
  }
}

String _paymentLabel(String method) {
  switch (method.toLowerCase()) {
    case 'card':
      return 'بطاقة';
    case 'cash':
      return 'نقداً عند الاستلام';
    default:
      return method;
  }
}
