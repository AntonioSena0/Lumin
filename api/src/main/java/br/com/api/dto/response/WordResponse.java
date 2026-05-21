package br.com.api.dto.response;

import lombok.Builder;

import java.time.LocalDateTime;

@Builder
public record WordResponse(

        Long id,
        String original,
        String translated,
        String description,
        LanguageResponse from_language,
        LanguageResponse to_language,
        LocalDateTime createdAt

) {}
