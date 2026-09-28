package br.com.api.service;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jws;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Date;

@Service
public class JwtServiceImpl implements JwtService{

    private final SecretKey key;
    private final long expMin;

    public JwtServiceImpl(
            @Value("${jwt.secret}") String secret,
            @Value("${jwt.exp-min}") long expMin
    ) {
        this.key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        this.expMin = expMin;
    }

    @Override
    public String issue(Long userId, boolean verified) {
        Instant now = Instant.now();
        return Jwts
                .builder()
                .subject(userId.toString())
                .claim("verified", verified)
                .issuedAt(Date.from(now))
                .expiration(Date.from(now.plus(expMin, ChronoUnit.MINUTES)))
                .signWith(key)
                .compact();
    }

    @Override
    public Jws<Claims> parse(String token) {
        return Jwts.parser()
                .verifyWith(key)
                .clockSkewSeconds(30)
                .build()
                .parseSignedClaims(token);
    }

    @Override
    public Long getUserId(String token) {
        return Long.valueOf(parse(token).getPayload().getSubject());
    }

    @Override
    public boolean isVerified(String token){
        Boolean v = parse(token).getPayload().get("verified", Boolean.class);
        return Boolean.TRUE.equals(v);
    }

}
