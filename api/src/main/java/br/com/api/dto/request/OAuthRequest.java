package br.com.api.dto.request;

import br.com.api.domain.OAuthProvider;
import jakarta.validation.constraints.NotNull;

public record OAuthRequest(

        @NotNull(message = "Provedor é obrigatório")
        OAuthProvider provider,

        String code,

        String redirectUri,

        String idToken

) {}
