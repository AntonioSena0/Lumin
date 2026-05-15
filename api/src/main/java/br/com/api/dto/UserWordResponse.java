package br.com.api.dto;

import br.com.api.entity.UserWordId;
import lombok.Builder;

import java.time.LocalDateTime;

@Builder
public record UserWordResponse(

        UserWordId id,
        UserResponse user,
        WordResponse word,
        LocalDateTime lastPracticed,
        LocalDateTime createdAt

) {}
