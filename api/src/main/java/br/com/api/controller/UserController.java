package br.com.api.controller;

import br.com.api.dto.UserRequest;
import br.com.api.dto.UserResponse;
import org.springframework.http.ResponseEntity;

import java.util.List;

public interface UserController {

    ResponseEntity<List<UserResponse>> findAll();
    ResponseEntity<UserResponse> findById(Long id);
    ResponseEntity<UserResponse> create(UserRequest request);

}
