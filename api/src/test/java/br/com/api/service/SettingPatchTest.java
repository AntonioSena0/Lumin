package br.com.api.service;

import br.com.api.domain.VoiceType;
import br.com.api.dto.request.SettingUpdateRequest;
import br.com.api.dto.response.SettingResponse;
import br.com.api.entity.Language;
import br.com.api.entity.Setting;
import br.com.api.exception.NotFoundException;
import br.com.api.repository.LanguageRepository;
import br.com.api.repository.SettingRepository;
import br.com.api.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class SettingPatchTest {

    @Mock
    private SettingRepository settingRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private LanguageRepository languageRepository;

    private SettingServiceImpl service;

    private Language appLanguage;

    private Setting setting;

    @BeforeEach
    void setUp() {
        service = new SettingServiceImpl(settingRepository, userRepository, languageRepository);
        appLanguage = Language.builder().id(1).code("pt").name("Portugues").build();
        setting = Setting.builder()
                .userId(1L)
                .appLanguage(appLanguage)
                .notifyDaily(true)
                .notifyReview(true)
                .voice(VoiceType.FEMALE)
                .build();
    }

    @Test
    void partialUpdateChangesOnlySentFields() {
        when(settingRepository.findByIdWithLanguage(1L)).thenReturn(Optional.of(setting));

        SettingResponse response = service.updateByUserId(new SettingUpdateRequest(null, false, null, null), 1L);

        assertThat(response.notifyDaily()).isFalse();
        assertThat(response.notifyReview()).isTrue();
        assertThat(response.voice()).isEqualTo(VoiceType.FEMALE);
        assertThat(response.appLanguage().id()).isEqualTo(1);
        assertThat(setting.isNotifyDaily()).isFalse();
        assertThat(setting.isNotifyReview()).isTrue();
        assertThat(setting.getVoice()).isEqualTo(VoiceType.FEMALE);
        assertThat(setting.getAppLanguage().getId()).isEqualTo(1);
        verify(languageRepository, never()).findById(any());
    }

    @Test
    void unknownLanguageReturnsLanguageNotFound() {
        when(settingRepository.findByIdWithLanguage(1L)).thenReturn(Optional.of(setting));
        when(languageRepository.findById(999)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.updateByUserId(new SettingUpdateRequest(999, null, null, null), 1L))
                .isInstanceOf(NotFoundException.class)
                .satisfies(e -> assertThat(((NotFoundException) e).getCode()).isEqualTo("LANGUAGE_NOT_FOUND"));
    }
}
