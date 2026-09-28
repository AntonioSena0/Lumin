package br.com.api.service;

public interface VerificationCodeService {

    void issue(String email, String name);
    void revoke(String email);

}
