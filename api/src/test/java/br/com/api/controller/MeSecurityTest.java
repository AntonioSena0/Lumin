package br.com.api.controller;

import br.com.api.config.ApplicationControllerAdvice;
import br.com.api.config.SecurityConfig;
import br.com.api.config.SecurityFilter;
import br.com.api.exception.BusinessException;
import br.com.api.service.JwtService;
import br.com.api.service.SettingService;
import br.com.api.service.StudySessionService;
import jakarta.servlet.http.Cookie;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(controllers = {StudySessionControllerImpl.class, SettingControllerImpl.class})
@Import({SecurityConfig.class, SecurityFilter.class, ApplicationControllerAdvice.class})
class MeSecurityTest {

    @Autowired
    private MockMvc mvc;

    @MockitoBean
    private JwtService jwtService;

    @MockitoBean
    private StudySessionService studySessionService;

    @MockitoBean
    private SettingService settingService;

    @Test
    void sessionsWithoutAccessCookieReturn401() throws Exception {
        mvc.perform(get("/lumin/me/sessions/1"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("NOT_AUTHENTICATED"));
    }

    @Test
    void finishWithoutAccessCookieReturns401() throws Exception {
        mvc.perform(patch("/lumin/me/sessions/finish/1"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("NOT_AUTHENTICATED"));
    }

    @Test
    void settingsWithoutAccessCookieReturn401() throws Exception {
        mvc.perform(get("/lumin/me/settings"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("NOT_AUTHENTICATED"));
    }

    @Test
    void userACannotReadUserBSession() throws Exception {
        when(jwtService.getUserId("token-a")).thenReturn(1L);
        when(jwtService.isVerified("token-a")).thenReturn(true);
        when(studySessionService.findById(99L)).thenThrow(new BusinessException("SESSION_NOT_OWNED", "Essa sessao nao pertence a voce"));

        mvc.perform(get("/lumin/me/sessions/99").cookie(new Cookie("access", "token-a")))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code").value("SESSION_NOT_OWNED"));
    }

    @Test
    void userACannotFinishUserBSession() throws Exception {
        when(jwtService.getUserId("token-a")).thenReturn(1L);
        when(jwtService.isVerified("token-a")).thenReturn(true);
        when(studySessionService.finishSession(eq(99L), eq(1L))).thenThrow(new BusinessException("SESSION_NOT_OWNED", "Essa sessao nao pertence a voce"));

        mvc.perform(patch("/lumin/me/sessions/finish/99").cookie(new Cookie("access", "token-a")))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code").value("SESSION_NOT_OWNED"));
    }
}
