package br.com.api.service;

import br.com.api.dto.response.CategoryProgressResponse;

import java.util.List;

public interface CategoryProgressService {

    List<CategoryProgressResponse> findByUserId(Long userId);

}
