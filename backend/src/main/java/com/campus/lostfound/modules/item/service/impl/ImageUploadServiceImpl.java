package com.campus.lostfound.modules.item.service.impl;

import com.campus.lostfound.common.exception.BusinessException;
import com.campus.lostfound.modules.item.service.ImageUploadService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

@Service
public class ImageUploadServiceImpl implements ImageUploadService {

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

    private final RestTemplate restTemplate;
    private final String uploadUrl;
    private final String storageDestination;
    private final String outputFormat;
    private final String cdnDomain;

    public ImageUploadServiceImpl(
            RestTemplate restTemplate,
            @Value("${image-bed.upload-url:https://img.scdn.io/api/v1.php}") String uploadUrl,
            @Value("${image-bed.storage-destination:r2}") String storageDestination,
            @Value("${image-bed.output-format:auto}") String outputFormat,
            @Value("${image-bed.cdn-domain:}") String cdnDomain) {
        this.restTemplate = restTemplate;
        this.uploadUrl = uploadUrl;
        this.storageDestination = storageDestination;
        this.outputFormat = outputFormat;
        this.cdnDomain = cdnDomain;
    }

    @Override
    @SuppressWarnings("unchecked")
    public Map<String, Object> upload(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new BusinessException("请选择要上传的图片");
        }
        validateFile(file);

        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.MULTIPART_FORM_DATA);

            MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
            body.add("image", asResource(file));
            body.add("storage_destination", storageDestination);
            body.add("outputFormat", outputFormat);
            if (cdnDomain != null && !cdnDomain.isBlank()) {
                body.add("cdn_domain", cdnDomain);
            }

            ResponseEntity<Map> response = restTemplate.postForEntity(
                    uploadUrl,
                    new HttpEntity<>(body, headers),
                    Map.class
            );

            Map responseBody = response.getBody();
            if (responseBody == null || !Boolean.TRUE.equals(responseBody.get("success"))) {
                throw new BusinessException(extractError(responseBody));
            }

            Map data = responseBody.get("data") instanceof Map ? (Map) responseBody.get("data") : Map.of();
            Object normalizedUrl = data.getOrDefault("url", responseBody.get("url"));
            if (!(normalizedUrl instanceof String) || ((String) normalizedUrl).isBlank()) {
                throw new BusinessException("图床未返回可用图片地址");
            }
            Map<String, Object> result = new LinkedHashMap<>();
            result.put("url", normalizedUrl);
            result.put("filename", data.get("filename"));
            result.put("storageBackend", data.get("storage_backend"));
            return result;
        } catch (IOException e) {
            throw new BusinessException("读取图片失败");
        } catch (BusinessException e) {
            throw e;
        } catch (Exception e) {
            throw new BusinessException("图片上传失败，请稍后重试");
        }
    }

    private void validateFile(MultipartFile file) {
        if (file.getSize() > MAX_UPLOAD_SIZE_BYTES) {
            throw new BusinessException("图片不能超过10MB");
        }

        String filename = file.getOriginalFilename();
        String contentType = file.getContentType();
        Set<String> errors = new HashSet<>();

        if (!isAllowedExtension(filename)) {
            errors.add("仅支持 jpg/jpeg、png、webp、gif、bmp、tiff 格式");
        }
        if (contentType == null || contentType.isBlank() || !ALLOWED_CONTENT_TYPES.contains(contentType.toLowerCase(Locale.ROOT))) {
            errors.add("图片 MIME 类型不受支持");
        }

        if (!errors.isEmpty()) {
            throw new BusinessException(String.join("；", errors));
        }
    }

    private ByteArrayResource asResource(MultipartFile file) throws IOException {
        return new ByteArrayResource(file.getBytes()) {
            @Override
            public String getFilename() {
                return file.getOriginalFilename();
            }
        };
    }

    private String extractError(Map responseBody) {
        if (responseBody == null) {
            return "图片上传失败";
        }
        Object message = responseBody.get("message");
        if (message instanceof String && !((String) message).isBlank()) {
            return (String) message;
        }
        Object error = responseBody.get("error");
        if (error instanceof String && !((String) error).isBlank()) {
            return (String) error;
        }
        return "图片上传失败";
    }

    private boolean isAllowedExtension(String filename) {
        if (filename == null || filename.isBlank() || !filename.contains(".")) {
            return false;
        }
        String extension = filename.substring(filename.lastIndexOf('.') + 1).toLowerCase(Locale.ROOT);
        return ALLOWED_EXTENSIONS.contains(extension);
    }
}
