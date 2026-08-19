package br.com.api.specification;

import br.com.api.dto.request.UserWordFilterRequest;
import br.com.api.entity.UserWord;
import br.com.api.entity.Word;
import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.JoinType;
import org.springframework.data.jpa.domain.Specification;

import java.util.Locale;

public class UserWordSpecification {

    public static Specification<UserWord> withFilters(Long userId, UserWordFilterRequest filter){
        return (root, query, criteriaBuilder) -> {

            Join<UserWord, Word> word = root.join("word", JoinType.INNER);

            if(!Long.class.equals(query.getResultType()) && !long.class.equals(query.getResultType())){
                var wordFetch = root.fetch("word", JoinType.INNER);
                wordFetch.fetch("category", JoinType.INNER);
                wordFetch.fetch("fromLanguage", JoinType.INNER);
                wordFetch.fetch("toLanguage", JoinType.INNER);
            }

            var predicates = criteriaBuilder.conjunction();

            predicates = criteriaBuilder.and(
                    predicates,
                    criteriaBuilder.equal(root.get("user").get("id"), userId)
            );

            if(filter == null){
                return predicates;
            }

            if(filter.saved() != null){
                predicates = criteriaBuilder.and(
                        predicates,
                        criteriaBuilder.equal(root.get("isSaved"), filter.saved())
                );
            }

            if(filter.level() != null){
                predicates = criteriaBuilder.and(
                        predicates,
                        criteriaBuilder.equal(root.get("level"), filter.level())
                );
            }

            if(filter.categoryId() != null){
                predicates = criteriaBuilder.and(
                        predicates,
                        criteriaBuilder.equal(word.get("category").get("id"), filter.categoryId())
                );
            }

            if(filter.languageId() != null){
                predicates = criteriaBuilder.and(
                        predicates,
                        criteriaBuilder.equal(word.get("toLanguage").get("id"), filter.languageId())
                );
            }

            if(Boolean.TRUE.equals(filter.onlyPracticed())){
                predicates = criteriaBuilder.and(
                        predicates,
                        criteriaBuilder.isNotNull(root.get("lastPracticed"))
                );
            }

            if(Boolean.TRUE.equals(filter.onlyWeak())){
                predicates = criteriaBuilder.and(
                        predicates,
                        criteriaBuilder.greaterThan(root.get("incorrectAnswers"), 0L)
                );
            }

            if(filter.search() != null && !filter.search().isBlank()) {
                String search = "%" + filter.search().trim().toLowerCase(Locale.ROOT) + "%";

                predicates = criteriaBuilder.and(
                        predicates,
                        criteriaBuilder.or(
                                criteriaBuilder.like(criteriaBuilder.lower(word.get("original")), search),
                                criteriaBuilder.like(criteriaBuilder.lower(word.get("translated")), search)
                        )
                );
            }

            return predicates;
        };
    }

}
