package br.com.api.repository;

import br.com.api.entity.Language;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface LanguageRepository extends JpaRepository<Language, Integer> {

    /** Busca um idioma pelo código, como pt-BR ou en. */
    Optional<Language> findByCode(String code);
}
