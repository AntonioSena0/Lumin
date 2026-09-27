package br.com.api.controller;

import br.com.api.dto.request.AvatarChangeRequest;
import br.com.api.dto.request.UserPatchRequest;
import br.com.api.dto.request.UserPutRequest;
import br.com.api.dto.response.UserResponse;
import org.springframework.http.ResponseEntity;

public interface UserMeController {

    ResponseEntity<UserResponse> findById();
    ResponseEntity<UserResponse> update(UserPutRequest request);
    ResponseEntity<UserResponse> parcialUpdate(UserPatchRequest request);
    ResponseEntity<UserResponse> changeAvatar(AvatarChangeRequest request);
    ResponseEntity<Void> delete();

}
