package br.com.api.mapper;

import br.com.api.dto.response.LanguageResponse;
import br.com.api.entity.Language;
import lombok.experimental.UtilityClass;

@UtilityClass
public class LanguageMapper {

    public LanguageResponse toLanguageResponse(Language language){

        return LanguageResponse
                .builder()
                .id(language.getId())
                .name(language.getName())
                .code(language.getCode())
                .createdAt(language.getCreatedAt())
                .build();

    }

}
