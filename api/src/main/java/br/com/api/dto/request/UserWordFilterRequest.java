package br.com.api.dto.request;

import br.com.api.domain.WordDomainLevel;

public record UserWordFilterRequest(

        Boolean saved,
        WordDomainLevel level,
        Integer categoryId,
        Integer languageId,
        String search,
        Boolean onlyPracticed,
        Boolean onlyWeak

) {}
