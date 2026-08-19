package br.com.api.repository;

import br.com.api.entity.UserWord;
import br.com.api.entity.UserWordId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserWordRepository extends JpaRepository<UserWord, UserWordId>, JpaSpecificationExecutor<UserWord> {

    @Query("SELECT uw FROM UserWord uw " +
        "JOIN FETCH uw.word w " +
        "JOIN FETCH w.category " +
        "JOIN FETCH w.fromLanguage " +
        "JOIN FETCH w.toLanguage " +
        "WHERE uw.user.id = :userId " +
        "AND uw.word.id = :wordId")
    Optional<UserWord> findByUserIdAndWordIdWithRelations(@Param("userId") Long userId, @Param("wordId") Long wordId);

}
