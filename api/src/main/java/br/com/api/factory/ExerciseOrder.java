package br.com.api.factory;

import br.com.api.entity.Exercise;
import br.com.api.entity.WrittenExercise;
import lombok.experimental.UtilityClass;

import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Deque;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;

@UtilityClass
public class ExerciseOrder {

    /** Embaralha a sessão sem repetir o mesmo tipo em sequência, escolhendo sempre o tipo com mais exercícios restantes. */
    public static List<Exercise> interleave(List<Exercise> exercises, Random random) {
        Map<String, Deque<Exercise>> byKind = new LinkedHashMap<>();
        List<Exercise> shuffled = new ArrayList<>(exercises);
        Collections.shuffle(shuffled, random);
        shuffled.forEach(e -> byKind.computeIfAbsent(kind(e), k -> new ArrayDeque<>()).add(e));

        List<Exercise> ordered = new ArrayList<>(exercises.size());
        String previous = null;
        while (ordered.size() < exercises.size()) {
            String last = previous;
            List<String> kinds = new ArrayList<>(byKind.keySet().stream()
                    .filter(k -> !byKind.get(k).isEmpty() && !k.equals(last))
                    .toList());
            if (kinds.isEmpty()) {
                kinds.add(last);
            }
            Collections.shuffle(kinds, random);
            String next = kinds.stream()
                    .max((a, b) -> Integer.compare(byKind.get(a).size(), byKind.get(b).size()))
                    .orElseThrow();
            ordered.add(byKind.get(next).poll());
            previous = next;
        }
        return ordered;
    }

    /** Identifica o tipo do exercício: o subtipo escrito ou SPEAKING. */
    public static String kind(Exercise exercise) {
        return exercise instanceof WrittenExercise written && written.getSubType() != null
                ? written.getSubType().name()
                : "SPEAKING";
    }

}
