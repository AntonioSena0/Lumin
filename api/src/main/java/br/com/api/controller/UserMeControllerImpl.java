package br.com.api.controller;

import br.com.api.dto.request.AvatarChangeRequest;
import br.com.api.dto.request.UserPatchRequest;
import br.com.api.dto.request.UserPutRequest;
import br.com.api.dto.response.UserResponse;
import br.com.api.service.UserService;
import br.com.api.util.SecurityUtils;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/lumin/me")
@AllArgsConstructor
public class UserMeControllerImpl implements UserMeController{

    private final UserService service;

    @Override
    @GetMapping
    public ResponseEntity<UserResponse> findById(){

        return ResponseEntity.ok(service.findById(SecurityUtils.currentUserId()));

    }

    @Override
    @PutMapping
    public ResponseEntity<UserResponse> update(@RequestBody @Valid UserPutRequest request){

        return ResponseEntity.ok(service.update(SecurityUtils.currentUserId(), request));

    }

    @Override
    @PatchMapping
    public ResponseEntity<UserResponse> parcialUpdate(@RequestBody @Valid UserPatchRequest request){

        return ResponseEntity.ok(service.parcialUpdate(SecurityUtils.currentUserId(), request));

    }

    @Override
    @PatchMapping("/change-avatar")
    public ResponseEntity<UserResponse> changeAvatar(@RequestBody @Valid AvatarChangeRequest request) {
        return ResponseEntity.ok(service.changeAvatar(SecurityUtils.currentUserId(), request));
    }

    @Override
    @DeleteMapping
    public ResponseEntity<Void> delete(){

        service.delete(SecurityUtils.currentUserId());

        return ResponseEntity.status(HttpStatus.NO_CONTENT).build();

    }

}
