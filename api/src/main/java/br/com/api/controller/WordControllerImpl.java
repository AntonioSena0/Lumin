package br.com.api.controller;

import br.com.api.dto.response.PageResponse;
import br.com.api.dto.response.WordResponse;
import br.com.api.service.WordService;
import lombok.AllArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/lumin/words")
@AllArgsConstructor
public class WordControllerImpl implements WordController{

    private final WordService service;

    @Override
    @GetMapping
    public ResponseEntity<PageResponse<WordResponse>> findAll(
            @PageableDefault(sort = "id", direction = Sort.Direction.ASC) Pageable pageable
    ) {
        return ResponseEntity.ok(PageResponse.from(service.findAll(pageable)));
    }

    @Override
    @GetMapping("/{wordId}")
    public ResponseEntity<WordResponse> findById(@PathVariable Long wordId) {
        return ResponseEntity.ok(service.findById(wordId));
    }

    @Override
    @GetMapping("/{languageId}/search={q}")
    public ResponseEntity<PageResponse<WordResponse>> search(
            @PathVariable Integer languageId,
            @PathVariable String q,
            @PageableDefault(sort = "id", direction = Sort.Direction.ASC) Pageable pageable
    ) {
        return ResponseEntity.ok(PageResponse.from(service.search(q, languageId, pageable)));
    }

}
