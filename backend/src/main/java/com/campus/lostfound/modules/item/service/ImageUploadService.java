package com.campus.lostfound.modules.item.service;

import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

public interface ImageUploadService {

    Map<String, Object> upload(MultipartFile file);
}
