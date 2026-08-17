package br.com.api.repository;

import br.com.api.entity.UserLanguageProgress;
import br.com.api.entity.UserLanguageProgressId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface UserLanguageProgressRepository extends JpaRepository<UserLanguageProgress, UserLanguageProgressId> {

    List<UserLanguageProgress> findByIdUserId(Long userId);

}
