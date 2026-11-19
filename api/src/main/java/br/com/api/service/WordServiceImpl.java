package br.com.api.service;

import br.com.api.dto.request.WordRequest;
import br.com.api.dto.response.UserWordListResponse;
import br.com.api.dto.response.WordInsightAiResponse;
import br.com.api.dto.response.WordResponse;
import br.com.api.entity.*;
import br.com.api.exception.BusinessException;
import br.com.api.exception.NotFoundException;
import br.com.api.mapper.UserWordMapper;
import br.com.api.mapper.WordMapper;
import br.com.api.repository.*;
import br.com.api.util.TextNormalizer;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.text.Normalizer;
import java.util.List;
import java.util.Optional;

@Slf4j
@Service
@AllArgsConstructor
public class WordServiceImpl implements WordService {

    private final AiGeneratorService aiService;
    private final WordRepository repository;
    private final UserRepository userRepository;
    private final UserWordRepository userWordRepository;
    private final CategoryRepository categoryRepository;

    @Override
    public Page<WordResponse> findAll(Pageable pageable) {
        return repository.findAllWithRelations(pageable)
                .map(WordMapper::toWordResponse);
    }

    @Override
    public WordResponse findById(Long wordId) {
        return WordMapper.toWordResponse(repository.findByIdWithRelations(wordId)
                .orElseThrow(() -> new NotFoundException("WORD_NOT_FOUND", "Palavra não encontrada")));
    }

    /** Pesquisa no catálogo da comunidade usando o par de idiomas do usuário e o termo normalizado. */
    @Override
    public Page<WordResponse> catalog(Long userId, String q, Integer categoryId, Pageable pageable) {

        User user = userRepository.findByIdWithRelations(userId)
                .orElseThrow(() -> new NotFoundException("USER_NOT_FOUND", "Usuário não encontrado"));

        return repository.searchCatalog(
                user.getNativeLanguage().getId(),
                user.getChosenLanguage().getId(),
                TextNormalizer.normalize(q),
                categoryId == null ? 0 : categoryId,
                pageable
        ).map(WordMapper::toWordResponse);

    }

    @Override
    public Page<WordResponse> search(String q, Integer languageId, Pageable pageable) {
        return repository.findByOriginalContains(q, languageId, pageable)
                .map(WordMapper::toWordResponse);
    }

    /** Salva a palavra para o usuário, reaproveitando palavras existentes e validando a categoria com a IA antes de criar uma nova. */
    @Override
    @Transactional
    public UserWordListResponse save(WordRequest request, Long userId) {

        User existingUser = userRepository.findByIdWithRelations(userId)
                .orElseThrow(() -> new NotFoundException("USER_NOT_FOUND", "Usuário que tentou realizar a ação não existe"));

        Category existingCategory = categoryRepository.findById(request.categoryId())
                .orElseThrow(() -> new NotFoundException("CATEGORY_NOT_FOUND", "Categoria não encontrada"));

        String original = TextNormalizer.normalize(request.original());
        String translated = TextNormalizer.normalize(request.translated());

        Optional<Word> existingWord = repository.findByOriginalAndTranslatedAndCategory(original, translated, existingCategory);

        if(existingWord.isPresent()){
            return saveForUser(existingUser, existingWord.get());
        }

        Language fromLanguage = existingUser.getNativeLanguage();
        Language toLanguage = existingUser.getChosenLanguage();

        List<Category> categories = categoryRepository.findAll();

        WordInsightAiResponse insight = generateInsight(original, translated, existingCategory, categories, fromLanguage);

        Category finalCategory = resolveCategory(insight.category(), categories, existingCategory);

        if(!finalCategory.equals(existingCategory)){
            Optional<Word> correctedWord = repository.findByOriginalAndTranslatedAndCategory(original, translated, finalCategory);
            if(correctedWord.isPresent()){
                return saveForUser(existingUser, correctedWord.get());
            }
        }

        Word newWord = repository.save(WordMapper.toWord(
                original,
                translated,
                limitDescription(insight.description()),
                fromLanguage,
                toLanguage,
                finalCategory
        ));

        return saveForUser(existingUser, newWord);

    }

    /** Pede descrição e categoria à IA; se ela falhar, a palavra é salva sem descrição e com a categoria escolhida. */
    private WordInsightAiResponse generateInsight(String original, String translated, Category chosen, List<Category> categories, Language language) {

        try {
            return aiService.generateWordInsight(
                    original,
                    translated,
                    chosen.getName(),
                    categories.stream().map(Category::getName).toList(),
                    language.getName()
            );
        } catch (RuntimeException e) {
            log.warn("IA indisponível ao salvar '{}': {}", original, e.getMessage());
            return new WordInsightAiResponse("", chosen.getName());
        }

    }

    /** Corta a descrição no limite da coluna para o banco não recusar textos longos da IA. */
    private static String limitDescription(String description) {

        if(description == null) return "";
        String trimmed = description.trim();
        return trimmed.length() > 200 ? trimmed.substring(0, 200) : trimmed;

    }

    /** Marca a palavra como salva para o usuário, criando a relação quando ainda não existe. */
    private UserWordListResponse saveForUser(User user, Word word) {

        Optional<UserWord> relation = userWordRepository.findById(new UserWordId(user.getId(), word.getId()));

        if(relation.isPresent()){
            UserWord userWord = relation.get();
            userWord.setSaved(true);
            return UserWordMapper.toUserWordListResponse(userWord);
        }

        UserWord userWord = new UserWord();
        userWord.setId(new UserWordId(user.getId(), word.getId()));
        userWord.setUser(user);
        userWord.setWord(word);
        userWord.setSaved(true);

        userWordRepository.save(userWord);

        return UserWordMapper.toUserWordListResponse(userWord);

    }

    /** Converte a categoria sugerida pela IA em uma categoria existente, mantendo a escolhida quando não há correspondência. */
    private Category resolveCategory(String suggested, List<Category> categories, Category chosen) {

        if(suggested == null || suggested.isBlank()){
            return chosen;
        }

        String key = normalize(suggested);

        return categories.stream()
                .filter(c -> normalize(c.getName()).equals(key))
                .findFirst()
                .orElse(chosen);

    }

    /** Normaliza nomes de categoria para comparação, sem acentos e em minúsculas. */
    private String normalize(String value) {
        return Normalizer.normalize(value.trim(), Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .toLowerCase();
    }

    @Override
    @Transactional
    public UserWordListResponse unsave(Long wordId, Long userId) {
    
        UserWord existingUserWord = userWordRepository.findById(new UserWordId(userId, wordId))
                .orElseThrow(() -> new BusinessException("USER_WORD_NOT_SAVED", "Tentando remover palavra que ainda não foi salva"));

        if(!existingUserWord.isSaved()){
            return UserWordMapper.toUserWordListResponse(existingUserWord);
        }

        existingUserWord.setSaved(false);

        return UserWordMapper.toUserWordListResponse(existingUserWord);
    }
}
