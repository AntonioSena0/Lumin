package br.com.api.repository;

import br.com.api.entity.*;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.PageRequest;
import org.springframework.test.context.ActiveProfiles;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@DataJpaTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@ActiveProfiles("test")
class FollowRepositoryTest {

    @Autowired private FollowRepository followRepository;
    @Autowired private UserRepository userRepository;
    @Autowired private LanguageRepository languageRepository;
    @Autowired private AvatarRepository avatarRepository;

    @Test
    void followersAndFollowingAreListedAndCounted() {
        User ana = user("ana");
        User bia = user("bia");
        User caio = user("caio");

        followRepository.save(Follow.builder().id(new FollowId(ana.getId(), bia.getId())).build());
        followRepository.save(Follow.builder().id(new FollowId(caio.getId(), bia.getId())).build());
        followRepository.flush();

        var followers = userRepository.findFollowersOf(bia.getId(), PageRequest.of(0, 10));
        assertThat(followers.getTotalElements()).isEqualTo(2);
        assertThat(followers.getContent()).extracting(User::getId).containsExactlyInAnyOrder(ana.getId(), caio.getId());

        assertThat(userRepository.findFollowedBy(ana.getId(), PageRequest.of(0, 10)).getContent())
                .extracting(User::getId).containsExactly(bia.getId());
        assertThat(followRepository.countByIdFollowedId(bia.getId())).isEqualTo(2);
        assertThat(followRepository.countByIdFollowerId(bia.getId())).isZero();
    }

    @Test
    void databaseRejectsSelfFollow() {
        User ana = user("self");

        assertThatThrownBy(() -> followRepository.saveAndFlush(Follow.builder().id(new FollowId(ana.getId(), ana.getId())).build()))
                .isInstanceOf(DataIntegrityViolationException.class);
    }

    @Test
    void searchByNameIsCaseInsensitive() {
        User ana = user("Mariana");

        assertThat(userRepository.searchByName("MARI", PageRequest.of(0, 10)).getContent())
                .extracting(User::getId).contains(ana.getId());
    }

    private User user(String name) {
        String suffix = Long.toString(System.nanoTime());
        Language language = languageRepository.findAll().getFirst();
        Avatar avatar = avatarRepository.findAll().getFirst();
        return userRepository.save(User.builder()
                .name(name + "-" + suffix)
                .email(name + "-" + suffix + "@test.com")
                .password("secret123")
                .nativeLanguage(language)
                .chosenLanguage(language)
                .avatar(avatar)
                .build());
    }
}
