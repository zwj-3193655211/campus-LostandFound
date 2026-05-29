package com.campus.lostfound.modules.item.controller;

import com.campus.lostfound.common.result.ApiResponse;
import com.campus.lostfound.modules.item.service.ImageUploadService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.Map;

@RestController
@RequestMapping("/api/uploads")
public class ImageUploadController {

    private final ImageUploadService imageUploadService;

    public ImageUploadController(ImageUploadService imageUploadService) {
        this.imageUploadService = imageUploadService;
    }

    @PostMapping("/images")
    public ApiResponse<Map<String, Object>> uploadImage(@RequestParam("image") MultipartFile image) {
        return ApiResponse.success(imageUploadService.upload(image));
    }
}
