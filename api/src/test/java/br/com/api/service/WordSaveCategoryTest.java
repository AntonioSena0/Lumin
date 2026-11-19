package br.com.api.service;

import br.com.api.dto.request.WordRequest;
import br.com.api.dto.response.UserWordListResponse;
import br.com.api.dto.response.WordInsightAiResponse;
import br.com.api.entity.*;
import br.com.api.exception.NotFoundException;
import br.com.api.repository.CategoryRepository;
import br.com.api.repository.UserRepository;
import br.com.api.repository.UserWordRepository;
import br.com.api.repository.WordRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class WordSaveCategoryTest {

    @Mock private AiGeneratorService aiService;
    @Mock private WordRepository wordRepository;
    @Mock private UserRepository userRepository;
    @Mock private UserWordRepository userWordRepository;
    @Mock private CategoryRepository categoryRepository;

    private WordServiceImpl service;
    private User user;
    private Category tecnologia;
    private Category animais;

    @BeforeEach
    void setUp() {
        service = new WordServiceImpl(aiService, wordRepository, userRepository, userWordRepository, categoryRepository);
        Language pt = Language.builder().id(1).code("pt-BR").name("Português (Brasil)").build();
        Language en = Language.builder().id(2).code("en").name("English").build();
        user = User.builder().id(1L).nativeLanguage(pt).chosenLanguage(en).build();
        tecnologia = Category.builder().id(3).name("Tecnologia").build();
        animais = Category.builder().id(6).name("Animais").build();

        when(userRepository.findByIdWithRelations(1L)).thenReturn(Optional.of(user));
        lenient().when(categoryRepository.findAll()).thenReturn(List.of(tecnologia, animais));
        lenient().when(wordRepository.findByOriginalAndTranslatedAndCategory(anyString(), anyString(), any()))
                .thenReturn(Optional.empty());
        lenient().when(wordRepository.save(any(Word.class))).thenAnswer(inv -> {
            Word w = inv.getArgument(0);
            w.setId(10L);
            return w;
        });
    }

    @Test
    void absurdCategoryIsReplacedBySuggestedOne() {
        when(categoryRepository.findById(6)).thenReturn(Optional.of(animais));
        when(aiService.generateWordInsight(eq("teclado"), eq("keyboard"), eq("Animais"), anyList(), anyString()))
                .thenReturn(new WordInsightAiResponse("Dispositivo usado para digitar.", "Tecnologia"));

        UserWordListResponse response = service.save(new WordRequest("Teclado", "Keyboard", 6), 1L);

        Word saved = captureSavedWord();
        assertThat(saved.getCategory()).isEqualTo(tecnologia);
        assertThat(response.categoryName()).isEqualTo("Tecnologia");
    }

    @Test
    void compatibleCategoryIsKept() {
        when(categoryRepository.findById(3)).thenReturn(Optional.of(tecnologia));
        when(aiService.generateWordInsight(anyString(), anyString(), anyString(), anyList(), anyString()))
                .thenReturn(new WordInsightAiResponse("Dispositivo usado para digitar.", "Tecnologia"));

        service.save(new WordRequest("teclado", "keyboard", 3), 1L);

        assertThat(captureSavedWord().getCategory()).isEqualTo(tecnologia);
    }

    @Test
    void unknownSuggestionKeepsUserCategory() {
        when(categoryRepository.findById(3)).thenReturn(Optional.of(tecnologia));
        when(aiService.generateWordInsight(anyString(), anyString(), anyString(), anyList(), anyString()))
                .thenReturn(new WordInsightAiResponse("Dispositivo usado para digitar.", "Categoria Inventada"));

        service.save(new WordRequest("teclado", "keyboard", 3), 1L);

        assertThat(captureSavedWord().getCategory()).isEqualTo(tecnologia);
    }

    @Test
    void suggestionMatchingIsCaseAndAccentInsensitive() {
        when(categoryRepository.findById(6)).thenReturn(Optional.of(animais));
        when(aiService.generateWordInsight(anyString(), anyString(), anyString(), anyList(), anyString()))
                .thenReturn(new WordInsightAiResponse("Dispositivo usado para digitar.", "  tecnologia "));

        service.save(new WordRequest("teclado", "keyboard", 6), 1L);

        assertThat(captureSavedWord().getCategory()).isEqualTo(tecnologia);
    }

    @Test
    void correctedCategoryReusesExistingWordInsteadOfDuplicating() {
        Word existing = Word.builder().id(77L).original("teclado").translated("keyboard").category(tecnologia)
                .fromLanguage(user.getNativeLanguage()).toLanguage(user.getChosenLanguage()).build();
        when(categoryRepository.findById(6)).thenReturn(Optional.of(animais));
        when(aiService.generateWordInsight(anyString(), anyString(), anyString(), anyList(), anyString()))
                .thenReturn(new WordInsightAiResponse("Dispositivo usado para digitar.", "Tecnologia"));
        when(wordRepository.findByOriginalAndTranslatedAndCategory("teclado", "keyboard", tecnologia))
                .thenReturn(Optional.of(existing));
        when(userWordRepository.findById(any())).thenReturn(Optional.empty());

        UserWordListResponse response = service.save(new WordRequest("teclado", "keyboard", 6), 1L);

        verify(wordRepository, never()).save(any());
        assertThat(response.wordId()).isEqualTo(77L);
        assertThat(response.isSaved()).isTrue();
    }

    @Test
    void existingWordWithSameCategorySkipsAi() {
        Word existing = Word.builder().id(77L).original("teclado").translated("keyboard").category(tecnologia)
                .fromLanguage(user.getNativeLanguage()).toLanguage(user.getChosenLanguage()).build();
        when(categoryRepository.findById(3)).thenReturn(Optional.of(tecnologia));
        when(wordRepository.findByOriginalAndTranslatedAndCategory("teclado", "keyboard", tecnologia))
                .thenReturn(Optional.of(existing));
        when(userWordRepository.findById(any())).thenReturn(Optional.empty());

        service.save(new WordRequest("teclado", "keyboard", 3), 1L);

        verifyNoInteractions(aiService);
    }

    @Test
    void repeatedWhitespaceIsCollapsedBeforeSaving() {
        when(categoryRepository.findById(3)).thenReturn(Optional.of(tecnologia));
        when(aiService.generateWordInsight(eq("teclado sem fio"), eq("wireless keyboard"), anyString(), anyList(), anyString()))
                .thenReturn(new WordInsightAiResponse("Teclado conectado sem cabos.", "Tecnologia"));

        service.save(new WordRequest("  Teclado   sem	fio ", "Wireless    Keyboard", 3), 1L);

        Word saved = captureSavedWord();
        assertThat(saved.getOriginal()).isEqualTo("teclado sem fio");
        assertThat(saved.getTranslated()).isEqualTo("wireless keyboard");
    }

    @Test
    void catalogSearchUsesUserLanguagePairAndNormalizedTerm() {
        when(wordRepository.searchCatalog(eq(1), eq(2), eq("teclado sem fio"), eq(3), any()))
                .thenReturn(new PageImpl<>(List.of()));

        service.catalog(1L, "  Teclado  sem fio ", 3, PageRequest.of(0, 20));

        verify(wordRepository).searchCatalog(eq(1), eq(2), eq("teclado sem fio"), eq(3), any());
    }

    @Test
    void catalogWithoutFiltersUsesEmptyTermAndNoCategory() {
        when(wordRepository.searchCatalog(eq(1), eq(2), eq(""), eq(0), any()))
                .thenReturn(new PageImpl<>(List.of()));

        service.catalog(1L, null, null, PageRequest.of(0, 20));

        verify(wordRepository).searchCatalog(eq(1), eq(2), eq(""), eq(0), any());
    }

    @Test
    void aiFailureStillSavesWordWithChosenCategory() {
        when(categoryRepository.findById(3)).thenReturn(Optional.of(tecnologia));
        when(aiService.generateWordInsight(anyString(), anyString(), anyString(), anyList(), anyString()))
                .thenThrow(new RuntimeException("quota exceeded"));

        UserWordListResponse response = service.save(new WordRequest("teclado", "keyboard", 3), 1L);

        Word saved = captureSavedWord();
        assertThat(saved.getCategory()).isEqualTo(tecnologia);
        assertThat(saved.getDescription()).isEmpty();
        assertThat(response.isSaved()).isTrue();
    }

    @Test
    void longAiDescriptionIsCutToColumnLimit() {
        when(categoryRepository.findById(3)).thenReturn(Optional.of(tecnologia));
        when(aiService.generateWordInsight(anyString(), anyString(), anyString(), anyList(), anyString()))
                .thenReturn(new WordInsightAiResponse("a".repeat(350), "Tecnologia"));

        service.save(new WordRequest("teclado", "keyboard", 3), 1L);

        assertThat(captureSavedWord().getDescription()).hasSize(200);
    }

    @Test
    void unknownCategoryIdIsRejected() {
        when(categoryRepository.findById(999)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.save(new WordRequest("teclado", "keyboard", 999), 1L))
                .isInstanceOf(NotFoundException.class);
    }

    private Word captureSavedWord() {
        ArgumentCaptor<Word> captor = ArgumentCaptor.forClass(Word.class);
        verify(wordRepository).save(captor.capture());
        return captor.getValue();
    }
}
