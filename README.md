# FitHub Admin

Ứng dụng quản trị viên Flutter cho nền tảng thương mại điện tử sản phẩm thể dục FitHub. Ứng dụng cung cấp giao diện quản lý toàn diện cho việc quản lý sản phẩm, danh mục, đơn hàng và theo dõi thống kê kinh doanh.

## 📋 Mục lục

- [Tính năng chính](#tính-năng-chính)
- [Công nghệ sử dụng](#công-nghệ-sử-dụng)
- [Kiến trúc dự án](#kiến-trúc-dự-án)
- [Cấu trúc thư mục](#cấu-trúc-thư-mục)
- [Thiết lập môi trường](#thiết-lập-môi-trường)
- [Cài đặt và chạy](#cài-đặt-và-chạy)
- [API Backend](#api-backend)
- [Đóng góp](#đóng-góp)

## 🚀 Tính năng chính

### 🏠 Dashboard
- Thống kê tổng quan (số lượng sản phẩm, đơn hàng, doanh thu)
- Biểu đồ trạng thái đơn hàng (pie chart)
- Danh sách đơn hàng gần đây
- Card thống kê với biểu tượng trực quan

### 📦 Quản lý sản phẩm
- **Xem danh sách sản phẩm** với phân trang
- **Thêm mới sản phẩm** với upload hình ảnh
- **Chỉnh sửa sản phẩm** với form validation
- **Xóa sản phẩm** với xác nhận
- **Tìm kiếm và lọc** sản phẩm
- **Quản lý tags** (Shoes, Clothes, Accessories)
- **Upload nhiều hình ảnh** với preview

### 📂 Quản lý danh mục
- Xem danh sách danh mục
- Thêm/sửa/xóa danh mục
- Dialog form với validation

### 📋 Quản lý đơn hàng
- Xem danh sách đơn hàng
- Chi tiết đơn hàng với dialog popup
- Theo dõi trạng thái đơn hàng
- Thông tin khách hàng và sản phẩm

### 👤 Hồ sơ người dùng
- Xem thông tin cá nhân
- Đổi mật khẩu
- Quản lý token xác thực

### 🔐 Xác thực
- Đăng nhập với JWT token
- Lưu trữ token an toàn
- Tự động điều hướng dựa trên trạng thái đăng nhập

## 🛠 Công nghệ sử dụng

### Core Framework
- **Flutter** ^3.9.0 - Framework chính cho UI
- **Dart** ^3.9.0 - Ngôn ngữ lập trình

### State Management
- **Provider** ^6.1.5+1 - State management pattern

### Navigation
- **Go Router** ^17.0.1 - Declarative routing
- **url_strategy** ^0.3.0 - Clean URLs cho web

### Networking
- **Dio** ^5.9.0 - HTTP client
- **JWT Decoder** ^2.0.1 - Decode JWT tokens

### UI Components
- **Font Awesome Flutter** ^10.7.0 - Icons
- **Google Fonts** ^6.1.0 - Typography (Plus Jakarta Sans, Manrope)
- **Flutter SVG** ^2.2.3 - SVG support
- **Image Picker** ^1.0.7 - Image selection
- **Dotted Border** ^2.1.0 - UI decorations
- **FL Chart** ^0.68.0 - Charts and graphs

### Storage
- **Shared Preferences** ^2.2.2 - Local storage cho tokens

### Development
- **Flutter Lints** ^5.0.0 - Code quality
- **Intl** ^0.20.2 - Internationalization

## 🏗 Kiến trúc dự án

### Design Pattern: MVVM (Model-View-ViewModel)

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│      View       │    │   ViewModel     │    │     Model       │
│                 │    │                 │    │                 │
│  - UI Widgets   │◄──►│  - Business     │◄──►│  - Data Models  │
│  - User Events  │    │    Logic        │    │  - API Response │
│  - State Display│    │  - State Mgmt   │    │  - Serialization│
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Layered Architecture

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│  ├── Views (Screens & Widgets)      │
│  ├── ViewModels (Business Logic)    │
│  └── Routes (Navigation)            │
├─────────────────────────────────────┤
│         Business Logic Layer        │
│  ├── Services (API Calls)           │
│  ├── Models (Data Structures)       │
│  └── Utils (Helpers)                │
├─────────────────────────────────────┤
│          Data Layer                 │
│  ├── API Services (HTTP Client)     │
│  ├── Local Storage (Preferences)    │
│  └── Token Management               │
└─────────────────────────────────────┘
```

### Responsive Design
- **Web**: Sidebar navigation cho desktop
- **Mobile**: Drawer navigation cho mobile
- **Adaptive Layout**: Tự động điều chỉnh theo screen size

## 📁 Cấu trúc thư mục

```
lib/
├── main.dart                          # Entry point
├── configs/                           # Configuration files
│   ├── app_config.dart                # API URLs, timeouts
│   ├── app_colors.dart                # Color palette
│   ├── app_text_styles.dart           # Typography
│   ├── app_theme.dart                 # Theme configuration
│   ├── menu_config.dart               # Navigation menu items
│   └── app_responsive.dart            # Responsive utilities
├── core/                              # Core functionality
│   ├── components/                    # Reusable UI components
│   │   ├── common/                    # Common widgets
│   │   └── layout/                    # Layout components
│   └── utils/                         # Utilities
│       └── token_manager.dart         # JWT token management
├── data/                              # Data layer
│   ├── models/                        # Data models
│   │   ├── product_model.dart         # Product entity
│   │   ├── category_model.dart        # Category entity
│   │   ├── order_model.dart           # Order entity
│   │   ├── user_model.dart            # User entity
│   │   ├── product_tag.dart           # Product tags
│   │   └── auth_model.dart            # Authentication
│   ├── services/                      # API services
│   │   ├── api_service.dart           # Base API client
│   │   ├── product_service.dart       # Product CRUD
│   │   ├── category_service.dart      # Category CRUD
│   │   ├── order_service.dart         # Order management
│   │   ├── user_service.dart          # User management
│   │   └── auth_service.dart          # Authentication
│   └── mocks/                         # Mock data for testing
├── modules/                           # Feature modules
│   ├── auth/                          # Authentication module
│   ├── dashboard/                     # Dashboard module
│   ├── management/                    # Management modules
│   └── profile/                       # User profile module
├── routes/                            # Navigation routes
│   └── app_routes.dart                # Route definitions
└── assets/                            # Static assets
    └── icons/                         # SVG icons
```

## 🔧 Thiết lập môi trường

### Yêu cầu hệ thống
- **Flutter SDK**: ^3.9.0
- **Dart SDK**: ^3.9.0
- **Android Studio** hoặc **VS Code** với Flutter extension
- **Android SDK** (cho Android development)
- **Xcode** (cho iOS development trên macOS)

### Cài đặt Flutter
```bash
# Kiểm tra Flutter đã cài đặt
flutter doctor

# Nếu chưa có Flutter, cài đặt từ:
# https://flutter.dev/docs/get-started/install
```

## 🚀 Cài đặt và chạy

### 1. Clone repository
```bash
git clone https://github.com/trinhhung12345/fithub_admin.git
cd fithub_admin
```

### 2. Cài đặt dependencies
```bash
flutter pub get
```

### 3. Kiểm tra thiết bị
```bash
# Android
flutter devices

# Web
flutter devices
```

### 4. Chạy ứng dụng

#### Chạy trên Android:
```bash
flutter run
```

#### Chạy trên Web:
```bash
flutter run -d chrome
```

#### Build APK Debug:
```bash
flutter build apk --debug
```

#### Build APK Release:
```bash
flutter build apk --release
```

#### Build Web:
```bash
flutter build web
```

### 5. Kiểm tra code quality
```bash
# Format code
flutter format lib/

# Analyze code
flutter analyze

# Run tests
flutter test
```

## 🔗 API Backend

Ứng dụng kết nối với backend Spring Boot thông qua REST API:

- **Base URL**: `https://mobile-backend-x50a.onrender.com/api/v1`
- **Authentication**: JWT Bearer Token
- **HTTP Client**: Dio với timeout configuration
- **Data Format**: JSON

### API Endpoints chính:
- `GET /products` - Lấy danh sách sản phẩm
- `POST /products` - Tạo sản phẩm mới
- `PUT /products/{id}` - Cập nhật sản phẩm
- `DELETE /products/{id}` - Xóa sản phẩm
- `GET /categories` - Lấy danh sách danh mục
- `GET /orders` - Lấy danh sách đơn hàng
- `POST /auth/login` - Đăng nhập

## 🤝 Đóng góp

### Quy trình đóng góp:
1. Fork repository
2. Tạo feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Tạo Pull Request

### Coding Standards:
- Sử dụng `flutter format` để format code
- Chạy `flutter analyze` để kiểm tra linting
- Viết unit tests cho business logic
- Sử dụng meaningful commit messages

### Branch Strategy:
- `main` - Production ready code
- `develop` - Development branch
- `feature/*` - Feature branches
- `bugfix/*` - Bug fix branches

## 📄 License

This project is private and proprietary.

## 📞 Liên hệ

- **Repository**: [GitHub](https://github.com/trinhhung12345/fithub_admin)
- **Issues**: [GitHub Issues](https://github.com/trinhhung12345/fithub_admin/issues)

---

*Built with ❤️ using Flutter*
