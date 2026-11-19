package br.com.api.dto.response;

import lombok.Builder;

@Builder
public record PublicProfileResponse(

        Long id,
        String name,
        AvatarResponse avatar,
        LanguageResponse nativeLanguage,
        LanguageResponse chosenLanguage,
        long followers,
        long following,
        boolean followedByMe,
        boolean me

) {}
