package br.com.api.service;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jws;

public interface JwtService {

    String issue(Long userId);
    Jws<Claims> parse(String token);
    Long getUserId(String token);

}
