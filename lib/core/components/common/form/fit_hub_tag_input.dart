import 'package:flutter/material.dart';
import 'package:fithub_admin/configs/app_colors.dart';
import 'package:fithub_admin/configs/app_text_styles.dart';
import 'package:fithub_admin/core/components/common/form/fit_hub_label_input.dart';
import 'package:fithub_admin/core/components/common/form/fit_hub_select_input.dart';
import 'package:fithub_admin/data/models/product_tag.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FitHubTagInput extends StatefulWidget {
  final Function(List<ProductTag>) onTagsChanged;

  const FitHubTagInput({super.key, required this.onTagsChanged});

  @override
  State<FitHubTagInput> createState() => _FitHubTagInputState();
}

class _FitHubTagInputState extends State<FitHubTagInput> {
  final List<ProductTag> _tags = [];

  // Temp controllers cho việc nhập liệu
  final _tagNameController = TextEditingController();
  TagType _selectedType = TagType.SHOES; // Mặc định

  void _addTag() {
    if (_tagNameController.text.trim().isEmpty) return;

    setState(() {
      _tags.add(
        ProductTag(name: _tagNameController.text.trim(), type: _selectedType),
      );
      _tagNameController.clear();
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
                itemLabelBuilder: (e) => e.name,
                onChanged: (val) {
                  if (val != null) setState(() => _selectedType = val);
                },
              ),
            ),
            const SizedBox(width: 12),

            // Input Name
            Expanded(
              flex: 5,
              child: FitHubLabelInput(
                label: "Tag Name",
                hintText: "e.g. Gym, Running",
                controller: _tagNameController,
              ),
            ),
            const SizedBox(width: 12),

            // Add Button
            Padding(
              padding: const EdgeInsets.only(
                bottom: 4.0,
              ), // Căn chỉnh với input
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
                label: Text("${tag.type.name}: ${tag.name}"),
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
