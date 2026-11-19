package br.com.api.factory;

import br.com.api.domain.WrittenType;
import br.com.api.entity.Exercise;
import br.com.api.entity.SpeakingExercise;
import br.com.api.entity.WrittenExercise;
import org.junit.jupiter.api.RepeatedTest;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

import static org.assertj.core.api.Assertions.assertThat;

class ExerciseOrderTest {

    @RepeatedTest(20)
    void sessionNeverRepeatsTheSameKindInARow() {
        List<Exercise> grouped = new ArrayList<>();
        add(grouped, WrittenType.FILL_IN, 3);
        add(grouped, WrittenType.TRANSLATE, 2);
        add(grouped, WrittenType.MULTIPLE_CHOICE, 3);
        add(grouped, WrittenType.REWRITE, 2);
        for (int i = 0; i < 5; i++) grouped.add(SpeakingExercise.builder().build());

        List<Exercise> ordered = ExerciseOrder.interleave(grouped, new Random());

        assertThat(ordered).hasSize(15).containsExactlyInAnyOrderElementsOf(grouped);
        for (int i = 1; i < ordered.size(); i++) {
            assertThat(ExerciseOrder.kind(ordered.get(i))).isNotEqualTo(ExerciseOrder.kind(ordered.get(i - 1)));
        }
    }

    private void add(List<Exercise> list, WrittenType type, int count) {
        for (int i = 0; i < count; i++) list.add(WrittenExercise.builder().subType(type).build());
    }
}
