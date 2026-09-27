package br.com.api.controller;

import br.com.api.dto.request.AvatarChangeRequest;
import br.com.api.dto.request.UserPatchRequest;
import br.com.api.dto.request.UserPutRequest;
import br.com.api.dto.response.UserMeResponse;
import br.com.api.dto.response.UserResponse;
import org.springframework.http.ResponseEntity;

public interface UserMeController {

    ResponseEntity<UserMeResponse> findById();
    ResponseEntity<UserMeResponse> update(UserPutRequest request);
    ResponseEntity<UserMeResponse> parcialUpdate(UserPatchRequest request);
    ResponseEntity<UserMeResponse> changeAvatar(AvatarChangeRequest request);
    ResponseEntity<Void> delete();

}
