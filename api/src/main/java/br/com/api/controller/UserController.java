package br.com.api.controller;

import br.com.api.dto.request.UserRequest;
import br.com.api.dto.response.UserResponse;
import br.com.api.dto.request.UserUpdateRequest;
import org.springframework.http.ResponseEntity;

import java.util.List;

public interface UserController {

    ResponseEntity<List<UserResponse>> findAll();
    ResponseEntity<UserResponse> findById(Long id);
    ResponseEntity<UserResponse> create(UserRequest request);
    ResponseEntity<UserResponse> update(Long id, UserUpdateRequest request);
    ResponseEntity<UserResponse> parcialUpdate(Long id, UserUpdateRequest request);
    ResponseEntity<Void> delete(Long id);

}
