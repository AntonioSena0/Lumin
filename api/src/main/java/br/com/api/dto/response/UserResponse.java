package br.com.api.dto.response;

import lombok.Builder;

import java.time.LocalDateTime;
import java.util.List;

@Builder
public record UserResponse(

        Long id,
        String name,
        String email,
        LanguageResponse nativeLanguage,
        LanguageResponse chosenLanguage,
        List<UserWordResponse> words,
        List<StudySessionResponse> sessions,
        LocalDateTime createdAt,
        LocalDateTime updatedAt

) {}
