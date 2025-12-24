import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Để format tiền tệ
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fithub_admin/configs/app_text_styles.dart';
import 'package:fithub_admin/configs/app_responsive.dart';
import 'package:fithub_admin/modules/dashboard/view_model/dashboard_view_model.dart';
import 'package:fithub_admin/modules/dashboard/view/widgets/fit_hub_stat_card.dart';
import 'package:fithub_admin/modules/dashboard/view/widgets/order_status_chart.dart'; // Import Chart
import 'package:fithub_admin/modules/dashboard/view/widgets/recent_orders_card.dart'; // Import List

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().initData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Dashboard", style: AppTextStyles.headingStyle(size: 28)),
            const SizedBox(height: 24),

            // 1. KPI Cards (Giữ nguyên)
            if (vm.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              _buildStatCards(vm),

            const SizedBox(height: 24),

            // 2. Chart & Recent Orders
            if (!vm.isLoading)
              isMobile
                  ? Column(
                      children: [
                        OrderStatusChart(data: vm.orderStatusMap),
                        const SizedBox(height: 24),
                        RecentOrdersCard(orders: vm.recentOrders),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Chart chiếm 4 phần
                        Expanded(
                          flex: 4,
                          child: OrderStatusChart(data: vm.orderStatusMap),
                        ),
                        const SizedBox(width: 24),
                        // List chiếm 6 phần
                        Expanded(
                          flex: 6,
                          child: RecentOrdersCard(orders: vm.recentOrders),
                        ),
                      ],
                    ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards(DashboardViewModel vm) {
    // Format tiền tệ
    final currencyFormat = NumberFormat("#,##0", "vi_VN");

    final cards = [
      FitHubStatCard(
        title: "Total Revenue",
        value: "${currencyFormat.format(vm.totalRevenue)} đ",
        icon: FontAwesomeIcons.dollarSign,
        color: Colors.blue,
      ),
      FitHubStatCard(
        title: "Total Orders",
        value: "${vm.totalOrders}",
        icon: FontAwesomeIcons.bagShopping,
        color: Colors.purple,
      ),
      FitHubStatCard(
        title: "New Orders",
        value: "${vm.newOrdersCount}",
        icon: FontAwesomeIcons.bell,
        color: Colors.orange,
      ),
      FitHubStatCard(
        title: "Total Products",
        value: "${vm.totalProducts}",
        icon: FontAwesomeIcons.boxOpen,
        color: Colors.green,
      ),
    ];

    // Responsive Layout
    if (Responsive.isMobile(context)) {
      // Mobile: Grid 2 cột
      return GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        shrinkWrap: true, // Quan trọng để nằm trong ScrollView
        physics: const NeverScrollableScrollPhysics(),
        // SỬA Ở ĐÂY:
        // Đổi từ 1.3 xuống 1.0 hoặc 1.1 để thẻ vuông vức hơn (cao hơn)
        // Điều này giúp nội dung bên trong không bị thiếu chỗ dọc
        childAspectRatio: 1.1,
        children: cards,
      );
    } else {
      // Web: Row 4 cột
      return Row(
        children: cards
            .map(
              (card) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: card,
                ),
              ),
            )
            .toList(),
      );
    }
  }
}
