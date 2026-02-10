Một vài biến môi trường hữu ích:
GOOS=linux – hệ điều hành đích (Linux)
GOARCH=amd64 – CPU 64-bit, dùng cho hầu hết server
GOARCH=arm64 – nếu chạy trên ARM (ví dụ Raspberry Pi, AWS Graviton)
Chạy trên Linux: ./pocketbase_linux serve --http="0.0.0.0:8090"