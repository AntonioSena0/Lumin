package br.com.api.service;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jws;

public interface JwtService {

    String issue(Long userId, boolean verified);
    Jws<Claims> parse(String token);
    Long getUserId(String token);
    boolean isVerified(String token);

}
