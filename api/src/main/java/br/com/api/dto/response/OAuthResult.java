package br.com.api.dto.response;

public record OAuthResult (

    TokenPair tokens,
    OAuthPendingResponse pendingResponse

) {}