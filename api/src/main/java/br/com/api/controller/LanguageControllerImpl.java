package br.com.api.controller;

import br.com.api.dto.LanguageResponse;
import br.com.api.service.LanguageService;
import lombok.AllArgsConstructor;
import org.springframework.http.HttpStatus;
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
        return ResponseEntity.status(HttpStatus.OK).body(service.findAll());
    }

    @Override
    @GetMapping("/{id}")
    public ResponseEntity<LanguageResponse> findById(@PathVariable Integer id) {
        return ResponseEntity.status(HttpStatus.OK).body(service.findById(id));
    }

}
