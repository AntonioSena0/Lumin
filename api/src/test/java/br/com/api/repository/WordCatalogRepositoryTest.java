package br.com.api.repository;

import br.com.api.entity.Category;
import br.com.api.entity.Language;
import br.com.api.entity.Word;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.data.domain.PageRequest;
import org.springframework.test.context.ActiveProfiles;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@ActiveProfiles("test")
class WordCatalogRepositoryTest {

    @Autowired private WordRepository wordRepository;
    @Autowired private LanguageRepository languageRepository;
    @Autowired private CategoryRepository categoryRepository;

    @Test
    void catalogFiltersByLanguagePairTermAndCategory() {
        Language pt = languageRepository.findByCode("pt-BR").orElseThrow();
        Language en = languageRepository.findByCode("en").orElseThrow();
        Category first = categoryRepository.findAll().getFirst();
        Category second = categoryRepository.findAll().get(1);
        String tag = "zq" + System.nanoTime();

        Word match = word(tag + " teclado", "keyboard", pt, en, first);
        word(tag + " mouse", "mouse", pt, en, second);
        word(tag + " teclado invertido", "keyboard", en, pt, first);

        var byTerm = wordRepository.searchCatalog(pt.getId(), en.getId(), tag, 0, PageRequest.of(0, 10));
        assertThat(byTerm.getTotalElements()).isEqualTo(2);

        var byCategory = wordRepository.searchCatalog(pt.getId(), en.getId(), tag, first.getId(), PageRequest.of(0, 10));
        assertThat(byCategory.getContent()).extracting(Word::getId).containsExactly(match.getId());

        var byTranslation = wordRepository.searchCatalog(pt.getId(), en.getId(), "keyboard", first.getId(), PageRequest.of(0, 50));
        assertThat(byTranslation.getContent()).extracting(Word::getId).contains(match.getId());
    }

    private Word word(String original, String translated, Language from, Language to, Category category) {
        return wordRepository.save(Word.builder()
                .original(original)
                .translated(translated)
                .description("desc")
                .fromLanguage(from)
                .toLanguage(to)
                .category(category)
                .build());
    }
}
