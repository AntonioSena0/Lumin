package br.com.api.dto.response;

import lombok.Builder;

@Builder
public record TokenPair(

        String access,
        String refreshJti

) {}
