package br.com.api.service;

import br.com.api.dto.request.UserRequest;
import br.com.api.dto.response.UserResponse;
import br.com.api.dto.request.UserUpdateRequest;

import java.util.List;

public interface UserService {

    List<UserResponse> findAll();
    UserResponse findById(Long id);
    UserResponse create(UserRequest request);
    UserResponse update(Long id, UserUpdateRequest request);
    UserResponse parcialUpdate(Long id, UserUpdateRequest request);
    void delete(Long id);

}
