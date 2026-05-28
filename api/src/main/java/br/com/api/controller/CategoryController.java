package br.com.api.controller;

import br.com.api.dto.response.CategoryResponse;
import org.springframework.http.ResponseEntity;

import java.util.List;

public interface CategoryController {

    ResponseEntity<List<CategoryResponse>> findAll();
    ResponseEntity<CategoryResponse> findById(Integer id);

}
