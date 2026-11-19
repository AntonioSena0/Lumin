package br.com.api.repository;

import br.com.api.entity.Avatar;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.core.io.ClassPathResource;
import org.springframework.test.context.ActiveProfiles;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@ActiveProfiles("test")
class AvatarCatalogTest {

    @Autowired
    private AvatarRepository avatarRepository;

    @Test
    void everyDefaultAvatarHasItsImageInStatic() {
        List<Avatar> defaults = avatarRepository.findAll().stream()
                .filter(a -> a.getImgUrl().startsWith("/images/avatars/"))
                .toList();

        assertThat(defaults).hasSize(12);
        assertThat(defaults).allSatisfy(a ->
                assertThat(new ClassPathResource("static" + a.getImgUrl()).exists())
                        .as(a.getImgUrl())
                        .isTrue());
    }
}
