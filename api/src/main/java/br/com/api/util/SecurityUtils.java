package br.com.api.util;

import br.com.api.exception.UnauthorizedException;
import lombok.experimental.UtilityClass;
import org.springframework.security.core.context.SecurityContextHolder;

@UtilityClass
public class SecurityUtils {

    public static Long currentUserId(){
        var auth = SecurityContextHolder.getContext().getAuthentication();
        if(auth == null || !(auth.getPrincipal() instanceof Long id)){
            throw new UnauthorizedException();
        }
        return id;
    }

}
