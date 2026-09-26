package br.com.api.dto.response;

import br.com.api.domain.VoiceType;
import lombok.Builder;

import java.time.LocalDateTime;

@Builder
public record SettingResponse(

    Long userId,
    LanguageResponse appLanguage,
    boolean notifyDaily,
    boolean notifyReview,
    VoiceType voice,
    LocalDateTime updatedAt

) {}
