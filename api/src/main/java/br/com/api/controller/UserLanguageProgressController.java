package br.com.api.controller;

import br.com.api.dto.response.UserLanguageProgressResponse;
import org.springframework.http.ResponseEntity;

import java.util.List;

public interface UserLanguageProgressController {

    ResponseEntity<UserLanguageProgressResponse> findById(Long userId, Integer languageId);

    ResponseEntity<List<UserLanguageProgressResponse>> findByUserId(Long userId);

    ResponseEntity<UserLanguageProgressResponse> getOrCreate(Long userId, Integer languageId);

}
