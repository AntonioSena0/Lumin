package br.com.api.domain;

public interface Checkable {

    boolean checkAnswer(String answer);
    String getCorrectAnswer();

}
