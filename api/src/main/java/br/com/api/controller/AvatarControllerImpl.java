package br.com.api.controller;

import br.com.api.dto.response.AvatarResponse;
import br.com.api.service.AvatarService;
import lombok.AllArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/lumin/avatars")
@AllArgsConstructor
public class AvatarControllerImpl implements AvatarController{

    private final AvatarService service;

    @Override
    @GetMapping("/")
    public ResponseEntity<List<AvatarResponse>> findAll() {
        return ResponseEntity.ok(service.findAll());
    }

    @Override
    @GetMapping("/{id}")
    public ResponseEntity<AvatarResponse> findById(@PathVariable Integer id) {
        return ResponseEntity.ok(service.findById(id));
    }
}
