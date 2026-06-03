package br.com.api.dto.response;

import br.com.api.entity.UserWordId;
import lombok.Builder;

import java.time.LocalDateTime;

@Builder
public record UserWordResponse(

        Long userId,
        Long wordId,
        WordResponse word,
        LocalDateTime lastPracticed,
        LocalDateTime createdAt

) {}
