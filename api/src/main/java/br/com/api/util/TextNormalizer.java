package br.com.api.util;

import lombok.experimental.UtilityClass;

@UtilityClass
public class TextNormalizer {

    /** Padroniza texto salvo ou buscado: remove espaços nas pontas, colapsa espaços repetidos e converte para minúsculas. */
    public static String normalize(String value) {
        if (value == null) {
            return "";
        }
        return value.trim().replaceAll("\\s+", " ").toLowerCase();
    }

}
