package br.com.api.service;

import br.com.api.dto.response.PublicProfileResponse;
import br.com.api.dto.response.UserResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface FollowService {

    void follow(Long meId, Long targetId);
    void unfollow(Long meId, Long targetId);
    PublicProfileResponse profile(Long meId, Long targetId);
    Page<UserResponse> followers(Long userId, Pageable pageable);
    Page<UserResponse> following(Long userId, Pageable pageable);

}
