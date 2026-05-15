package br.com.api.dto;

import lombok.Builder;

import java.time.LocalDateTime;

@Builder
public record WordResponse(

        Long id,
        String original,
        String translated,
        String description,
        LanguageResponse language,
        LocalDateTime createdAt

) {}
