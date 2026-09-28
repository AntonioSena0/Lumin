package br.com.api.dto.request;

import br.com.api.domain.OAuthProvider;
import jakarta.validation.constraints.NotNull;

import java.net.URI;

public record OAuthRequest(

        @NotNull(message = "Provedor é obrigatório")
        OAuthProvider provider,

        @NotNull(message = "Código é obrigatório")
        String code,

        @NotNull(message = "Redirect é obrigatório")
        String redirectUri

) {}
