package br.com.api.controller;

import br.com.api.dto.response.PageResponse;
import br.com.api.dto.response.UserResponse;
import br.com.api.service.UserService;
import lombok.AllArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
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


}
