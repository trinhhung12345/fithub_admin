// Định nghĩa các loại Tag như yêu cầu
enum TagType { SHOES, CLOTHING, EQUIPMENT, ACCESSORY, BAG, PROTECTIVE_GEAR }

class ProductTag {
  String name;
  TagType type;

  ProductTag({required this.name, required this.type});

  // Helper để lấy string value gửi lên server (SHOES, BAG...)
  String get typeName => type.name;

  // Override equals và hashCode để so sánh đúng
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductTag && other.name == name && other.type == type;
  }

  @override
  int get hashCode => name.hashCode ^ type.hashCode;
}

// Dictionary các tag có sẵn theo Type
const Map<TagType, List<String>> tagDictionary = {
  TagType.SHOES: ['RUNNING SHOES', 'BASKETBALL SHOES'],
  TagType.CLOTHING: ['GYM T-SHIRT', 'SPORT SHORTS'],
  TagType.EQUIPMENT: ['DUMBBELL', 'BARBELL'],
  TagType.ACCESSORY: ['SPORT WATCH', 'WATER BOTTLE'],
  TagType.BAG: ['GYM BAG'],
  TagType.PROTECTIVE_GEAR: ['KNEE SUPPORT'],
};

// Lấy tất cả tags dưới dạng list ProductTag
List<ProductTag> get allPredefinedTags {
  List<ProductTag> tags = [];
  tagDictionary.forEach((type, names) {
    for (var name in names) {
      tags.add(ProductTag(name: name, type: type));
    }
  });
  return tags;
}
