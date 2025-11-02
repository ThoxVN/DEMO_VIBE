# Các Nguyên Tắc Tốt Nhất Cho Prompt Phát Triển Salesforce

## Tổng Quan
Tài liệu này trình bày các nguyên tắc tốt nhất để tạo ra các prompt hiệu quả khi làm việc với phát triển hỗ trợ AI cho các dự án Salesforce. Các nguyên tắc này giúp đảm bảo tạo ra mã nguồn chất lượng cao, an toàn và có hiệu suất tốt.

## Nguyên Tắc Bảo Mật

### 1. Xác Thực Đầu Vào
Luôn chỉ định rằng mã nguồn được tạo ra phải bao gồm xác thực đầu vào thích hợp:
```
Đảm bảo tất cả đầu vào người dùng đều được xác thực và làm sạch trước khi xử lý.
Sử dụng các kỹ thuật escape và xác thực thích hợp để ngăn chặn các cuộc tấn công tiêm lệnh.
```

### 2. Mẫu Lập Trình An Toàn
```
Tuân thủ các nguyên tắc bảo mật Salesforce:
- Sử dụng annotation @AuraEnabled một cách thích hợp
- Triển khai xử lý lỗi thích hợp mà không tiết lộ thông tin nhạy cảm
- Tránh các thông tin đăng nhập hoặc bí mật được cứng hóa
- Sử dụng truy vấn có tham số để ngăn chặn SOQL injection
```

### 3. Kiểm Soát Truy Cập
```
Triển khai kiểm tra quyền truy cập thích hợp:
- Xác thực quyền người dùng trước khi thực hiện các thao tác
- Sử dụng các mô hình chia sẻ thích hợp
- Đảm bảo sự cách ly dữ liệu giữa các người dùng
```

## Nguyên Tắc Tối Ưu Hóa Hiệu Suất

### 1. Tối Ưu Truy Vấn
```
Tối ưu hóa truy vấn cơ sở dữ liệu:
- Sử dụng truy vấn SOQL chọn lọc với các mệnh đề WHERE thích hợp
- Tránh các vấn đề truy vấn N+1
- Sử dụng các mệnh đề LIMIT khi cần thiết
- Giảm thiểu số lượng truy vấn trong vòng lặp
```

### 2. Quản Lý Bộ Nhớ
```
Tối ưu hóa sử dụng bộ nhớ:
- Sử dụng cấu trúc dữ liệu hiệu quả (Set, Map, List)
- Xử lý dữ liệu theo lô khi làm việc với tập dữ liệu lớn
- Tránh sao chép đối tượng không cần thiết
- Dọn dẹp biến khi không còn cần thiết
```

### 3. Hướng Dẫn Hiệu Suất Apex
```
Tuân thủ các nguyên tắc hiệu suất Apex:
- Giảm thiểu các thao tác DML
- Sử dụng các mẫu bulk-safe
- Tránh các câu lệnh DML không cần thiết bên trong vòng lặp
- Sử dụng các phương thức Database.insert/update/delete cho các thao tác hàng loạt
- Triển khai xử lý ngoại lệ thích hợp
```

## Chất Lượng Mã và Khả Năng Duy Trì

### 1. Nguyên Tắc Lập Trình Sạch
```
Viết mã sạch, dễ đọc:
- Sử dụng tên biến và phương thức mô tả rõ ràng
- Tuân thủ quy tắc đặt tên của Salesforce
- Bao gồm tài liệu hóa thích hợp với JavaDoc
- Giữ các phương thức tập trung và nhỏ gọn
- Tránh trùng lặp mã
```

### 2. Phủ Sóng Kiểm Thử
```
Đảm bảo phủ sóng kiểm thử toàn diện:
- Viết kiểm thử đơn vị cho tất cả logic kinh doanh
- Kiểm tra các trường hợp biên và điều kiện lỗi
- Đạt mức phủ sóng mã tối thiểu 75%
- Bao gồm các lớp kiểm thử cho tất cả các lớp Apex
```

### 3. Xử Lý Lỗi
```
Triển khai xử lý lỗi mạnh mẽ:
- Sử dụng khối try-catch một cách thích hợp
- Ghi nhật ký lỗi với các thông báo có ý nghĩa
- Cung cấp các thông báo lỗi thân thiện với người dùng
- Xử lý các ngoại lệ một cách lịch sự
```

## Hướng Dẫn Kỹ Thuật Prompt

### 1. Tính Cụ Thể
Hãy cụ thể về các yêu cầu:
- Xác định rõ chức năng mong muốn
- Chỉ định các ràng buộc và giới hạn
- Nêu rõ mã hiện có cần tích hợp
- Định nghĩa đầu ra và hành vi mong đợi

### 2. Nhận Thức Bối Cảnh
Cung cấp đủ bối cảnh:
- Tham chiếu đến các tệp và mẫu mã hiện có
- Giải thích mục đích và trường hợp sử dụng
- Nêu rõ yêu cầu hiệu suất
- Chỉ ra các yếu tố bảo mật

### 3. Tinh Tế Hóa Từng Bước
```
Cấu trúc prompt mẫu:
1. Phát biểu vấn đề
2. Đặc tả yêu cầu
3. Ràng buộc và giới hạn
4. Kết quả mong đợi
5. Tiêu chí chất lượng
```

### 4. Mẫu Prompt Ví Dụ
```
Tạo một lớp Apex Salesforce mà [chức năng cụ thể].
Yêu cầu:
- Phải là [mức độ bảo mật]
- Nên đạt [mục tiêu hiệu suất]
- Phải tuân theo [tiêu chuẩn lập trình]
- Cần tích hợp với [thành phần/dịch vụ hiện có]
- Nên xử lý [trường hợp biên]

Nguyên tắc tốt nhất cần tuân theo:
- [Nguyên tắc bảo mật]
- [Tối ưu hóa hiệu suất]
- [Tiêu chuẩn chất lượng mã]
```

## Tự Động Sinh Kiểm Thử

### 1. Yêu Cầu Phủ Sóng Kiểm Thử
```
Tạo kiểm thử đơn vị toàn diện bao gồm:
- Các tình huống bình thường
- Các trường hợp biên
- Điều kiện lỗi
- Giá trị ranh giới
- Các điểm tích hợp
```

### 2. Cấu Trúc Kiểm Thử
```
Mỗi kiểm thử nên tuân theo mẫu AAA:
- Arrange: Chuẩn bị dữ liệu kiểm thử
- Act: Thực thi phương thức cần kiểm thử
- Assert: Xác minh kết quả mong đợi
```

### 3. Tự Động Hóa Kiểm Thử
```
Tự động tạo kiểm thử cho:
- Tất cả các phương thức công khai
- Logic kinh doanh quan trọng
- Các đường dẫn xử lý ngoại lệ
- Các điểm tích hợp
```

## Kỹ Thuật Tối Ưu Hóa Hiệu Suất

### 1. Các Thao Tác Hàng Loạt
```
Triển khai các mẫu bulk-safe:
- Xử lý dữ liệu theo lô
- Sử dụng bộ sưu tập một cách hiệu quả
- Giảm thiểu các lượt truy cập cơ sở dữ liệu
- Tận dụng API hàng loạt của Salesforce khi cần thiết
```

### 2. Chiến Lược Cache
```
Triển khai cache thông minh:
- Cache các phép tính tốn kém
- Sử dụng biến tạm thời một cách khôn ngoan
- Triển khai chiến lược invalidation cache
- Xem xét ảnh hưởng đến sử dụng bộ nhớ
```

### 3. Xử Lý Bất Đồng Bộ
```
Sử dụng các mẫu xử lý bất đồng bộ khi thích hợp:
- Queueable Apex cho các quy trình chạy lâu
- Phương thức Future cho các thao tác độc lập
- Scheduled Apex cho các tác vụ định kỳ
```

## Giám Sát và Gỡ Lỗi

### 1. Nguyên Tắc Nhật Ký
```
Triển khai nhật ký thích hợp:
- Ghi lại thông tin debug có ý nghĩa
- Sử dụng các cấp độ nhật ký thích hợp
- Tránh ghi nhật ký thông tin nhạy cảm
- Bao gồm thông tin bối cảnh trong nhật ký
```

### 2. Hỗ Trợ Gỡ Lỗi
```
Bao gồm các công cụ hỗ trợ gỡ lỗi:
- Thông báo lỗi thích hợp
- Thông tin chẩn đoán
- Chỉ số hiệu suất khi cần thiết
- Sự tách biệt rõ ràng về các mối quan hệ
```

## Tuân Thủ và Tiêu Chuẩn

### 1. Tiêu Chuẩn Salesforce
```
Tuân thủ các tiêu chuẩn Salesforce:
- Tuân thủ quy tắc lập trình Force.com
- Sử dụng các định dạng metadata thích hợp
- Tuân thủ giới hạn governor
- Tuân thủ các nguyên tắc nền tảng
```

### 2. Tiêu Chuẩn Ngành
```
Duy trì các nguyên tắc tốt nhất ngành:
- Tuân thủ các nguyên tắc SOLID khi cần thiết
- Triển khai lập trình phòng vệ
- Đảm bảo khả năng duy trì mã
- Xem xét khả năng mở rộng từ đầu
```

## Quy Trình Đánh Giá và Cải Tiến

### 1. Cải Tiến Liên Tục
```
Đánh giá và cải tiến định kỳ:
- Hiệu quả của prompt
- Chất lượng mã được tạo ra
- Chỉ số hiệu suất
- Tình trạng bảo mật
```

### 2. Vòng Lặp Phản Hồi
```
Thiết lập cơ chế phản hồi:
- Kiểm tra mã cho mã được tạo ra
- Giám sát hiệu suất
- Kiểm toán bảo mật
- Tích hợp phản hồi người dùng
```

## Kết Luận
Việc tuân thủ các nguyên tắc prompt tốt nhất này đảm bảo rằng phát triển hỗ trợ AI tạo ra mã Salesforce an toàn, có hiệu suất và dễ duy trì đáp ứng các tiêu chuẩn và yêu cầu doanh nghiệp.
