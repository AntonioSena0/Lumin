package br.com.api.dto.response;

import lombok.Builder;

import java.time.LocalDateTime;

@Builder
public record UserResponse(

        Long id,
        String name,
        String email,
        LanguageResponse nativeLanguage,
        LanguageResponse chosenLanguage,
        LocalDateTime createdAt,
        LocalDateTime updatedAt

) {}
