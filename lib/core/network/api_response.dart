/// 统一 API 响应包装类。
///
/// 业务层通过 [isSuccess] 判断成败：成功取 [data]，失败读
/// [errorMessage] / [statusCode]，避免在调用处重复 try-catch 与
/// 状态码判断，落实「统一异常响应处理」。
class ApiResponse<T> {
  const ApiResponse.success(this.data, {this.statusCode = 200})
      : isSuccess = true,
        errorMessage = null;

  const ApiResponse.failure(this.errorMessage, {this.statusCode})
      : isSuccess = false,
        data = null;

  final bool isSuccess;
  final T? data;
  final String? errorMessage;
  final int? statusCode;

  @override
  String toString() =>
      'ApiResponse(isSuccess: $isSuccess, statusCode: $statusCode, '
      'errorMessage: $errorMessage)';
}
