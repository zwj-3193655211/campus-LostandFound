package com.campus.lostfound.security;

import cn.dev33.satoken.jwt.StpLogicJwtForStateless;
import cn.dev33.satoken.stp.StpLogic;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Sa-Token 配置类
 *
 * <p>使用 {@link StpLogicJwtForStateless}（无状态模式），而不是
 * {@code StpLogicJwtForSimple}。两者的区别:</p>
 * <ul>
 *   <li><b>Simple</b> —— token 虽然是 JWT，但 {@code getLoginIdByToken}
 *       仍然走父类 {@code StpLogic} 的 DAO（Redis）查找，且 DAO 里的
 *       {@code token→loginId} 用 {@code sa-token.timeout}（15 分钟）做 TTL。
 *       结果就是 JWT 签名没失效，Redis entry 却被悄悄清掉 → 返回 null →
 *       任何受保护接口 403。</li>
 *   <li><b>Stateless</b> —— 纯 JWT，{@code getLoginIdByToken} 直接走
 *       {@code SaJwtUtil.getLoginId} 校验签名 + {@code eff} 过期戳，DAO
 *       完全禁用（{@code getSaTokenDao()} 抛 {@code ApiDisabledException}）。
 *       Token 失效的唯一判据就是 JWT 自己的 {@code eff} claim。</li>
 * </ul>
 *
 * @author Campus LostFound
 */
@Configuration
public class SaTokenConfig {

    /**
     * Sa-Token 整合 JWT 模式（Stateless 纯无状态）
     */
    @Bean
    public StpLogic getStpLogicJwt() {
        return new StpLogicJwtForStateless();
    }
}
