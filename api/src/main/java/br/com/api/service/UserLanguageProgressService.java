package br.com.api.service;

import br.com.api.dto.response.UserLanguageProgressResponse;
import br.com.api.entity.Language;
import br.com.api.entity.User;

import java.util.List;

public interface UserLanguageProgressService {

    UserLanguageProgressResponse findById(Long userId, Integer languageId);

    List<UserLanguageProgressResponse> findByUserId(Long userId);

    UserLanguageProgressResponse getOrCreate(Long userId, Integer languageId);

    void registerFinishedSession(User user, Language language, Integer score, Integer totalExercises);

}