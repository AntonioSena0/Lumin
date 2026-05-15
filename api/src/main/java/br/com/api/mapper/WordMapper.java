package br.com.api.mapper;

import br.com.api.dto.WordRequest;
import br.com.api.dto.WordResponse;
import br.com.api.entity.Language;
import br.com.api.entity.Word;
import lombok.experimental.UtilityClass;

@UtilityClass
public class WordMapper {

    public Word toWord(WordRequest request, Language language){

        return Word
                .builder()
                .original(request.original())
                .translated(request.translated())
                .description(request.description())
                .language(language)
                .build();

    }

    public WordResponse toWordResponse(Word word){

        return WordResponse
                .builder()
                .id(word.getId())
                .original(word.getOriginal())
                .translated(word.getTranslated())
                .description(word.getDescription())
                .language(LanguageMapper.toLanguageResponse(word.getLanguage()))
                .createdAt(word.getCreatedAt())
                .build();

    }


}
