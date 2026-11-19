package br.com.api.service;

import br.com.api.dto.response.PublicProfileResponse;
import br.com.api.entity.*;
import br.com.api.exception.BusinessException;
import br.com.api.exception.NotFoundException;
import br.com.api.repository.FollowRepository;
import br.com.api.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class FollowServiceTest {

    @Mock private FollowRepository followRepository;
    @Mock private UserRepository userRepository;

    private FollowServiceImpl service;
    private User bia;

    @BeforeEach
    void setUp() {
        service = new FollowServiceImpl(followRepository, userRepository);
        Language pt = Language.builder().id(1).code("pt-BR").name("Português (Brasil)").build();
        Language en = Language.builder().id(2).code("en").name("English").build();
        Avatar avatar = Avatar.builder().id(1).name("Default").imgUrl("/images/avatars/default.png").build();
        bia = User.builder().id(2L).name("bia").email("bia@mail.com").nativeLanguage(pt).chosenLanguage(en).avatar(avatar).build();
    }

    @Test
    void cannotFollowYourself() {
        assertThatThrownBy(() -> service.follow(1L, 1L))
                .isInstanceOf(BusinessException.class)
                .satisfies(e -> assertThat(((BusinessException) e).getCode()).isEqualTo("CANNOT_FOLLOW_SELF"));
        verify(followRepository, never()).save(any());
    }

    @Test
    void cannotFollowUnknownUser() {
        when(userRepository.existsById(99L)).thenReturn(false);

        assertThatThrownBy(() -> service.follow(1L, 99L))
                .isInstanceOf(NotFoundException.class)
                .satisfies(e -> assertThat(((NotFoundException) e).getCode()).isEqualTo("USER_NOT_FOUND"));
    }

    @Test
    void followCreatesRelation() {
        when(userRepository.existsById(2L)).thenReturn(true);
        when(followRepository.existsById(new FollowId(1L, 2L))).thenReturn(false);

        service.follow(1L, 2L);

        ArgumentCaptor<Follow> captor = ArgumentCaptor.forClass(Follow.class);
        verify(followRepository).save(captor.capture());
        assertThat(captor.getValue().getId()).isEqualTo(new FollowId(1L, 2L));
    }

    @Test
    void followTwiceIsIdempotent() {
        when(userRepository.existsById(2L)).thenReturn(true);
        when(followRepository.existsById(new FollowId(1L, 2L))).thenReturn(true);

        service.follow(1L, 2L);

        verify(followRepository, never()).save(any());
    }

    @Test
    void unfollowRemovesRelation() {
        service.unfollow(1L, 2L);

        verify(followRepository).deleteById(new FollowId(1L, 2L));
    }

    @Test
    void profileShowsCountsAndWhetherIFollow() {
        when(userRepository.findByIdWithRelations(2L)).thenReturn(Optional.of(bia));
        when(followRepository.countByIdFollowedId(2L)).thenReturn(10L);
        when(followRepository.countByIdFollowerId(2L)).thenReturn(3L);
        when(followRepository.existsById(new FollowId(1L, 2L))).thenReturn(true);

        PublicProfileResponse profile = service.profile(1L, 2L);

        assertThat(profile.name()).isEqualTo("bia");
        assertThat(profile.followers()).isEqualTo(10L);
        assertThat(profile.following()).isEqualTo(3L);
        assertThat(profile.followedByMe()).isTrue();
        assertThat(profile.me()).isFalse();
    }

    @Test
    void profileOfUnknownUserIsNotFound() {
        when(userRepository.findByIdWithRelations(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.profile(1L, 99L)).isInstanceOf(NotFoundException.class);
    }
}
