package br.com.api.service;

import br.com.api.domain.WordDomainLevel;
import br.com.api.entity.User;
import br.com.api.entity.UserWord;
import br.com.api.entity.UserWordId;
import br.com.api.entity.Word;
import br.com.api.repository.UserWordRepository;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@AllArgsConstructor
public class UserWordProgressServiceImpl implements UserWordProgressService {

    private final UserWordRepository repository;

    @Override
    @Transactional
    public void registerAnswer(User user, Word word, boolean correct) {
        UserWord userWord = getOrCreate(user, word);

        if (correct) {
            userWord.setCorrectAnswers(userWord.getCorrectAnswers() + 1);
        } else {
            userWord.setIncorrectAnswers(userWord.getIncorrectAnswers() + 1);
        }

        userWord.setLastPracticed(LocalDateTime.now());
        userWord.setLevel(calculateLevel(userWord));
    }

    private UserWord getOrCreate(User user, Word word) {
        UserWordId id = new UserWordId(user.getId(), word.getId());

        return repository.findById(id)
                .orElseGet(() -> {
                    UserWord userWord = new UserWord();
                    userWord.setId(id);
                    userWord.setUser(user);
                    userWord.setWord(word);
                    userWord.setSaved(false);
                    userWord.setCorrectAnswers(0L);
                    userWord.setIncorrectAnswers(0L);
                    userWord.setLevel(WordDomainLevel.DISCOVERED);
                    return repository.save(userWord);
                });
    }

    private WordDomainLevel calculateLevel(UserWord userWord) {
        long correctAnswers = userWord.getCorrectAnswers();
        long incorrectAnswers = userWord.getIncorrectAnswers();
        long totalAnswers = correctAnswers + incorrectAnswers;

        if (totalAnswers == 0) {
            return WordDomainLevel.DISCOVERED;
        }

        if (correctAnswers >= 5 && accuracy(correctAnswers, totalAnswers) >= 0.75) {
            return WordDomainLevel.FAMILIAR;
        }

        return WordDomainLevel.PRACTICING;
    }

    private double accuracy(long correctAnswers, long totalAnswers) {
        return (double) correctAnswers / totalAnswers;
    }

}