// Định nghĩa các loại Tag như yêu cầu
enum TagType { SHOES, CLOTHING, EQUIPMENT, ACCESSORY, BAG, PROTECTIVE_GEAR }

class ProductTag {
  String name;
  TagType type;

  ProductTag({required this.name, required this.type});

  // Helper để lấy string value gửi lên server (SHOES, BAG...)
  String get typeName => type.name;
}
