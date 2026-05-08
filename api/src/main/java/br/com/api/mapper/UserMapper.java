package br.com.api.mapper;

import br.com.api.dto.UserRequest;
import br.com.api.dto.UserResponse;
import br.com.api.entity.User;
import lombok.experimental.UtilityClass;

@UtilityClass
public class UserMapper {

    public static User toUser(UserRequest request){

        return User
                .builder()
                .name(request.name())
                .email(request.email())
                .password(request.password())
                .build();

    }

    public static UserResponse toUserResponse(User user){

        return UserResponse
                .builder()
                .id(user.getId())
                .name(user.getName())
                .email(user.getEmail())
                .createdAt(user.getCreatedAt())
                .updatedAt(user.getUpdatedAt())
                .build();

    }

}
