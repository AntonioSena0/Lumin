package br.com.api.dto.response;

import lombok.Builder;

@Builder
public record AuthRegisterResponse(

        UserMeResponse userMeResponse,
        TokenPair tokenPair

) {}
