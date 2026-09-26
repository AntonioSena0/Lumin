package br.com.api.repository;

import br.com.api.entity.Setting;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface SettingRepository extends JpaRepository<Setting, Long> {

    @Query("SELECT s FROM Setting s " +
            "JOIN FETCH s.appLanguage " +
            "WHERE s.userId = :userId")
    Optional<Setting> findByIdWithLanguage(@Param("userId") Long userId);

}
