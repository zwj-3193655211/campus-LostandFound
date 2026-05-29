package com.campus.lostfound.modules.system.controller;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.runner.ApplicationContextRunner;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.client.RestTemplate;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;

class DbFixControllerConditionalTest {

    private ApplicationContextRunner contextRunner;

    @BeforeEach
    void setUp() {
        contextRunner = new ApplicationContextRunner()
                .withBean(JdbcTemplate.class, () -> mock(JdbcTemplate.class))
                .withBean(RestTemplate.class, () -> mock(RestTemplate.class))
                .withUserConfiguration(DbFixControllerTestConfiguration.class);
    }

    @Test
    void shouldNotRegisterControllerWhenPropertyIsDisabled() {
        contextRunner.run(context -> assertThat(context).doesNotHaveBean(DbFixController.class));
    }

    @Test
    void shouldRegisterControllerWhenPropertyIsEnabled() {
        contextRunner
                .withPropertyValues("app.db-fix-enabled=true")
                .run(context -> assertThat(context).hasSingleBean(DbFixController.class));
    }

    @Configuration(proxyBeanMethods = false)
    @Import(DbFixController.class)
    static class DbFixControllerTestConfiguration {
    }
}
