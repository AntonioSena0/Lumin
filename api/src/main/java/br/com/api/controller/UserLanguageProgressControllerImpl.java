package br.com.api.controller;

import br.com.api.dto.response.UserLanguageProgressResponse;
import br.com.api.service.UserLanguageProgressService;
import lombok.AllArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/lumin/progress")
@AllArgsConstructor
public class UserLanguageProgressControllerImpl implements UserLanguageProgressController{

    private final UserLanguageProgressService service;

    @Override
    @GetMapping("/{userId}/{languageId}")
    public ResponseEntity<UserLanguageProgressResponse> findById(@PathVariable Long userId, @PathVariable Integer languageId){
        return ResponseEntity.ok(service.findById(userId, languageId));
    }

    @Override
    @GetMapping("/{userId}")
    public ResponseEntity<List<UserLanguageProgressResponse>> findByUserId(@PathVariable Long userId){
        return ResponseEntity.ok(service.findByUserId(userId));
    }

    @Override
    @PostMapping("/{userId}/{languageId}")
    public ResponseEntity<UserLanguageProgressResponse> getOrCreate(@PathVariable Long userId, @PathVariable Integer languageId){
        return ResponseEntity.status(HttpStatus.CREATED).body(service.getOrCreate(userId, languageId));
    }

}
