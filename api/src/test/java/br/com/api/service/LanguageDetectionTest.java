package br.com.api.service;

import br.com.api.entity.Language;
import br.com.api.repository.LanguageRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.web.client.ResourceAccessException;
import org.springframework.web.client.RestTemplate;

import java.util.Map;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class LanguageDetectionTest {

    @Mock private LanguageRepository repository;
    @Mock private RestTemplate restTemplate;

    private LanguageServiceImpl service;

    @BeforeEach
    void setUp() {
        service = new LanguageServiceImpl(repository, restTemplate);
        Language pt = Language.builder().id(1).code("pt-BR").name("Português (Brasil)").build();
        Language en = Language.builder().id(2).code("en").name("English").build();
        lenient().when(repository.findByCode("pt-BR")).thenReturn(Optional.of(pt));
        lenient().when(repository.findByCode("en")).thenReturn(Optional.of(en));
    }

    @Test
    void brazilianIpGetsPortuguese() {
        when(restTemplate.getForObject(anyString(), eq(Map.class))).thenReturn(Map.of("country", "BR"));

        assertThat(service.detect("200.147.67.142", null).code()).isEqualTo("pt-BR");
    }

    @Test
    void foreignIpGetsEnglishEvenWithPortugueseDevice() {
        when(restTemplate.getForObject(anyString(), eq(Map.class))).thenReturn(Map.of("country", "US"));

        assertThat(service.detect("8.8.8.8", "pt-BR,pt;q=0.9").code()).isEqualTo("en");
    }

    @Test
    void lookupFailureFallsBackToDeviceLanguage() {
        when(restTemplate.getForObject(anyString(), eq(Map.class))).thenThrow(new ResourceAccessException("timeout"));

        assertThat(service.detect("8.8.8.8", "pt-BR,pt;q=0.9").code()).isEqualTo("pt-BR");
        assertThat(service.detect("8.8.8.8", "en-US").code()).isEqualTo("en");
    }

    @Test
    void privateIpSkipsLookupAndUsesDeviceLanguage() {
        assertThat(service.detect("10.0.0.5", "pt").code()).isEqualTo("pt-BR");
        assertThat(service.detect("127.0.0.1", null).code()).isEqualTo("en");
        verifyNoInteractions(restTemplate);
    }

    @Test
    void firstForwardedAddressIsTheClient() {
        assertThat(LanguageServiceImpl.clientIp("200.147.67.142, 10.0.0.1", "10.0.0.1")).isEqualTo("200.147.67.142");
        assertThat(LanguageServiceImpl.clientIp(null, "200.147.67.142")).isEqualTo("200.147.67.142");
    }
}
