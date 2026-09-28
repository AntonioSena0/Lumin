package br.com.api.service;

import br.com.api.dto.request.*;

import br.com.api.dto.response.AuthRegisterResponse;
import br.com.api.dto.response.OAuthResult;
import br.com.api.dto.response.TokenPair;

public interface AuthService {

    AuthRegisterResponse register(UserRequest request);
    TokenPair login(LoginRequest request);
    TokenPair refresh(String refreshJti);
    void logout(String refreshJti);
    void verify(VerifyRequest request);
    void resend(ResendRequest request);
    OAuthResult oauth(OAuthRequest request);
    AuthRegisterResponse registerOAuth(UserOAuthRequest request);

}
