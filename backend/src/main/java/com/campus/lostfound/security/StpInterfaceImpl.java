package com.campus.lostfound.security;

import cn.dev33.satoken.stp.StpInterface;
import com.campus.lostfound.modules.system.entity.User;
import com.campus.lostfound.modules.system.service.UserService;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

/**
 * Sa-Token 权限验证接口实现
 * 每次请求 Sa-Token 会调用本类查用户的角色/权限,实现"实时权限校验"。
 *
 * 同时承担"禁用用户拦截"职责 - 原 JwtAuthenticationFilter 里的 user.status 检查
 * 现在在这里统一做,被禁用的用户拿不到任何角色,等价于被拒绝访问。
 */
@Component
public class StpInterfaceImpl implements StpInterface {

    private final UserService userService;

    public StpInterfaceImpl(UserService userService) {
        this.userService = userService;
    }

    @Override
    public List<String> getRoleList(Object loginId, String loginType) {
        User user = userService.getById((Long) loginId);
        if (user == null || user.getStatus() == 0) {
            return new ArrayList<>();
        }
        List<String> roleList = new ArrayList<>();
        String role = user.getRole();
        if (role != null && !role.isEmpty()) {
            // Spring Security 的 hasAnyRole("CAMPUS_ADMIN") 实际匹配 "ROLE_CAMPUS_ADMIN"
            roleList.add("ROLE_" + role);
        }
        return roleList;
    }

    @Override
    public List<String> getPermissionList(Object loginId, String loginType) {
        User user = userService.getById((Long) loginId);
        if (user == null || user.getStatus() == 0) {
            return new ArrayList<>();
        }

        List<String> permissionList = new ArrayList<>();
        String role = user.getRole();

        if ("SUPER_ADMIN".equals(role)) {
            permissionList.add("*");
        } else if ("ADMIN".equals(role)) {
            permissionList.add("user:view");
            permissionList.add("user:edit");
            permissionList.add("item:view");
            permissionList.add("item:audit");
            permissionList.add("match:view");
        } else {
            permissionList.add("item:view");
            permissionList.add("item:create");
            permissionList.add("item:edit");
            permissionList.add("item:delete");
            permissionList.add("match:view");
        }
        return permissionList;
    }
}
