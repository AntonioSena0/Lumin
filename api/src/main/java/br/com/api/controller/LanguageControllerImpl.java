package br.com.api.controller;

import br.com.api.dto.response.LanguageResponse;
import br.com.api.service.LanguageService;
import br.com.api.service.LanguageServiceImpl;
import jakarta.servlet.http.HttpServletRequest;
import lombok.AllArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/lumin/languages")
@AllArgsConstructor
public class LanguageControllerImpl implements LanguageController{

    private final LanguageService service;

    @Override
    @GetMapping("/")
    public ResponseEntity<List<LanguageResponse>> findAll() {
        return ResponseEntity.ok(service.findAll());
    }

    @Override
    @GetMapping("/{id}")
    public ResponseEntity<LanguageResponse> findById(@PathVariable Integer id) {
        return ResponseEntity.ok(service.findById(id));
    }

    /** Retorna o idioma padrão do app a partir do IP real do cliente (X-Forwarded-For) e do Accept-Language. */
    @Override
    @GetMapping("/detect")
    public ResponseEntity<LanguageResponse> detect(HttpServletRequest request) {
        String ip = LanguageServiceImpl.clientIp(request.getHeader("X-Forwarded-For"), request.getRemoteAddr());
        return ResponseEntity.ok(service.detect(ip, request.getHeader("Accept-Language")));
    }

}
