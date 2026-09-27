package br.com.api.controller;

import br.com.api.dto.request.AvatarChangeRequest;
import br.com.api.dto.request.UserPutRequest;
import br.com.api.dto.request.UserRequest;
import br.com.api.dto.response.PageResponse;
import br.com.api.dto.response.UserResponse;
import br.com.api.dto.request.UserPatchRequest;
import br.com.api.service.UserService;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/lumin/users")
@AllArgsConstructor
public class UserControllerImpl implements UserController{

    private final UserService service;

    @Override
    @GetMapping
    public ResponseEntity<PageResponse<UserResponse>> findAll(
            @PageableDefault(sort = "id", direction = Sort.Direction.ASC) Pageable pageable
    ){

        return ResponseEntity.ok(PageResponse.from(service.findAll(pageable)));

    }

    @Override
    @GetMapping("/{id}")
    public ResponseEntity<UserResponse> findById(@PathVariable Long id){

        return ResponseEntity.ok(service.findById(id));

    }

    @Override
    @PostMapping("/")
    public ResponseEntity<UserResponse> create(@RequestBody @Valid UserRequest request){

        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));

    }

    @Override
    @PutMapping("/{id}")
    public ResponseEntity<UserResponse> update(@PathVariable Long id, @RequestBody @Valid UserPutRequest request){

        return ResponseEntity.ok(service.update(id, request));

    }

    @Override
    @PatchMapping("/{id}")
    public ResponseEntity<UserResponse> parcialUpdate(@PathVariable Long id, @RequestBody @Valid UserPatchRequest request){

        return ResponseEntity.ok(service.parcialUpdate(id, request));

    }

    @Override
    @PatchMapping("/{id}/change-avatar")
    public ResponseEntity<UserResponse> changeAvatar(@PathVariable Long id, @RequestBody @Valid AvatarChangeRequest request) {
        return ResponseEntity.ok(service.changeAvatar(id, request));
    }

    @Override
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id){

        service.delete(id);

        return ResponseEntity.status(HttpStatus.NO_CONTENT).build();

    }


}
