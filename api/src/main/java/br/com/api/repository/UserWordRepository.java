package br.com.api.repository;

import br.com.api.entity.UserWord;
import br.com.api.entity.UserWordId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserWordRepository extends JpaRepository<UserWord, UserWordId> {
}
