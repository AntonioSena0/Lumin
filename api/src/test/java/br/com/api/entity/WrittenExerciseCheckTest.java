package br.com.api.entity;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class WrittenExerciseCheckTest {

    private final WrittenExercise exercise = WrittenExercise.builder()
            .correctAnswer("The keyboard is on the desk, near the lamp.")
            .build();

    @Test
    void ignoresPunctuationCaseAndExtraSpaces() {
        assertThat(exercise.checkAnswer("the keyboard  is on the desk near the lamp")).isTrue();
    }

    @Test
    void keepsApostrophesMeaningful() {
        WrittenExercise contraction = WrittenExercise.builder().correctAnswer("I don't have a keyboard.").build();

        assertThat(contraction.checkAnswer("I don’t have a keyboard")).isTrue();
        assertThat(contraction.checkAnswer("I dont have a keyboard")).isFalse();
    }

    @Test
    void wrongWordIsRejected() {
        assertThat(exercise.checkAnswer("The mouse is on the desk, near the lamp.")).isFalse();
        assertThat(exercise.checkAnswer(null)).isFalse();
    }
}
