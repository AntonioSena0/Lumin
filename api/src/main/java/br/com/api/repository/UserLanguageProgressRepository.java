package br.com.api.repository;

import br.com.api.entity.UserLanguageProgress;
import br.com.api.entity.UserLanguageProgressId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserLanguageProgressRepository extends JpaRepository<UserLanguageProgress, UserLanguageProgressId> {

    @Query("SELECT ulp FROM UserLanguageProgress ulp " +
            "JOIN FETCH ulp.user u " +
            "JOIN FETCH u.nativeLanguage " +
            "JOIN FETCH u.chosenLanguage " +
            "JOIN FETCH u.avatar " +
            "JOIN FETCH ulp.language " +
            "WHERE ulp.id.userId = :userId")
    List<UserLanguageProgress> findByIdUserIdWithRelations(@Param("userId") Long userId);

    @Query("SELECT ulp FROM UserLanguageProgress ulp " +
            "JOIN FETCH ulp.user u " +
            "JOIN FETCH u.nativeLanguage " +
            "JOIN FETCH u.chosenLanguage " +
            "JOIN FETCH u.avatar " +
            "JOIN FETCH ulp.language " +
            "WHERE ulp.id.userId = :userId " +
            "AND ulp.id.languageId = :languageId")
    Optional<UserLanguageProgress> findByIdWithRelations(@Param("userId") Long userId, @Param("languageId") Integer languageId);
}
