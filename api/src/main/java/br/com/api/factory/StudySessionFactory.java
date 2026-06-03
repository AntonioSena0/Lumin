package br.com.api.factory;

import br.com.api.domain.SessionStatus;
import br.com.api.entity.Exercise;
import br.com.api.entity.StudySession;
import br.com.api.entity.User;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class StudySessionFactory {

    public StudySession createStudySession(User user, List<Exercise> exercises){

        return StudySession
                .builder()
                .currentIndex(0)
                .totalExercises(exercises.size())
                .score(0)
                .status(SessionStatus.IN_PROGRESS)
                .finishedAt(null)
                .user(user)
                .exercises(exercises)
                .build();

    }

}
