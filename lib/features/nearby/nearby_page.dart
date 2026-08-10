import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'nearby_controller.dart';
import 'nearby_card.dart';

@RoutePage()
class NearbyPage extends StatefulWidget {
  const NearbyPage({super.key});

  @override
  State<NearbyPage> createState() => _NearbyPageState();
}

class _NearbyPageState extends State<NearbyPage> {
  late final NearbyController _controller;

  @override
  void initState() {
    super.initState();
    _controller = NearbyController();
    _controller.loadNearby();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Navigasi ke halaman chat (sesuaikan dengan route yang ada)
  void _onChatTap(NearbyUser user) {
    // Contoh: context.router.pushNamed('/chat?guid=${user.guid}&name=${user.fullname}');
    // Untuk sementara gunakan snackbar sebagai placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chat dengan ${user.fullname}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _onRefresh() => _controller.refresh();

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FilterSheet(controller: _controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Radar Terdekat'),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          // LOADING AWAL
          if (_controller.isInitialLoading) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Mendapatkan posisi GPS & mencari pengguna...',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          // ERROR
          if (_controller.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        size: 64, color: colorScheme.error),
                    const SizedBox(height: 16),
                    Text(
                      _controller.errorMessage!,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _onRefresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final users = _controller.users;
          final isEmpty = users.isEmpty;

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: CustomScrollView(
              slivers: [
                // HEADER + TOMBOL FILTER
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pengguna di sekitar kamu',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${users.length} pengguna ditemukan',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: _showFilterSheet,
                          icon: const Icon(Icons.tune),
                          label: const Text('Filter'),
                        ),
                      ],
                    ),
                  ),
                ),

                // EMPTY STATE
                if (isEmpty && !_controller.isLoading)
                  SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Tidak ada pengguna terdekat sesuai filter.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  // GRID RESPONSIF
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount =
                            constraints.crossAxisExtent > 600
                                ? (constraints.crossAxisExtent > 900 ? 4 : 3)
                                : 2;
                        return SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.75,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => NearbyCard(
                              user: users[index],
                              onChatTap: () => _onChatTap(users[index]),
                            ),
                            childCount: users.length,
                          ),
                        );
                      },
                    ),
                  ),

                // LOADING TAMBAHAN (bukan initial)
                if (_controller.isLoading && !_controller.isInitialLoading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------- BOTTOM SHEET FILTER ----------
class _FilterSheet extends StatefulWidget {
  final NearbyController controller;
  const _FilterSheet({required this.controller});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late double _radius;
  late String _gender;
  late RangeValues _ageRange;

  @override
  void initState() {
    super.initState();
    _radius = widget.controller.radius;
    _gender = widget.controller.gender;
    _ageRange = RangeValues(
      widget.controller.minAge.toDouble(),
      widget.controller.maxAge.toDouble(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) => SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('Filter Pengguna', style: textTheme.titleLarge),
            const SizedBox(height: 24),

            // Gender
            Text('Jenis Kelamin', style: textTheme.titleSmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ['all', 'male', 'female'].map((g) {
                final selected = _gender == g;
                return ChoiceChip(
                  label: Text(g == 'all'
                      ? 'Semua'
                      : (g == 'male' ? 'Laki-laki' : 'Perempuan')),
                  selected: selected,
                  onSelected: (v) {
                    if (v) setState(() => _gender = g);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Radius
            Text('Jarak Maksimal', style: textTheme.titleSmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${_radius.toInt()} km', style: textTheme.bodyLarge),
                Text('1 - 200 km', style: textTheme.bodySmall),
              ],
            ),
            Slider(
              value: _radius,
              min: 1,
              max: 200,
              divisions: 199,
              label: '${_radius.toInt()} km',
              onChanged: (v) => setState(() => _radius = v),
            ),
            const SizedBox(height: 16),

            // Rentang Usia
            Text('Rentang Usia', style: textTheme.titleSmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_ageRange.start.toInt()} - ${_ageRange.end.toInt()} tahun',
                  style: textTheme.bodyLarge,
                ),
                Text('18 - 80 tahun', style: textTheme.bodySmall),
              ],
            ),
            RangeSlider(
              values: _ageRange,
              min: 18,
              max: 80,
              divisions: 62,
              labels: RangeLabels(
                '${_ageRange.start.toInt()}',
                '${_ageRange.end.toInt()}',
              ),
              onChanged: (v) => setState(() => _ageRange = v),
            ),
            const SizedBox(height: 32),

            // Tombol Reset & Terapkan
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      widget.controller.resetFilter();
                      Navigator.pop(context);
                    },
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      widget.controller.applyFilter(
                        radius: _radius,
                        gender: _gender,
                        minAge: _ageRange.start.toInt(),
                        maxAge: _ageRange.end.toInt(),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Terapkan Filter'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
