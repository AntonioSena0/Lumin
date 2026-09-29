package br.com.api.repository.projection;

public interface SessionWordProjection {

    Long getSessionId();

    Long getWordId();

    String getWordOriginal();

    String getWordTranslated();

    String getLanguageName();

    String getLanguageCode();

}
