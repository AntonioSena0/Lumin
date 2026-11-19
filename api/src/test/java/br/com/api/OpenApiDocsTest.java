package br.com.api;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class OpenApiDocsTest {

    @Autowired
    private MockMvc mvc;

    @Test
    void newRoutesAreDocumentedInSwagger() throws Exception {
        mvc.perform(get("/v3/api-docs"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.paths['/lumin/languages/detect'].get").exists())
                .andExpect(jsonPath("$.paths['/lumin/words/catalog'].get").exists())
                .andExpect(jsonPath("$.paths['/lumin/users/{id}/profile'].get").exists())
                .andExpect(jsonPath("$.paths['/lumin/users/{id}/follow'].post").exists())
                .andExpect(jsonPath("$.paths['/lumin/users/{id}/follow'].delete").exists())
                .andExpect(jsonPath("$.paths['/lumin/users/{id}/followers'].get").exists())
                .andExpect(jsonPath("$.paths['/lumin/users/{id}/following'].get").exists());
    }
}
