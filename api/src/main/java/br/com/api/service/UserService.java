package br.com.api.service;

import br.com.api.dto.request.AvatarChangeRequest;
import br.com.api.dto.request.UserPutRequest;
import br.com.api.dto.request.UserRequest;
import br.com.api.dto.response.UserMeResponse;
import br.com.api.dto.response.UserResponse;
import br.com.api.dto.request.UserPatchRequest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface UserService {

    Page<UserResponse> findAll(Pageable pageable);
    UserResponse findById(Long id);
    UserMeResponse findMe(Long id);
    UserMeResponse create(UserRequest request);
    UserMeResponse update(Long id, UserPutRequest request);
    UserMeResponse parcialUpdate(Long id, UserPatchRequest request);
    UserMeResponse changeAvatar(Long id, AvatarChangeRequest request);
    void delete(Long id);
    void requestPasswordReset(Long id);
    void confirmPasswordReset(Long id, String code, String newPassword);

}
