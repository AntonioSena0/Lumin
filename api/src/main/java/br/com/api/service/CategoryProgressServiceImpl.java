package br.com.api.service;

import br.com.api.dto.response.CategoryProgressResponse;
import br.com.api.mapper.CategoryProgressMapper;
import br.com.api.repository.UserWordRepository;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@AllArgsConstructor
public class CategoryProgressServiceImpl implements CategoryProgressService{

    private final UserWordRepository repository;

    @Override
    public List<CategoryProgressResponse> findByUserId(Long userId) {
        return repository.findCategoryProgressByUserId(userId)
                .stream()
                .map(CategoryProgressMapper::toCategoryProgressResponse)
                .toList();
    }

}
