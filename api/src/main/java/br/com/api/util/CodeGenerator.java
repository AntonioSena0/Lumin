package br.com.api.util;

import lombok.experimental.UtilityClass;

import java.security.SecureRandom;

@UtilityClass
public class CodeGenerator {

    private static final SecureRandom RANDOM = new SecureRandom();

    public static String sixDigits() {
        return String.format("%06d", RANDOM.nextInt(1_000_000));
    }

}
