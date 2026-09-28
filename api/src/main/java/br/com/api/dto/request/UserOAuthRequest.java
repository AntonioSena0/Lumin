package br.com.api.dto.request;

import br.com.api.domain.OAuthProvider;
import jakarta.validation.constraints.*;

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

        @NotBlank(message = "Código não pode ser vazio")
        String code,

        @NotBlank(message = "Redirect não pode ser vazio")
        String redirectUri

) {}
