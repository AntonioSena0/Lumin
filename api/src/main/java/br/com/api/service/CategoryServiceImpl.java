package br.com.api.service;

import br.com.api.dto.response.CategoryResponse;
import br.com.api.mapper.CategoryMapper;
import br.com.api.repository.CategoryRepository;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@AllArgsConstructor
public class CategoryServiceImpl implements CategoryService{

    private final CategoryRepository repository;

    @Override
    public List<CategoryResponse> findAll() {
        return repository.findAll()
                .stream()
                .map(CategoryMapper::toCategoryResponse)
                .toList();
    }

    @Override
    public CategoryResponse findById(Integer id) {
        return CategoryMapper.toCategoryResponse(repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Categoria não encontrada"))
        );
    }
}
