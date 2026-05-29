package com.campus.lostfound;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan({"com.campus.lostfound.**.repository", "com.campus.lostfound.**.mapper"})
public class CampusLostFoundApplication {
    public static void main(String[] args) {
        SpringApplication.run(CampusLostFoundApplication.class, args);
    }
}