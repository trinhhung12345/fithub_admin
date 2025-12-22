import 'package:flutter/material.dart';
import 'package:fithub_admin/configs/app_colors.dart';
import 'package:fithub_admin/configs/app_responsive.dart';
import 'package:fithub_admin/core/components/common/table/fit_hub_pagination.dart';
import 'package:fithub_admin/core/components/common/table/table_components.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FitHubDataTable<T> extends StatelessWidget {
  final List<FitHubColumn> columns;
  final List<T> data;

  // Builder cho Web: Trả về danh sách Widget tương ứng với số cột
  final List<Widget> Function(T item) webRowBuilder;

  // Builder cho Mobile:
  // 1. Header Widget (Phần luôn hiện: Ảnh, Tên)
  final Widget Function(T item) mobileHeaderBuilder;
  // 2. Detail Widget (Phần hiện ra khi bấm mũi tên: Giá, Qty, Action...)
  final Widget Function(T item) mobileDetailBuilder;

  // Selection Logic
  final bool Function(T item) isSelected;
  final Function(T item, bool? val) onSelectRow;
  final Function(bool? val) onSelectAll;

  // Pagination
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const FitHubDataTable({
    super.key,
    required this.columns,
    required this.data,
    required this.webRowBuilder,
    required this.mobileHeaderBuilder,
    required this.mobileDetailBuilder,
    required this.isSelected,
    required this.onSelectRow,
    required this.onSelectAll,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // DATA AREA
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Responsive.isMobile(context)
                ? _buildMobileList()
                : _buildWebTable(),
          ),
        ),

        const SizedBox(height: 16),

        // PAGINATION AREA
        FitHubPagination(
          currentPage: currentPage,
          totalPages: totalPages,
          onPageChanged: onPageChanged,
        ),
      ],
    );
  }

  // --- WEB IMPLEMENTATION ---
  Widget _buildWebTable() {
    return Column(
      children: [
        // 1. Header Row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xFFF9FAFB), // Màu nền header xám nhạt
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              // Checkbox All
              SizedBox(
                width: 40,
                child: Checkbox(
                  value: false,
                  onChanged: onSelectAll,
                ), // Logic check all xử lý sau
              ),
              // Columns
              ...columns.map(
                (col) => Expanded(
                  flex: col.flex,
                  child: Row(
                    children: [
                      Text(
                        col.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (col.isSortable)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: FaIcon(
                            FontAwesomeIcons.sort,
                            size: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // 2. Data Rows
        Expanded(
          child: ListView.separated(
            itemCount: data.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppColors.border),
            itemBuilder: (context, index) {
              final item = data[index];
              final cells = webRowBuilder(item);

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // Checkbox Row
                    SizedBox(
                      width: 40,
                      child: Checkbox(
                        value: isSelected(item),
                        onChanged: (val) => onSelectRow(item, val),
                        activeColor: AppColors.primary,
                      ),
                    ),
                    // Cells
                    ...List.generate(columns.length, (i) {
                      return Expanded(flex: columns[i].flex, child: cells[i]);
                    }),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- MOBILE IMPLEMENTATION ---
  Widget _buildMobileList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: data.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = data[index];
        return _MobileCard(
          item: item,
          header: mobileHeaderBuilder(item),
          detail: mobileDetailBuilder(item),
          isSelected: isSelected(item),
          onSelect: (val) => onSelectRow(item, val),
        );
      },
    );
  }
}

// Widget con xử lý việc mở rộng trên Mobile
class _MobileCard<T> extends StatefulWidget {
  final T item;
  final Widget header;
  final Widget detail;
  final bool isSelected;
  final Function(bool?) onSelect;

  const _MobileCard({
    required this.item,
    required this.header,
    required this.detail,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  State<_MobileCard> createState() => _MobileCardState();
}

class _MobileCardState extends State<_MobileCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header Row (Luôn hiện)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Checkbox(value: widget.isSelected, onChanged: widget.onSelect),
                Expanded(child: widget.header),
                IconButton(
                  icon: FaIcon(
                    isExpanded
                        ? FontAwesomeIcons.chevronUp
                        : FontAwesomeIcons.chevronDown,
                    size: 16,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() => isExpanded = !isExpanded),
                ),
              ],
            ),
          ),

          // Detail Row (Hiện khi mở)
          if (isExpanded)
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
                color: Color(0xFFF9FAFB),
              ),
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              child: widget.detail,
            ),
        ],
      ),
    );
  }
}
