package br.com.api.service;

import br.com.api.dto.request.AvatarChangeRequest;
import br.com.api.dto.request.UserPutRequest;
import br.com.api.dto.request.UserRequest;
import br.com.api.dto.response.UserResponse;
import br.com.api.dto.request.UserPatchRequest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface UserService {

    Page<UserResponse> findAll(Pageable pageable);
    UserResponse findById(Long id);
    UserResponse create(UserRequest request);
    UserResponse update(Long id, UserPutRequest request);
    UserResponse parcialUpdate(Long id, UserPatchRequest request);
    UserResponse changeAvatar(Long id, AvatarChangeRequest request);
    void delete(Long id);

}
