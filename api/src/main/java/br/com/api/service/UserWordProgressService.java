package br.com.api.service;

import br.com.api.entity.User;
import br.com.api.entity.Word;

public interface UserWordProgressService {

    void registerAnswer(User user, Word word, boolean correct);

}
