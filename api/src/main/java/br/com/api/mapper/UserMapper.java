package br.com.api.mapper;

import br.com.api.dto.request.UserRequest;
import br.com.api.dto.response.UserResponse;
import br.com.api.entity.Avatar;
import br.com.api.entity.Language;
import br.com.api.entity.User;
import lombok.experimental.UtilityClass;

@UtilityClass
public class UserMapper {

    public User toUser(UserRequest request, Language nativeLanguage, Language chosenLanguage, Avatar avatar){

        return User
                .builder()
                .name(request.name())
                .email(request.email().trim())
                .password(request.password().trim())
                .nativeLanguage(nativeLanguage)
                .chosenLanguage(chosenLanguage)
                .avatar(avatar)
                .build();

    }

    public UserResponse toUserResponse(User user){

        return UserResponse
                .builder()
                .id(user.getId())
                .name(user.getName())
                .email(user.getEmail())
                .nativeLanguage(LanguageMapper.toLanguageResponse(user.getNativeLanguage()))
                .chosenLanguage(LanguageMapper.toLanguageResponse(user.getChosenLanguage()))
                .avatar(AvatarMapper.toAvatarResponse(user.getAvatar()))
                .createdAt(user.getCreatedAt())
                .updatedAt(user.getUpdatedAt())
                .build();

    }

}
