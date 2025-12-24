import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fithub_admin/configs/app_colors.dart';

class OrderStatusChart extends StatefulWidget {
  final Map<String, double> data; // Map<Status, Count>

  const OrderStatusChart({super.key, required this.data});

  @override
  State<OrderStatusChart> createState() => _OrderStatusChartState();
}

class _OrderStatusChartState extends State<OrderStatusChart> {
  int touchedIndex = -1;

  // Helper chọn màu cho Status
  Color _getColor(String status) {
    switch (status) {
      case "NEW":
        return Colors.blue;
      case "CONFIRMED":
        return Colors.orange;
      case "DELIVERING":
        return Colors.purple;
      case "DONE":
        return Colors.green;
      case "CANCEL":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const Center(child: Text("No Data"));
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Order Statistics",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Chart Area
          SizedBox(
            height: 200,
            child: Row(
              children: [
                // 1. Pie Chart
                Expanded(
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse
                                .touchedSection!
                                .touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 0,
                      centerSpaceRadius: 40, // Biểu đồ rỗng ở giữa (Donut)
                      sections: _buildSections(),
                    ),
                  ),
                ),

                // 2. Legend (Chú thích)
                const SizedBox(width: 24),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.data.keys.map((status) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            color: _getColor(status),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "$status (${widget.data[status]?.toInt()})",
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    return List.generate(widget.data.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 60.0 : 50.0;

      final key = widget.data.keys.elementAt(i);
      final value = widget.data[key]!;
      final color = _getColor(key);

      return PieChartSectionData(
        color: color,
        value: value,
        title: '${value.toInt()}', // Hiển thị số lượng trên biểu đồ
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }
}
