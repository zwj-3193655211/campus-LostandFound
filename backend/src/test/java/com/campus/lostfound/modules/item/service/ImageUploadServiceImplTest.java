package com.campus.lostfound.modules.item.service;

import com.campus.lostfound.common.exception.BusinessException;
import com.campus.lostfound.modules.item.service.impl.ImageUploadServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.web.client.RestTemplate;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ImageUploadServiceImplTest {

    @Mock
    private RestTemplate restTemplate;

    private ImageUploadServiceImpl imageUploadService;

    @BeforeEach
    void setUp() {
        imageUploadService = new ImageUploadServiceImpl(
                restTemplate,
                "https://img.scdn.io/api/v1.php",
                "r2",
                "auto",
                ""
        );
    }

    @Test
    void shouldRejectEmptyFile() {
        MockMultipartFile file = new MockMultipartFile("image", "empty.png", "image/png", new byte[0]);

        BusinessException exception = assertThrows(BusinessException.class, () -> imageUploadService.upload(file));

        assertEquals("请选择要上传的图片", exception.getMessage());
    }

    @Test
    void shouldRejectOversizedFile() {
        byte[] content = new byte[10 * 1024 * 1024 + 1];
        MockMultipartFile file = new MockMultipartFile("image", "large.png", "image/png", content);

        BusinessException exception = assertThrows(BusinessException.class, () -> imageUploadService.upload(file));

        assertEquals("图片不能超过10MB", exception.getMessage());
    }

    @Test
    void shouldRejectUnsupportedMimeType() {
        MockMultipartFile file = new MockMultipartFile("image", "document.txt", "text/plain", "bad".getBytes());

        BusinessException exception = assertThrows(BusinessException.class, () -> imageUploadService.upload(file));

        assertEquals("仅支持 jpg/jpeg、png、webp、gif、bmp、tiff 格式；图片 MIME 类型不受支持", exception.getMessage());
    }

    @Test
    void shouldSurfaceRemoteErrorMessage() {
        MockMultipartFile file = new MockMultipartFile("image", "demo.png", "image/png", "png".getBytes());
        when(restTemplate.postForEntity(
                eq("https://img.scdn.io/api/v1.php"),
                any(HttpEntity.class),
                eq(Map.class)
        )).thenReturn(new ResponseEntity<>(Map.of(
                "success", false,
                "message", "请求过于频繁，请稍后再试。"
        ), HttpStatus.OK));

        BusinessException exception = assertThrows(BusinessException.class, () -> imageUploadService.upload(file));

        assertEquals("请求过于频繁，请稍后再试。", exception.getMessage());
    }

    @Test
    void shouldReturnNormalizedUploadResult() {
        MockMultipartFile file = new MockMultipartFile("image", "demo.png", "image/png", "png".getBytes());
        when(restTemplate.postForEntity(
                eq("https://img.scdn.io/api/v1.php"),
                any(HttpEntity.class),
                eq(Map.class)
        )).thenReturn(new ResponseEntity<>(Map.of(
                "success", true,
                "data", Map.of(
                        "url", "https://img.scdn.io/i/demo.webp",
                        "filename", "demo.webp",
                        "storage_backend", "r2"
                )
        ), HttpStatus.OK));

        Map<String, Object> result = imageUploadService.upload(file);

        assertEquals("https://img.scdn.io/i/demo.webp", result.get("url"));
        assertEquals("demo.webp", result.get("filename"));
        assertEquals("r2", result.get("storageBackend"));
    }
}
