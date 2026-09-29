package br.com.api.service;

import br.com.api.domain.OAuthProvider;
import br.com.api.dto.response.OAuthPendingResponse;
import br.com.api.exception.BusinessException;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;

import java.io.IOException;
import java.security.GeneralSecurityException;
import java.util.List;

@Service
public class OAuthServiceImpl implements OAuthService{

    private final GoogleIdTokenVerifier verifier;
    private final String googleClientId;
    private final String googleClientSecret;
    private final RestTemplate restTemplate;

    public OAuthServiceImpl(
            @Value("${GOOGLE_CLIENT_ID}") String googleClientId,
            @Value("${GOOGLE_CLIENT_SECRET}") String googleClientSecret,
            RestTemplate restTemplate
    ) {
        this.verifier = new GoogleIdTokenVerifier
                .Builder(new NetHttpTransport(), new GsonFactory())
                .setAudience(List.of(googleClientId))
                .build();
        this.googleClientId = googleClientId;
        this.googleClientSecret = googleClientSecret;
        this.restTemplate = restTemplate;
    }

    @Override
    @Transactional
    public OAuthPendingResponse resolveGoogle(String code, String redirectUri, String idToken) {

        if (idToken != null && !idToken.isBlank()) {
            return fromIdToken(idToken);
        }

        if (code == null || code.isBlank() || redirectUri == null || redirectUri.isBlank()) {
            throw new BusinessException("OAUTH_INVALID", "Informe o idToken do aplicativo ou o código de autorização");
        }

        return fromAuthorizationCode(code, redirectUri);
    }

    private OAuthPendingResponse fromIdToken(String idToken) {

        try {
            GoogleIdToken verified = verifier.verify(idToken);

            if (verified == null) {
                throw new BusinessException("OAUTH_INVALID", "Login social inválido");
            }

            return toPending(verified);
        } catch (GeneralSecurityException | IOException e){
            throw new BusinessException("OAUTH_INVALID", "Login social inválido");
        }
    }

    private OAuthPendingResponse fromAuthorizationCode(String code, String redirectUri) {

        MultiValueMap<String, String> form = new LinkedMultiValueMap<>();
        form.add("code", code);
        form.add("client_id", googleClientId);
        form.add("client_secret", googleClientSecret);
        form.add("redirect_uri", redirectUri);
        form.add("grant_type", "authorization_code");

        record TokenResponse(
                @JsonProperty("access_token") String accessToken,
                @JsonProperty("id_token") String idToken,
                @JsonProperty("expires_in") int expiresIn
        ) {}

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

        TokenResponse tokens = restTemplate.postForObject(
                "https://oauth2.googleapis.com/token", new HttpEntity<>(form, headers), TokenResponse.class
        );

        if (tokens == null || tokens.idToken == null) {
            throw new BusinessException("OAUTH_INVALID", "Login social inválido");
        }

        return fromIdToken(tokens.idToken);
    }

    private OAuthPendingResponse toPending(GoogleIdToken idToken) {

        GoogleIdToken.Payload payload = idToken.getPayload();

        return OAuthPendingResponse
                .builder()
                .email(payload.getEmail())
                .name((String) payload.get("name"))
                .avatarUrl((String) payload.get("picture"))
                .provider(OAuthProvider.GOOGLE)
                .providerId(payload.getSubject())
                .emailVerified(Boolean.TRUE.equals(payload.getEmailVerified()))
                .build();
    }

}
