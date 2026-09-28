package br.com.api.controller;

import br.com.api.dto.request.*;
import br.com.api.dto.response.*;
import br.com.api.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseCookie;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import static org.springframework.http.HttpHeaders.SET_COOKIE;

@RestController
@RequestMapping("/lumin/auth")
public class AuthControllerImpl implements AuthController{

    private final AuthService service;
    private final boolean cookieSecure;

    public AuthControllerImpl(
            AuthService service,
            @Value("${cookie.secure}") boolean cookieSecure
    ){
        this.service = service;
        this.cookieSecure = cookieSecure;
    }

    @Override
    @PostMapping("/register")
    public ResponseEntity<UserMeResponse> register(@RequestBody @Valid UserRequest request) {

        AuthRegisterResponse authRegisterResponse = service.register(request);

        ResponseCookie accessToken = ResponseCookie
                .from("access", authRegisterResponse.tokenPair().access())
                .httpOnly(true).secure(cookieSecure)
                .sameSite("Lax")
                .path("/")
                .maxAge(900)
                .build();

        ResponseCookie refreshToken = ResponseCookie
                .from("refresh", authRegisterResponse.tokenPair().refreshJti())
                .httpOnly(true)
                .secure(cookieSecure)
                .sameSite("Lax")
                .path("/lumin/auth/refresh")
                .maxAge(604800)
                .build();

        return ResponseEntity.status(HttpStatus.CREATED)
                .header(SET_COOKIE, accessToken.toString())
                .header(SET_COOKIE, refreshToken.toString())
                .body(authRegisterResponse.userMeResponse());
    }

    @Override
    @PostMapping("/login")
    public ResponseEntity<Void> login(@RequestBody @Valid LoginRequest request) {

        TokenPair tokenPair = service.login(request);

        ResponseCookie accessToken = ResponseCookie
                .from("access", tokenPair.access())
                .httpOnly(true).secure(cookieSecure)
                .sameSite("Lax")
                .path("/")
                .maxAge(900)
                .build();

        ResponseCookie refreshToken = ResponseCookie
                .from("refresh", tokenPair.refreshJti())
                .httpOnly(true)
                .secure(cookieSecure)
                .sameSite("Lax")
                .path("/lumin/auth/refresh")
                .maxAge(604800)
                .build();

        return ResponseEntity.noContent()
                .header(SET_COOKIE, accessToken.toString())
                .header(SET_COOKIE, refreshToken.toString())
                .build();

    }

    @Override
    @PostMapping("/refresh")
    public ResponseEntity<Void> refresh(
            @CookieValue(name = "refresh", required = false) String refresh
    ) {
        TokenPair tokenPair = service.refresh(refresh);

        ResponseCookie accessToken = ResponseCookie
                .from("access", tokenPair.access())
                .httpOnly(true)
                .secure(cookieSecure)
                .sameSite("Lax")
                .path("/")
                .maxAge(900)
                .build();

        ResponseCookie refreshToken = ResponseCookie
                .from("refresh", tokenPair.refreshJti())
                .httpOnly(true)
                .secure(cookieSecure)
                .sameSite("Lax")
                .path("/lumin/auth/refresh")
                .maxAge(604800)
                .build();

        return ResponseEntity.noContent()
                .header(SET_COOKIE, accessToken.toString())
                .header(SET_COOKIE, refreshToken.toString())
                .build();
    }

    @Override
    @PostMapping("/logout")
    public ResponseEntity<Void> logout(
            @CookieValue(name = "refresh", required = false) String refresh
    ) {
        service.logout(refresh);

        ResponseCookie accessToken = ResponseCookie
                .from("access", "")
                .httpOnly(true)
                .secure(cookieSecure)
                .sameSite("Lax")
                .path("/")
                .maxAge(0)
                .build();

        ResponseCookie refreshToken = ResponseCookie
                .from("refresh", "")
                .httpOnly(true)
                .secure(cookieSecure)
                .sameSite("Lax")
                .path("/lumin/auth/refresh")
                .maxAge(0)
                .build();

        return ResponseEntity.noContent()
                .header(SET_COOKIE, accessToken.toString())
                .header(SET_COOKIE, refreshToken.toString())
                .build();
    }

    @Override
    @PostMapping("/oauth")
    public ResponseEntity<OAuthPendingResponse> oauth(@RequestBody @Valid OAuthRequest request) {

        OAuthResult result = service.oauth(request);

        if(result.tokens() != null){

            ResponseCookie access = ResponseCookie.from("access", result.tokens().access())
                    .httpOnly(true)
                    .secure(cookieSecure)
                    .sameSite("Lax")
                    .path("/")
                    .maxAge(900)
                    .build();

            ResponseCookie refresh = ResponseCookie.from("refresh", result.tokens().refreshJti())
                    .httpOnly(true)
                    .secure(cookieSecure)
                    .sameSite("Lax")
                    .path("/lumin/auth/refresh")
                    .maxAge(604800)
                    .build();

            return ResponseEntity.noContent()
                    .header(SET_COOKIE, access.toString())
                    .header(SET_COOKIE, refresh.toString())
                    .build();
        }

        return ResponseEntity.status(202).body(result.pendingResponse());
    }

    @Override
    @PostMapping("/register/oauth")
    public ResponseEntity<UserMeResponse> registerOAuth(@RequestBody @Valid UserOAuthRequest request) {

        AuthRegisterResponse authRegisterResponse = service.registerOAuth(request);

        ResponseCookie accessToken = ResponseCookie
                .from("access", authRegisterResponse.tokenPair().access())
                .httpOnly(true).secure(cookieSecure)
                .sameSite("Lax")
                .path("/")
                .maxAge(900)
                .build();

        ResponseCookie refreshToken = ResponseCookie
                .from("refresh", authRegisterResponse.tokenPair().refreshJti())
                .httpOnly(true)
                .secure(cookieSecure)
                .sameSite("Lax")
                .path("/lumin/auth/refresh")
                .maxAge(604800)
                .build();

        return ResponseEntity.status(HttpStatus.CREATED)
                .header(SET_COOKIE, accessToken.toString())
                .header(SET_COOKIE, refreshToken.toString())
                .body(authRegisterResponse.userMeResponse());

    }

    @Override
    @PostMapping("/verify")
    public ResponseEntity<Void> verify(@RequestBody @Valid VerifyRequest request) {
        service.verify(request);
        return ResponseEntity.noContent().build();
    }

    @Override
    @PostMapping("/resend")
    public ResponseEntity<Void> resend(@RequestBody @Valid ResendRequest request) {
        service.resend(request);
        return ResponseEntity.noContent().build();
    }
}
