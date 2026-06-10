package com.campus.lostfound.common.exception;

import com.campus.lostfound.common.result.ApiResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.validation.BindException;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/**
 * 全局异常处理器
 */
@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @Value("${app.debug-errors:false}")
    private boolean debugErrors;

    @ExceptionHandler(BusinessException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ApiResponse<Void> handleBusinessException(BusinessException e) {
        log.error("业务异常: {}", e.getMessage());
        return ApiResponse.error(e.getCode(), e.getMessage());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ApiResponse<Void> handleValidationException(MethodArgumentNotValidException e) {
        String message = e.getBindingResult().getFieldError() != null
                ? e.getBindingResult().getFieldError().getDefaultMessage()
                : "参数校验失败";
        log.error("参数校验异常: {}", message);
        return ApiResponse.error(400, message);
    }

    @ExceptionHandler(BindException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ApiResponse<Void> handleBindException(BindException e) {
        String message = e.getBindingResult().getFieldError() != null
                ? e.getBindingResult().getFieldError().getDefaultMessage()
                : "参数绑定失败";
        log.error("参数绑定异常: {}", message);
        return ApiResponse.error(400, message);
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ApiResponse<Void> handleHttpMessageNotReadableException(HttpMessageNotReadableException e) {
        String rawMessage = e.getMostSpecificCause() != null
                ? e.getMostSpecificCause().getMessage()
                : e.getMessage();
        String message = rawMessage != null && rawMessage.contains("LocalDateTime")
                ? "时间格式不正确，请使用 yyyy-MM-dd HH:mm:ss"
                : "请求体格式不正确: " + rawMessage;
        log.error("请求体解析异常: {}", rawMessage);
        return ApiResponse.error(400, message);
    }

    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ApiResponse<Void> handleMethodArgumentTypeMismatchException(MethodArgumentTypeMismatchException e) {
        String message = String.format("参数 %s 格式不正确", e.getName());
        log.error("参数类型异常: {}", message);
        return ApiResponse.error(400, message);
    }

    @ExceptionHandler(MissingServletRequestParameterException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ApiResponse<Void> handleMissingServletRequestParameterException(MissingServletRequestParameterException e) {
        String message = String.format("参数 %s 不能为空", e.getParameterName());
        log.error("缺少请求参数: {}", message);
        return ApiResponse.error(400, message);
    }

    /**
     * 把 DB 层 UNIQUE 约束冲突翻译成 400 + 友好消息。
     * 这样 users.email_active / users.username 等唯一键冲突不会再返回 500。
     * 主要针对 users.uk_users_email_active 和 users.idx_username (DB 层唯一约束)。
     */
    @ExceptionHandler(DuplicateKeyException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ApiResponse<Void> handleDuplicateKey(DuplicateKeyException e) {
        String msg = e.getMessage() == null ? "" : e.getMessage();
        if (msg.contains("uk_users_email_active") || msg.toLowerCase().contains("email")) {
            log.warn("邮箱唯一约束冲突: {}", msg);
            return ApiResponse.error(400, "邮箱已被其他用户使用");
        }
        if (msg.contains("username") || msg.contains("uk_users_username") || msg.contains("idx_username")) {
            log.warn("用户名唯一约束冲突: {}", msg);
            return ApiResponse.error(400, "用户名已存在");
        }
        log.warn("数据库唯一约束冲突: {}", msg);
        return ApiResponse.error(400, "数据已存在,无法重复操作");
    }

    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public ApiResponse<Void> handleException(Exception e) {
        log.error("系统异常", e);
        if (debugErrors) {
            String message = e.getClass().getSimpleName() + ": " + String.valueOf(e.getMessage());
            return ApiResponse.error(500, message);
        }
        return ApiResponse.error("系统异常，请稍后重试");
    }
}
