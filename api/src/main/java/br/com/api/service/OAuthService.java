package br.com.api.service;

import br.com.api.dto.response.OAuthPendingResponse;

public interface OAuthService {

    OAuthPendingResponse resolveGoogle(String code, String redirectUri);

}
