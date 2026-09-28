package br.com.api.service;

import br.com.api.dto.request.LoginRequest;
import br.com.api.dto.request.ResendRequest;
import br.com.api.dto.request.UserRequest;
import br.com.api.dto.request.VerifyRequest;
import br.com.api.dto.response.AuthRegisterResponse;
import br.com.api.dto.response.TokenPair;

public interface AuthService {

    AuthRegisterResponse register(UserRequest request);
    TokenPair login(LoginRequest request);
    TokenPair refresh(String refreshJti);
    void logout(String refreshJti);
    void verify(VerifyRequest request);
    void resend(ResendRequest request);

}
