package br.com.api.config;

import br.com.api.config.ApplicationControllerAdvice.Error;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.DispatcherType;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    public final SecurityFilter securityFilter;
    private final ObjectMapper mapper;

    /** Define rotas públicas e autenticadas, CORS, sessão stateless e a resposta padrão para requisições sem autenticação. */
    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        return http
                .csrf(csrf -> csrf.disable())
                .cors(Customizer.withDefaults())
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(a -> a
                        .dispatcherTypeMatchers(DispatcherType.ERROR).permitAll()
                        .requestMatchers(
                                HttpMethod.POST,
                                "/lumin/auth/register", "/lumin/auth/register/oauth", "/lumin/auth/login", "/lumin/auth/refresh", "/lumin/auth/logout", "/lumin/auth/verify", "/lumin/auth/resend", "/lumin/auth/oauth", "/lumin/auth/password/forgot", "/lumin/auth/password/reset")
                        .permitAll()
                        .requestMatchers("/lumin/languages/**").permitAll()
                        .requestMatchers(HttpMethod.GET, "/images/**", "/lumin/avatars/**").permitAll()
                        .requestMatchers(HttpMethod.GET, "/v3/api-docs/**", "/swagger-ui/**", "/actuator/health").permitAll()
                        .anyRequest().authenticated()
                )
                .addFilterBefore(securityFilter, UsernamePasswordAuthenticationFilter.class)
                .exceptionHandling(e -> e.authenticationEntryPoint(
                        ((request, response, authException) -> {
                            response.setStatus(401);
                            response.setContentType("application/json;charset=UTF-8");
                            mapper.writeValue(response.getWriter(), new Error("NOT_AUTHENTICATED", "Você não está autenticado", List.of()));
                        })
                ))
                .build();
    }

    /** Libera CORS apenas para leitura das imagens estáticas e dos avatares, usados direto pelo app via rede. */
    @Bean
    CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration publicAssets = new CorsConfiguration();
        publicAssets.addAllowedOriginPattern("*");
        publicAssets.setAllowedMethods(List.of("GET", "HEAD", "OPTIONS"));

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/images/**", publicAssets);
        source.registerCorsConfiguration("/lumin/avatars/**", publicAssets);
        return source;
    }

    @Bean
    AuthenticationManager authenticationManager(AuthenticationConfiguration authenticationConfiguration) throws Exception {
        return authenticationConfiguration.getAuthenticationManager();
    }

    @Bean
    PasswordEncoder passwordEncoder(){
        return new BCryptPasswordEncoder(10);
    }

}
