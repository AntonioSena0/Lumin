package br.com.api.dto.request;

import br.com.api.domain.OAuthProvider;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record UserOAuthRequest(

        @NotEmpty(message = "Nome não pode ser vazio")
        @Size(max = 100)
        String name,

        @NotNull(message = "Língua nativa não pode ser nula")
        Integer nativeLanguage,

        @NotNull(message = "Língua escolhida não pode ser nula")
        Integer chosenLanguage,

        @NotNull(message = "Provider não pode ser nulo")
        OAuthProvider provider,

        String code,

        String redirectUri,

        String idToken

) {}
