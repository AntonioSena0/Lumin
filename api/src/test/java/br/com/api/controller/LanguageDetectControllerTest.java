package br.com.api.controller;

import br.com.api.config.ApplicationControllerAdvice;
import br.com.api.config.SecurityConfig;
import br.com.api.config.SecurityFilter;
import br.com.api.dto.response.LanguageResponse;
import br.com.api.service.JwtService;
import br.com.api.service.LanguageService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(controllers = LanguageControllerImpl.class)
@Import({SecurityConfig.class, SecurityFilter.class, ApplicationControllerAdvice.class})
class LanguageDetectControllerTest {

    @Autowired
    private MockMvc mvc;

    @MockitoBean
    private JwtService jwtService;

    @MockitoBean
    private LanguageService languageService;

    @Test
    void detectIsPublicAndUsesForwardedClientIp() throws Exception {
        when(languageService.detect("200.147.67.142", "pt-BR"))
                .thenReturn(new LanguageResponse(1, "Português (Brasil)", "pt-BR", null));

        mvc.perform(get("/lumin/languages/detect")
                        .header("X-Forwarded-For", "200.147.67.142, 10.0.0.1")
                        .header("Accept-Language", "pt-BR"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("pt-BR"));
    }
}
