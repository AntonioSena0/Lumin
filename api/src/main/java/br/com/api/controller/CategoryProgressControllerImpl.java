package br.com.api.controller;

import br.com.api.dto.response.CategoryProgressResponse;
import br.com.api.service.CategoryProgressService;
import lombok.AllArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/lumin/users/{userId}/categories/progress")
@AllArgsConstructor
public class CategoryProgressControllerImpl implements CategoryProgressController{

    private final CategoryProgressService service;

    @Override
    @GetMapping
    public ResponseEntity<List<CategoryProgressResponse>> findByUserId(@PathVariable Long userId) {
        return ResponseEntity.ok(service.findByUserId(userId));
    }

}
