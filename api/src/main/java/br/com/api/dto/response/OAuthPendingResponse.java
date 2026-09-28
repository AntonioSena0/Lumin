package br.com.api.dto.response;

import br.com.api.domain.OAuthProvider;
import lombok.Builder;

@Builder
public record OAuthPendingResponse(

    String email,
    String name,
    String avatarUrl,
    OAuthProvider provider,
    String providerId,
    boolean emailVerified

) {}
