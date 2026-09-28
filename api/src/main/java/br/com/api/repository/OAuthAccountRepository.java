package br.com.api.repository;

import br.com.api.entity.OAuthAccount;
import br.com.api.entity.OAuthAccountId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface OAuthAccountRepository extends JpaRepository<OAuthAccount, OAuthAccountId> {
}
