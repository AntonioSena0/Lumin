package br.com.api.dto;

import lombok.Builder;

import java.time.LocalDateTime;

@Builder
public record LanguageResponse(

        int id,
        String name,
        String code,
        LocalDateTime createdAt

) {}
