package br.com.api.controller;

import br.com.api.domain.WordDomainLevel;
import br.com.api.dto.request.UserWordFilterRequest;
import br.com.api.dto.request.WordRequest;
import br.com.api.dto.response.PageResponse;
import br.com.api.dto.response.UserWordListResponse;
import br.com.api.service.UserWordQueryService;
import br.com.api.service.WordService;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/lumin/users/{userId}/words")
@AllArgsConstructor
public class UserWordControllerImpl implements UserWordController {

    private final UserWordQueryService service;
    private final WordService wordService;

    @Override
    @GetMapping("/{wordId}")
    public ResponseEntity<UserWordListResponse> findUserWordById(@PathVariable Long userId, @PathVariable Long wordId) {
        return ResponseEntity.ok(service.findUserWordById(userId, wordId));
    }

    @Override
    @GetMapping
    public ResponseEntity<PageResponse<UserWordListResponse>> findUserWords(
            @PathVariable Long userId,
            @RequestParam(required = false) Boolean saved,
            @RequestParam(required = false) WordDomainLevel level,
            @RequestParam(required = false) Integer categoryId,
            @RequestParam(required = false) Integer languageId,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) Boolean onlyPracticed,
            @RequestParam(required = false) Boolean onlyWeak,
            @PageableDefault(size = 20, sort = "lastPracticed", direction = Sort.Direction.DESC) Pageable pageable
    ) {
        UserWordFilterRequest filter = new UserWordFilterRequest(
                saved,
                level,
                categoryId,
                languageId,
                search,
                onlyPracticed,
                onlyWeak
        );

        return ResponseEntity.ok(PageResponse.from(service.findUserWords(
                userId,
                filter,
                pageable
        )));
    }

    @Override
    @PostMapping("/save")
    public ResponseEntity<UserWordListResponse> save(@RequestBody @Valid WordRequest request, @PathVariable Long userId) {
        return ResponseEntity.status(HttpStatus.CREATED).body(wordService.save(request, userId));
    }

    @Override
    @PatchMapping("/{wordId}/unsave")
    public ResponseEntity<UserWordListResponse> unsave(@PathVariable Long wordId, @PathVariable Long userId) {
        return ResponseEntity.ok(wordService.unsave(wordId, userId));
    }

}
