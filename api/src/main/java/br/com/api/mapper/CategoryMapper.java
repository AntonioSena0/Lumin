package br.com.api.mapper;

import br.com.api.dto.response.CategoryResponse;
import br.com.api.entity.Category;
import lombok.experimental.UtilityClass;

@UtilityClass
public class CategoryMapper {

    public CategoryResponse toCategoryResponse(Category category){

        return CategoryResponse
                .builder()
                .id(category.getId())
                .name(category.getName())
                .description(category.getDescription())
                .createdAt(category.getCreatedAt())
                .build();

    }

}
