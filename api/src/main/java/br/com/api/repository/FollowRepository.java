package br.com.api.repository;

import br.com.api.entity.Follow;
import br.com.api.entity.FollowId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface FollowRepository extends JpaRepository<Follow, FollowId> {

    /** Conta quantos seguidores um usuário tem. */
    long countByIdFollowedId(Long followedId);

    /** Conta quantos usuários um usuário segue. */
    long countByIdFollowerId(Long followerId);

}
