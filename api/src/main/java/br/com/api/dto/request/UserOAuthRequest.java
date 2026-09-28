package br.com.api.dto.request;

import br.com.api.domain.OAuthProvider;
import jakarta.validation.constraints.*;

public record UserOAuthRequest(

        @NotEmpty(message = "Nome não pode ser vazio")
        @Size(max = 100)
        String name,

        @NotEmpty(message = "Email não pode ser vazio")
        @Size(max = 100)
        @Email(message = "Formato de email inválido")
        String email,

        @NotNull(message = "Língua nativa não pode ser nula")
        Integer nativeLanguage,

        @NotNull(message = "Língua escolhida não pode ser nula")
        Integer chosenLanguage,

        @NotNull(message = "Provider não pode ser nulo")
        OAuthProvider provider,

        @NotBlank(message = "Id do provider não pode ser vazio")
        String providerId,

        boolean providerEmailVerified

) {}
