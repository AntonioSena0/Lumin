package br.com.api.controller;

import br.com.api.dto.response.UserLanguageProgressResponse;
import br.com.api.service.UserLanguageProgressService;
import br.com.api.util.SecurityUtils;
import lombok.AllArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/lumin/me/progress")
@AllArgsConstructor
public class UserLanguageProgressControllerImpl implements UserLanguageProgressController{

    private final UserLanguageProgressService service;

    @Override
    @GetMapping("/{languageId}")
    public ResponseEntity<UserLanguageProgressResponse> findById(@PathVariable Integer languageId){
        return ResponseEntity.ok(service.findById(SecurityUtils.currentUserId(), languageId));
    }

    @Override
    @GetMapping
    public ResponseEntity<List<UserLanguageProgressResponse>> findByUserId(){
        return ResponseEntity.ok(service.findByUserId(SecurityUtils.currentUserId()));
    }

    @Override
    @PostMapping("/{languageId}")
    public ResponseEntity<UserLanguageProgressResponse> getOrCreate(@PathVariable Integer languageId){
        return ResponseEntity.status(HttpStatus.CREATED).body(service.getOrCreate(SecurityUtils.currentUserId(), languageId));
    }

}
