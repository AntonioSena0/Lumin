package br.com.api.controller;

import br.com.api.dto.request.ExerciseCheckRequest;
import br.com.api.dto.response.WrittenExerciseCheckResponse;
import br.com.api.dto.response.WrittenExerciseResponse;
import br.com.api.service.WrittenExerciseService;
import lombok.RequiredArgsConstructor;
import org.apache.coyote.Response;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/lumin/exercises/written")
@RequiredArgsConstructor
public class WrittenExerciseControllerImpl implements WrittenExerciseController{

    private final WrittenExerciseService service;

    @Override
    @GetMapping("/{userId}")
    public ResponseEntity<List<WrittenExerciseResponse>> findByUserId(@PathVariable Long userId){
        return ResponseEntity.ok(service.findByUserId(userId));
    }

    @Override
    @PostMapping("/generate/{userId}/{wordId}")
    public ResponseEntity<WrittenExerciseResponse> generate(@PathVariable Long userId, @PathVariable Long wordId) {
        return ResponseEntity.ok(service.generateNewExercise(userId, wordId));
    }

    @Override
    @PostMapping("/{id}/check")
    public ResponseEntity<WrittenExerciseCheckResponse> check(@PathVariable Long id, @RequestBody ExerciseCheckRequest answer) {
        return ResponseEntity.ok(service.validate(id, answer));
    }

    @Override
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id){
        service.delete(id);

        return ResponseEntity.status(HttpStatus.NO_CONTENT).build();
    }

}