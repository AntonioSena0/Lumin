package br.com.api.mapper;

import br.com.api.dto.UserRequest;
import br.com.api.dto.UserResponse;
import br.com.api.dto.UserUpdateRequest;
import br.com.api.entity.Language;
import br.com.api.entity.User;
import lombok.experimental.UtilityClass;

@UtilityClass
public class UserMapper {

    public User toUser(UserRequest request, Language language){

        return User
                .builder()
                .name(request.name())
                .email(request.email())
                .password(request.password())
                .chosenLanguage(language)
                .build();

    }

    public User toUser(UserUpdateRequest request, Language language){

        return User
                .builder()
                .name(request.name())
                .email(request.email())
                .password(request.password())
                .chosenLanguage(language)
                .build();

    }

    public UserResponse toUserResponse(User user){

        return UserResponse
                .builder()
                .id(user.getId())
                .name(user.getName())
                .email(user.getEmail())
                .chosenLanguage(LanguageMapper.toLanguageResponse(user.getChosenLanguage()))
                .createdAt(user.getCreatedAt())
                .updatedAt(user.getUpdatedAt())
                .build();

    }

}
