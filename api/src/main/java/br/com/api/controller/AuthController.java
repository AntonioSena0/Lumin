package br.com.api.controller;

import br.com.api.dto.request.LoginRequest;
import br.com.api.dto.request.UserRequest;
import br.com.api.dto.response.UserResponse;
import org.springframework.http.ResponseEntity;

public interface AuthController {

    ResponseEntity<UserResponse> register(UserRequest request);
    ResponseEntity<Void> login(LoginRequest request);
    ResponseEntity<Void> refresh(String refresh);
    ResponseEntity<Void> logout(String refresh);

}
