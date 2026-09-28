package br.com.api.dto.event;

import lombok.Builder;

import java.util.Map;

@Builder
public record MailEvent (

        String to,
        String subject,
        String template,
        Map<String, String> vars

) {}
