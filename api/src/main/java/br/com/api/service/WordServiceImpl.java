package br.com.api.service;

import br.com.api.domain.WordDomainLevel;
import br.com.api.dto.request.WordRequest;
import br.com.api.dto.response.WordResponse;
import br.com.api.entity.*;
import br.com.api.mapper.WordMapper;
import br.com.api.repository.*;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@AllArgsConstructor
public class WordServiceImpl implements WordService {

    private final AiGeneratorService aiService;
    private final WordRepository repository;
    private final UserRepository userRepository;
    private final UserWordRepository userWordRepository;
    private final CategoryRepository categoryRepository;

    @Override
    public List<WordResponse> findAll() {
        return repository.findAllWithRelations()
                .stream()
                .map(WordMapper::toWordResponse)
                .toList();
    }

    @Override
    public WordResponse findById(Long wordId) {
        return WordMapper.toWordResponse(repository.findByIdWithRelations(wordId)
                .orElseThrow(() -> new RuntimeException("Palavra não encontrada")));
    }

    @Override
    public List<WordResponse> search(String q, Integer languageId) {
        return repository.findByOriginalContains(q, languageId)
                .stream()
                .map(WordMapper::toWordResponse)
                .toList();
    }

    @Override
    @Transactional
    public WordResponse save(WordRequest request, Long userId) {

        User existingUser = userRepository.findByIdWithRelations(userId)
                .orElseThrow(() -> new RuntimeException("Usuário que tentou realizar a ação não existe"));

        Optional<Word> existingWord = repository.findByOriginalAndTranslated(request.original(), request.translated());

        if(existingWord.isPresent()){

            Word word = existingWord.get();

            Optional<UserWord> relation = userWordRepository.findById(new UserWordId(existingUser.getId(), word.getId()));

            if(relation.isPresent()){
                UserWord userWord = relation.get();
                return WordMapper.toWordResponse(userWord.getWord());
            }


            UserWord userWord = new UserWord();
            userWord.setId(new UserWordId(existingUser.getId(), word.getId()));
            userWord.setUser(existingUser);
            userWord.setWord(word);
            userWord.setLastPracticed(null);
            userWord.setCorrectAnswers(0L);
            userWord.setIncorrectAnswers(0L);
            userWord.setLevel(WordDomainLevel.BASIC);

            userWordRepository.save(userWord);

            return WordMapper.toWordResponse(word);

        }

        Language fromLanguage = existingUser.getNativeLanguage();
        Language toLanguage = existingUser.getChosenLanguage();
        Category category = categoryRepository.findById(request.categoryId())
                .orElseThrow(() -> new RuntimeException("Categoria não encontrada"));

        Word newWord = repository.save(WordMapper.toWord(
                request,
                aiService.generateDescription(request.original(), request.translated(), category.getName(), fromLanguage.getName()),
                fromLanguage,
                toLanguage,category
        ));

        UserWord userWord = new UserWord();
        userWord.setId(new UserWordId(existingUser.getId(), newWord.getId()));
        userWord.setUser(existingUser);
        userWord.setWord(newWord);
        userWord.setLastPracticed(null);
        userWord.setCorrectAnswers(0L);
        userWord.setIncorrectAnswers(0L);
        userWord.setLevel(WordDomainLevel.BASIC);

        userWordRepository.save(userWord);

        return WordMapper.toWordResponse(newWord);

    }

    @Override
    @Transactional
    public void unsave(Long wordId, Long userId) {

        if(!userWordRepository.existsById(new UserWordId(userId, wordId))){
            throw new RuntimeException("Tentando remover palavra que ainda não foi salva");
        }

        userWordRepository.deleteById(new UserWordId(userId, wordId));

    }
}
