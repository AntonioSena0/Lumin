package br.com.api.mapper;

import br.com.api.dto.request.WordRequest;
import br.com.api.dto.response.WordResponse;
import br.com.api.entity.Category;
import br.com.api.entity.Language;
import br.com.api.entity.Word;
import lombok.experimental.UtilityClass;

@UtilityClass
public class WordMapper {

    public Word toWord(WordRequest request, String description, Language from_language, Language to_language, Category category){

        return Word
                .builder()
                .original(request.original())
                .translated(request.translated())
                .description(description)
                .category(category)
                .fromLanguage(from_language)
                .toLanguage(to_language)
                .build();

    }

    public WordResponse toWordResponse(Word word){

        return WordResponse
                .builder()
                .id(word.getId())
                .original(word.getOriginal())
                .translated(word.getTranslated())
                .description(word.getDescription())
                .from_language(LanguageMapper.toLanguageResponse(word.getFromLanguage()))
                .to_language(LanguageMapper.toLanguageResponse(word.getToLanguage()))
                .category(CategoryMapper.toCategoryResponse(word.getCategory()))
                .createdAt(word.getCreatedAt())
                .updatedAt(word.getUpdatedAt())
                .build();

    }


}
