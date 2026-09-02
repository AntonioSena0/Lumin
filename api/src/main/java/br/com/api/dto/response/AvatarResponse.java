package br.com.api.dto.response;

import lombok.Builder;

@Builder
public record AvatarResponse(

    Integer id,
    String name,
    String imgUrl

) {}
