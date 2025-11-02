# Hướng dẫn CI Workflow với Vibe Coding

## Tổng quan
Hướng dẫn này mô tả quy trình CI/CD tự động cho dự án Salesforce sử dụng GitHub Actions, áp dụng các nguyên tắc và công cụ phù hợp với môi trường Vibe Coding.

## Cấu trúc Project

```
DEMO_VibeCoding/
├── .github/
│   └── workflows/
│       └── cicd.yml
├── force-app/
│   ├── main/
│   │   └── default/
│   │       ├── classes/
│   │       │   ├── TodoController.cls
│   │       │   ├── TodoController.cls-meta.xml
│   │       │   └── TodoControllerTest.cls
│   │       ├── lwc/
│   │       │   └── todoListCmp/
│   │       │       ├── todoListCmp.html
│   │       │       ├── todoListCmp.js
│   │       │       └── todoListCmp.js-meta.xml
│   │       └── objects/
│   │           └── Todo__c/
│   │               └── Todo__c.object-meta.xml
├── config/
│   └── project-scratch-def.json
├── sfdx-project.json
└── README.md
```

## Các Thành Phần Chính

### 1. File Workflow: `.github/workflows/cicd.yml`

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4

    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '20'

    - name: Install Salesforce CLI
      run: |
        curl https://developer.salesforce.com/media/salesforce-cli/sfdx/channels/stable/sfdx-linux-x64.tar.xz | tar xJf - -C /tmp
        sudo /tmp/sfdx/bin/sfdx --version

    - name: Install dependencies
      run: npm install

    - name: Deploy source to scratch org
      run: |
        sfdx org create scratch -f config/project-scratch-def.json -a scratch-org --set-default --duration-days 1
        sfdx project deploy start --source-dir force-app/main/default --target-org scratch-org

    - name: Run Apex tests
      run: |
        sfdx apex run test --class-names TodoControllerTest --target-org scratch-org --result-format human --code-coverage

    - name: Deploy to production (if on main branch)
      if: github.ref == 'refs/heads/main'
      run: |
        # Example deployment to production (replace with your prod org alias)
        # sfdx project deploy start --source-dir force-app/main/default --target-org prod-org
        echo "Deployment to production skipped in this demo"

    - name: Cleanup scratch org
      if: always()
      run: |
        sfdx org delete scratch -o scratch-org --noprompt
```

### 2. Các Bước Thực Thi

#### A. Trigger Events
- **Push**: Khi có commit lên branch `main`
- **Pull Request**: Khi tạo PR lên branch `main`

#### B. Build Job
1. **Checkout Code**: Lấy mã nguồn từ repo
2. **Setup Environment**: Cài đặt Node.js 20 và Salesforce CLI
3. **Install Dependencies**: Cài đặt các package cần thiết
4. **Deploy Source**: 
   - Tạo scratch org từ `project-scratch-def.json`
   - Deploy toàn bộ source lên scratch org
5. **Run Tests**:
   - Chạy test Apex `TodoControllerTest`
   - Báo cáo coverage
6. **Deploy to Production**: 
   - Chỉ chạy khi trên branch `main`
   - Mẫu: Chưa cấu hình thực tế
7. **Cleanup**: Xóa scratch org sau khi hoàn tất

## Yêu Cầu Hệ Thống

### Yêu cầu cơ bản
- Node.js 20+
- Git
- GitHub account
- Salesforce CLI (đã được cài đặt trong workflow)

### Cấu hình GitHub Secrets (nếu cần deploy lên production)
- `SFDC_AUTH_URL`: URL auth cho org production

## Cách Sử Dụng

### 1. Cấu Hình Repository
1. Tạo repository mới trên GitHub
2. Clone repo về local:
   ```bash
   git clone <your-repo-url>
   cd DEMO_VibeCoding
   ```

3. Copy các file đã tạo vào thư mục:
   - `.github/workflows/cicd.yml`
   - Các file Apex và LWC trong `force-app/`

4. Commit và push lên GitHub:
   ```bash
   git add .
   git commit -m "Setup CI/CD pipeline"
   git push origin main
   ```

### 2. Kiểm Tra Pipeline
1. Vào tab **Actions** trên GitHub repo
2. Chọn workflow **CI/CD Pipeline**
3. Theo dõi quá trình chạy:
   - Build
   - Test
   - Deploy

### 3. Kiểm Tra Kết Quả
- **Build Success**: Tất cả các bước chạy thành công
- **Test Coverage**: Báo cáo độ bao phủ test > 80%
- **Logs**: Xem chi tiết các bước trong workflow

## Các Lợi Ích

### 1. Tự Động Hóa
- Build, test, deploy tự động khi có thay đổi
- Giảm thiểu lỗi do con người
- Tiết kiệm thời gian phát triển

### 2. Đảm Bảo Chất Lượng
- Test tự động trước khi merge code
- Coverage > 80% cho Apex
- Kiểm tra chất lượng code

### 3. Dễ Dàng Triển Khai
- Cấu hình đơn giản
- Dễ dàng mở rộng cho các môi trường khác
- Tự động cleanup sau mỗi lần chạy

## Lưu Ý

### 1. Security
- Không commit các thông tin nhạy cảm
- Sử dụng GitHub Secrets cho các credential
- Kiểm tra các permission trên GitHub Actions

### 2. Performance
- Thời gian chạy pipeline khoảng 5-10 phút
- Tối ưu hóa các bước test nếu cần
- Sử dụng cache cho các dependency

### 3. Debugging
- Xem log chi tiết trong tab Actions
- Kiểm tra các bước thất bại
- Sử dụng `echo` để debug các bước phức tạp

## Extension

### Mở Rộng Pipeline
1. **Thêm môi trường khác**:
   ```yaml
   - name: Deploy to Sandbox
     if: github.ref == 'refs/heads/develop'
     run: |
       sfdx project deploy start --source-dir force-app/main/default --target-org sandbox-org
   ```

2. **Thêm kiểm tra code quality**:
   ```yaml
   - name: Run Code Analysis
     run: |
       # Thêm lệnh kiểm tra code quality
   ```

3. **Email notification**:
   ```yaml
   - name: Send Notification
     if: failure()
     run: |
       # Gửi email khi test thất bại
   ```

## Kết Luận

CI/CD Workflow này giúp:
- Tự động hóa toàn bộ quy trình phát triển Salesforce
- Đảm bảo chất lượng code thông qua test tự động
- Tăng tốc độ release và giảm lỗi
- Phù hợp với quy trình làm việc nhóm tại Vibe Coding

Hãy bắt đầu với việc push code lên GitHub để pipeline chạy tự động!
