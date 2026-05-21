package br.com.api.service;

import br.com.api.dto.request.WordRequest;
import br.com.api.dto.response.WordResponse;
import br.com.api.dto.request.WordUpdateRequest;
import br.com.api.entity.*;
import br.com.api.mapper.WordMapper;
import br.com.api.repository.LanguageRepository;
import br.com.api.repository.UserRepository;
import br.com.api.repository.UserWordRepository;
import br.com.api.repository.WordRepository;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@AllArgsConstructor
public class WordServiceImpl implements WordService {

    private final WordRepository repository;
    private final UserRepository userRepository;
    private final LanguageRepository languageRepository;
    private final UserWordRepository userWordRepository;

    @Override
    public List<WordResponse> findAll() {
        return repository.findAll()
                .stream()
                .map(WordMapper::toWordResponse)
                .toList();
    }

    @Override
    public WordResponse findById(Long wordId) {
        return WordMapper.toWordResponse(repository.findById(wordId)
                .orElseThrow(() -> new RuntimeException("Palavra não encontrada")));
    }

    @Override
    public List<WordResponse> search(String q) {
        return repository.findByOriginalContains(q)
                .stream()
                .map(WordMapper::toWordResponse)
                .toList();
    }

    @Override
    public WordResponse save(WordRequest request, Long userId) {

        User existingUser = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Usuário que tentou realizar a ação não existe"));

        Optional<Word> existingWord = repository.findByOriginalAndTranslated(request.original(), request.translated());

        if(existingWord.isPresent()){

            Word word = existingWord.get();

            UserWord userWord = new UserWord();
            userWord.setId(new UserWordId(existingUser.getId(), word.getId()));
            userWord.setUser(existingUser);
            userWord.setWord(word);
            userWord.setLastPracticed(null);

            userWordRepository.save(userWord);

            return WordMapper.toWordResponse(word);

        }

        Language fromLanguage = existingUser.getNativeLanguage();
        Language toLanguage = existingUser.getChosenLanguage();

        Word newWord = repository.save(WordMapper.toWord(request, fromLanguage, toLanguage));

        UserWord userWord = new UserWord();
        userWord.setId(new UserWordId(existingUser.getId(), newWord.getId()));
        userWord.setUser(existingUser);
        userWord.setWord(newWord);
        userWord.setLastPracticed(null);

        userWordRepository.save(userWord);

        return WordMapper.toWordResponse(newWord);

    }

    @Override
    public WordResponse update(WordUpdateRequest request, Long wordId) {

        Word existingWord = repository.findById(wordId)
                .orElseThrow(() -> new RuntimeException("Palavra não encontrada"));

        existingWord.setDescription(request.description());

        return WordMapper.toWordResponse(repository.save(existingWord));

    }

    @Override
    public void unsave(Long wordId, Long userId) {

        UserWord existingUserWord = userWordRepository.findById(new UserWordId(userId, wordId))
                .orElseThrow(() -> new RuntimeException("Tentando remover palavra que ainda não foi salva"));

        userWordRepository.delete(existingUserWord);

    }
}
