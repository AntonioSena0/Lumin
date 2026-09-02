package br.com.api.mapper;

import br.com.api.dto.response.AvatarResponse;
import br.com.api.entity.Avatar;
import lombok.experimental.UtilityClass;

@UtilityClass
public class AvatarMapper {

    public AvatarResponse toAvatarResponse(Avatar avatar){

        return AvatarResponse
                .builder()
                .id(avatar.getId())
                .name(avatar.getName())
                .imgUrl(avatar.getImgUrl())
                .build();

    }

}
