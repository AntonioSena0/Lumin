package br.com.api.dto.request;

import br.com.api.domain.VoiceType;

public record SettingUpdateRequest(

        Integer appLanguage,

        Boolean notifyDaily,

        Boolean notifyReview,

        VoiceType voice

) {}
