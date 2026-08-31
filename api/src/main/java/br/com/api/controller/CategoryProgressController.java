package br.com.api.controller;

import br.com.api.dto.response.CategoryProgressResponse;
import org.springframework.http.ResponseEntity;

import java.util.List;

public interface CategoryProgressController {

    ResponseEntity<List<CategoryProgressResponse>> findByUserId(Long userId);

}
