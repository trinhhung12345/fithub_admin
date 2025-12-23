import 'package:flutter/material.dart';
import 'package:fithub_admin/configs/app_colors.dart';
import 'package:fithub_admin/core/components/common/form/fit_hub_select_input.dart';
import 'package:fithub_admin/data/models/product_tag.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FitHubTagInput extends StatefulWidget {
  final Function(List<ProductTag>) onTagsChanged;
  final List<ProductTag> initialTags; // Thêm tham số này

  const FitHubTagInput({
    super.key,
    required this.onTagsChanged,
    this.initialTags = const [], // Mặc định rỗng
  });

  @override
  State<FitHubTagInput> createState() => _FitHubTagInputState();
}

class _FitHubTagInputState extends State<FitHubTagInput> {
  late List<ProductTag> _tags; // Bỏ final, thêm late

  // State cho dropdown
  TagType _selectedType = TagType.SHOES; // Mặc định
  String? _selectedTagName; // Tag name được chọn

  // Lấy danh sách tag names theo type đã chọn
  List<String> get _availableTagNames => tagDictionary[_selectedType] ?? [];

  @override
  void initState() {
    super.initState();
    // Copy list từ initialTags để không ảnh hưởng list gốc
    _tags = List.from(widget.initialTags);
    // Set default tag name nếu có
    if (_availableTagNames.isNotEmpty) {
      _selectedTagName = _availableTagNames.first;
    }
  }

  // Nếu cha update initialTags (khi load API xong), con cũng phải update theo
  @override
  void didUpdateWidget(covariant FitHubTagInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTags != oldWidget.initialTags) {
      setState(() {
        _tags = List.from(widget.initialTags);
      });
    }
  }

  void _onTypeChanged(TagType? newType) {
    if (newType == null) return;
    setState(() {
      _selectedType = newType;
      // Reset tag name khi đổi type
      final names = tagDictionary[newType] ?? [];
      _selectedTagName = names.isNotEmpty ? names.first : null;
    });
  }

  void _addTag() {
    if (_selectedTagName == null) return;

    // Kiểm tra tag đã tồn tại chưa
    final newTag = ProductTag(name: _selectedTagName!, type: _selectedType);
    final exists = _tags.any(
      (t) => t.name == newTag.name && t.type == newTag.type,
    );

    if (exists) {
      // Tag đã tồn tại, không thêm nữa
      return;
    }

    setState(() {
      _tags.add(newTag);
    });

    // Callback ra ngoài
    widget.onTagsChanged(_tags);
  }

  void _removeTag(int index) {
    setState(() {
      _tags.removeAt(index);
    });
    widget.onTagsChanged(_tags);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Product Tags",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),

        // 1. Khu vực nhập liệu (Type + Name + Button)
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Select Type
            Expanded(
              flex: 4,
              child: FitHubSelectInput<TagType>(
                label: "Type",
                hintText: "Select Type",
                items: TagType.values,
                value: _selectedType,
                itemLabelBuilder: (e) => e.name.replaceAll('_', ' '),
                onChanged: _onTypeChanged,
              ),
            ),
            const SizedBox(width: 12),

            // Select Tag Name (Dropdown thay vì Input)
            Expanded(
              flex: 5,
              child: FitHubSelectInput<String>(
                label: "Tag Name",
                hintText: "Select Tag",
                items: _availableTagNames,
                value: _selectedTagName,
                itemLabelBuilder: (e) => e,
                onChanged: (val) {
                  if (val != null) setState(() => _selectedTagName = val);
                },
              ),
            ),
            const SizedBox(width: 12),

            // Add Button
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: IconButton(
                onPressed: _addTag,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(12),
                ),
                icon: const FaIcon(FontAwesomeIcons.plus, size: 16),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // 2. Danh sách Tags đã thêm (Chips)
        if (_tags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.asMap().entries.map((entry) {
              final index = entry.key;
              final tag = entry.value;
              return Chip(
                label: Text(
                  "${tag.type.name.replaceAll('_', ' ')}: ${tag.name}",
                ),
                labelStyle: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMain,
                ),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: AppColors.border),
                ),
                deleteIcon: const FaIcon(
                  FontAwesomeIcons.xmark,
                  size: 14,
                  color: Colors.grey,
                ),
                onDeleted: () => _removeTag(index),
              );
            }).toList(),
          ),
      ],
    );
  }
}
