package br.com.api.mapper;

import br.com.api.dto.request.UserRequest;
import br.com.api.dto.response.StudySessionResponse;
import br.com.api.dto.response.UserResponse;
import br.com.api.dto.request.UserUpdateRequest;
import br.com.api.dto.response.UserWordResponse;
import br.com.api.entity.Language;
import br.com.api.entity.User;
import br.com.api.entity.UserWord;
import br.com.api.entity.Word;
import lombok.experimental.UtilityClass;

import java.util.ArrayList;
import java.util.List;
import java.util.Stack;

@UtilityClass
public class UserMapper {

    public User toUser(UserRequest request, Language nativeLanguage, Language chosenLanguage){

        return User
                .builder()
                .name(request.name())
                .email(request.email())
                .password(request.password())
                .nativeLanguage(nativeLanguage)
                .chosenLanguage(chosenLanguage)
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

        List<UserWordResponse> safeWords = sortByLastPracticed(user.getWords());

        List<StudySessionResponse> safeSessions = (user.getSessions() != null ? user.getSessions().stream()
                .map(StudySessionMapper::toStudySessionResponse)
                .toList() : List.of());

        return UserResponse
                .builder()
                .id(user.getId())
                .name(user.getName())
                .email(user.getEmail())
                .nativeLanguage(LanguageMapper.toLanguageResponse(user.getNativeLanguage()))
                .chosenLanguage(LanguageMapper.toLanguageResponse(user.getChosenLanguage()))
                .words(safeWords)
                .sessions(safeSessions)
                .createdAt(user.getCreatedAt())
                .updatedAt(user.getUpdatedAt())
                .build();

    }

    public List<UserWordResponse> sortByLastPracticed(List<UserWord> words){

         if (words == null || words.isEmpty()) {
             return List.of();
         }

        return words.stream()
                .sorted((w1, w2) -> {
                    if(w1.getLastPracticed() == null && w2.getLastPracticed() == null){
                        return 0;
                    }
                    if(w1.getLastPracticed() == null){
                        return 1;
                    }
                    if(w2.getLastPracticed() == null){
                        return -1;
                    }
                    return w2.getLastPracticed().compareTo(w1.getLastPracticed());
                })
                .map(UserWordMapper::toUserWordResponse)
                .toList();

    }

}
