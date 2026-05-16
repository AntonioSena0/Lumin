package br.com.api.controller;

import br.com.api.dto.WordRequest;
import br.com.api.dto.WordResponse;
import br.com.api.dto.WordUpdateRequest;
import br.com.api.service.WordService;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/lumin/words")
@AllArgsConstructor
public class WordControllerImpl implements WordController{

    private final WordService service;

    @Override
    @GetMapping("/")
    public ResponseEntity<List<WordResponse>> findAll() {
        return ResponseEntity.ok(service.findAll());
    }

    @Override
    @GetMapping("/{wordId}")
    public ResponseEntity<WordResponse> findById(@PathVariable Long wordId) {
        return ResponseEntity.ok(service.findById(wordId));
    }

    @Override
    @GetMapping("/search={q}")
    public ResponseEntity<List<WordResponse>> search(@PathVariable String q) {
        return ResponseEntity.ok(service.search(q));
    }

    @Override
    @PostMapping("/save/{userId}")
    public ResponseEntity<WordResponse> save(@RequestBody @Valid WordRequest request, @PathVariable Long userId) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.save(request, userId));
    }

    @Override
    @PatchMapping("/update/{wordId}")
    public ResponseEntity<WordResponse> update(@RequestBody @Valid WordUpdateRequest request, @PathVariable Long wordId) {
        return ResponseEntity.ok(service.update(request, wordId));
    }

    @Override
    @DeleteMapping("/unsave/{wordId}/{userId}")
    public ResponseEntity<Void> unsave(@PathVariable Long wordId, @PathVariable Long userId) {

        service.unsave(wordId, userId);

        return ResponseEntity.status(HttpStatus.NO_CONTENT).build();

    }
}
