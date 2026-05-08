package br.com.api.controller;

import br.com.api.dto.UserRequest;
import br.com.api.dto.UserResponse;
import br.com.api.entity.User;
import br.com.api.mapper.UserMapper;
import br.com.api.service.UserService;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/lumin/users")
@AllArgsConstructor
public class UserControllerImpl implements UserController{

    private final UserService service;

    @GetMapping("/")
    public ResponseEntity<List<UserResponse>> findAll(){

        return ResponseEntity.status(HttpStatus.OK).body(
                service.findAll()
                        .stream()
                        .map(UserMapper::toUserResponse)
                        .toList()
        );

    }

    @GetMapping("/{id}")
    public ResponseEntity<UserResponse> findById(@PathVariable Long id){

        return ResponseEntity.status(HttpStatus.OK).body(UserMapper.toUserResponse(service.findById(id)));

    }

    @PostMapping("/")
    public ResponseEntity<UserResponse> create(@RequestBody @Valid UserRequest request){

        return ResponseEntity.status(HttpStatus.CREATED).body(UserMapper.toUserResponse(service.create(UserMapper.toUser(request))));

    }


}
