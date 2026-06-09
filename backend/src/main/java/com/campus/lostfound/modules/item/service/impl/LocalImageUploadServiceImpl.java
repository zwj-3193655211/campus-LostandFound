package com.campus.lostfound.modules.item.service.impl;

import com.campus.lostfound.common.exception.BusinessException;
import com.campus.lostfound.modules.item.service.ImageUploadService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import jakarta.annotation.PostConstruct;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

@Service("localImageUploadService")
public class LocalImageUploadServiceImpl implements ImageUploadService {

    private static final Logger log = LoggerFactory.getLogger(LocalImageUploadServiceImpl.class);
    private static final long MAX_UPLOAD_SIZE_BYTES = 10L * 1024 * 1024;
    private static final Set<String> ALLOWED_CONTENT_TYPES = Set.of(
            "image/jpeg",
            "image/png",
            "image/webp",
            "image/gif",
            "image/bmp",
            "image/tiff"
    );
    private static final Set<String> ALLOWED_EXTENSIONS = Set.of(
            "jpg",
            "jpeg",
            "png",
            "webp",
            "gif",
            "bmp",
            "tif",
            "tiff"
    );

    private final String uploadPath;
    private final String baseUrl;

    public LocalImageUploadServiceImpl(
            @Value("${image-bed.local-upload-path:./uploads}") String uploadPath,
            @Value("${server.port:18090}") String serverPort) {
        this.uploadPath = uploadPath;
        this.baseUrl = "http://localhost:" + serverPort + "/uploads/images/";
    }

    @PostConstruct
    public void init() {
        try {
            Path path = Paths.get(uploadPath);
            if (!Files.exists(path)) {
                Files.createDirectories(path);
                log.info("创建图片上传目录: {}", path.toAbsolutePath());
            }
        } catch (IOException e) {
            log.error("创建图片上传目录失败: {}", e.getMessage());
            throw new RuntimeException("无法创建图片上传目录", e);
        }
    }

    @Override
    public Map<String, Object> upload(MultipartFile file) {
        log.info("开始本地上传图片：{}, 大小：{} bytes, 类型：{}",
                file.getOriginalFilename(), file.getSize(), file.getContentType());

        if (file == null || file.isEmpty()) {
            throw new BusinessException("请选择要上传的图片");
        }
        validateFile(file);

        try {
            String originalFilename = file.getOriginalFilename();
            String extension = getFileExtension(originalFilename);
            
            // 生成唯一文件名：时间戳 + UUID + 扩展名
            String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
            String uuid = UUID.randomUUID().toString().substring(0, 8);
            String newFilename = timestamp + "-" + uuid + "." + extension;

            // 创建日期子目录
            String dateDir = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy/MM"));
            Path targetDir = Paths.get(uploadPath, dateDir);
            if (!Files.exists(targetDir)) {
                Files.createDirectories(targetDir);
            }

            // 保存文件
            Path targetPath = targetDir.resolve(newFilename);
            Files.write(targetPath, file.getBytes());
            log.info("图片保存成功: {}", targetPath.toAbsolutePath());

            // 构建访问URL - 使用相对路径，前端会通过代理访问
        String url = "/api/uploads/images/" + dateDir + "/" + newFilename;

            Map<String, Object> result = new LinkedHashMap<>();
            result.put("url", url);
            result.put("filename", newFilename);
            result.put("storageBackend", "local");
            return result;

        } catch (IOException e) {
            log.error("保存图片失败：{}", e.getMessage());
            throw new BusinessException("保存图片失败");
        } catch (BusinessException e) {
            throw e;
        } catch (Exception e) {
            log.error("图片上传异常：{}", e.getMessage(), e);
            throw new BusinessException("图片上传失败，请稍后重试");
        }
    }

    private void validateFile(MultipartFile file) {
        if (file.getSize() > MAX_UPLOAD_SIZE_BYTES) {
            throw new BusinessException("图片不能超过 10MB");
        }

        String filename = file.getOriginalFilename();
        String contentType = file.getContentType();

        if (!isAllowedExtension(filename)) {
            throw new BusinessException("仅支持 jpg/jpeg、png、webp、gif、bmp、tiff 格式");
        }
        if (contentType == null || contentType.isBlank() || !ALLOWED_CONTENT_TYPES.contains(contentType.toLowerCase(Locale.ROOT))) {
            throw new BusinessException("图片 MIME 类型不受支持");
        }
    }

    private boolean isAllowedExtension(String filename) {
        if (filename == null || filename.isBlank() || !filename.contains(".")) {
            return false;
        }
        String extension = filename.substring(filename.lastIndexOf('.') + 1).toLowerCase(Locale.ROOT);
        return ALLOWED_EXTENSIONS.contains(extension);
    }

    private String getFileExtension(String filename) {
        if (filename == null || !filename.contains(".")) {
            return "png";
        }
        return filename.substring(filename.lastIndexOf('.') + 1).toLowerCase(Locale.ROOT);
    }
}
