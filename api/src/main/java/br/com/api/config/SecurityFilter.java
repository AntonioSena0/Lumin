package br.com.api.config;

import br.com.api.config.ApplicationControllerAdvice.Error;
import br.com.api.service.JwtService;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.jsonwebtoken.JwtException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

@Component
@RequiredArgsConstructor
public class SecurityFilter extends OncePerRequestFilter {

    private final JwtService jwtService;
    private final ObjectMapper mapper;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        String access = null;

        if(request.getCookies() != null){
            for(Cookie c : request.getCookies()){
                if("access".equals(c.getName())){
                    access = c.getValue(); break;
                }
            }
        }

        if(access != null && !access.isBlank()){
            try {
                Long userId = jwtService.getUserId(access);
                boolean verified = jwtService.isVerified(access);
                String path = request.getRequestURI();
                boolean free = path.startsWith("/lumin/auth/") || path.startsWith("/lumin/languages");
                if(!verified && !free) {
                    response.setStatus(403);
                    response.setContentType("application/json;charset=UTF-8");
                    mapper.writeValue(response.getWriter(), new Error("EMAIL_NOT_VERIFIED", "Email não verificado", List.of()));
                    return;
                }
                var auth = new UsernamePasswordAuthenticationToken(userId, null, List.of());
                SecurityContextHolder.getContext().setAuthentication(auth);
            } catch (JwtException e){
                SecurityContextHolder.clearContext();
            }
        }

        filterChain.doFilter(request, response);

    }

}
