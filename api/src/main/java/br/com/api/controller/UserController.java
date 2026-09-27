package br.com.api.controller;

import br.com.api.dto.request.AvatarChangeRequest;
import br.com.api.dto.request.UserPutRequest;
import br.com.api.dto.request.UserRequest;
import br.com.api.dto.response.PageResponse;
import br.com.api.dto.response.UserResponse;
import br.com.api.dto.request.UserPatchRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;

public interface UserController {

    ResponseEntity<PageResponse<UserResponse>> findAll(Pageable pageable);
    ResponseEntity<UserResponse> findById(Long id);

}
