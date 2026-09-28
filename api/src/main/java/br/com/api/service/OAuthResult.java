package br.com.api.service;

import br.com.api.dto.response.OAuthPendingResponse;
import br.com.api.dto.response.TokenPair;

public record OAuthResult(
        TokenPair tokens,
        OAuthPendingResponse pendingResponse
) {}
